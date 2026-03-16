//==============================================================================
// Multi-Port Retirement Tracer
//==============================================================================
// Logs retired (committed) instructions from all 8 retirement buffer ports.
// Uses the decoding logic from the lowRISC tracer for readable output.
//
// Supported Extensions:
//   - RV32I/RV64I base integer
//   - RV32M multiply/divide
//   - RV32F single-precision floating-point (with f0-f31 naming)
//   - RV32C compressed instructions (16-bit)
//   - Zba/Zbb/Zbc/Zbs bit manipulation
//   - Zicsr CSR instructions
//   - RVV vector (v0-v31 naming)
//
// Output format:
//   order cycle pc inst [rd=value] [rs1:value] [rs2:value] [TRAP]
//
// VECTOR TRACE FIX:
//   Vector instruction results are read from the shadow VRF (vecregfile) which
//   probes the actual hardware register file, rather than from the retirement
//   buffer's accumulated write data. This fixes two issues:
//   1. Reduction tail element zeroing: The retirement buffer lacks byte-enable
//      info, so tail elements appeared as zeros. The VRF correctly preserves
//      tail elements via byte-enable flip-flops.
//   2. WAW hazard: When two instructions write the same register, the VRF
//      always has the architecturally correct final value.
//
// Enable via plusarg: +TRACE_FILE=trace.log
//==============================================================================

module retirement_tracer (
    input logic        clk,
    input logic        resetn,

    // Shadow register file for source register value lookups
    input logic [31:0] regfile [0:31],

    // Shadow vector register file - use this for vector values instead of rb_data
    // to get correct architectural state (fixes WAW tracer bug)
    input logic [127:0] vecregfile [0:31],

    // Retirement buffer ports (8 ports)
    input logic        rb_valid_0,
    input logic [31:0] rb_pc_0,
    input logic [31:0] rb_inst_0,
    input logic [6:0]  rb_idx_0,
    input logic [127:0] rb_data_0,
    input logic        rb_trap_0,

    input logic        rb_valid_1,
    input logic [31:0] rb_pc_1,
    input logic [31:0] rb_inst_1,
    input logic [6:0]  rb_idx_1,
    input logic [127:0] rb_data_1,
    input logic        rb_trap_1,

    input logic        rb_valid_2,
    input logic [31:0] rb_pc_2,
    input logic [31:0] rb_inst_2,
    input logic [6:0]  rb_idx_2,
    input logic [127:0] rb_data_2,
    input logic        rb_trap_2,

    input logic        rb_valid_3,
    input logic [31:0] rb_pc_3,
    input logic [31:0] rb_inst_3,
    input logic [6:0]  rb_idx_3,
    input logic [127:0] rb_data_3,
    input logic        rb_trap_3,

    input logic        rb_valid_4,
    input logic [31:0] rb_pc_4,
    input logic [31:0] rb_inst_4,
    input logic [6:0]  rb_idx_4,
    input logic [127:0] rb_data_4,
    input logic        rb_trap_4,

    input logic        rb_valid_5,
    input logic [31:0] rb_pc_5,
    input logic [31:0] rb_inst_5,
    input logic [6:0]  rb_idx_5,
    input logic [127:0] rb_data_5,
    input logic        rb_trap_5,

    input logic        rb_valid_6,
    input logic [31:0] rb_pc_6,
    input logic [31:0] rb_inst_6,
    input logic [6:0]  rb_idx_6,
    input logic [127:0] rb_data_6,
    input logic        rb_trap_6,

    input logic        rb_valid_7,
    input logic [31:0] rb_pc_7,
    input logic [31:0] rb_inst_7,
    input logic [6:0]  rb_idx_7,
    input logic [127:0] rb_data_7,
    input logic        rb_trap_7
);

    string trace_file;
    integer fd = 0;
    bit tracing_enabled = 0;
    longint unsigned inst_count = 0;
    longint unsigned cycle_count = 0;

    //==========================================================================
    // 1-Cycle Delay Pipeline for Retirement Signals
    //==========================================================================
    // The VRF write and retirement happen on the same posedge. The vecregfile
    // shadow (in tb_top) captures VRF state at negedge. By delaying the
    // retirement signals by 1 cycle, the tracer processes them on the next
    // posedge, when vecregfile already reflects the VRF state after the write.
    logic        rb_valid_d [8];
    logic [31:0] rb_pc_d [8];
    logic [31:0] rb_inst_d [8];
    logic [6:0]  rb_idx_d [8];
    logic [127:0] rb_data_d [8];
    logic        rb_trap_d [8];

    initial begin
        for (int i = 0; i < 8; i++) begin
            rb_valid_d[i] = 0;
        end
    end

    // Buffer retirement signals by 1 cycle
    always_ff @(posedge clk) begin
        if (!resetn) begin
            for (int i = 0; i < 8; i++) rb_valid_d[i] <= 0;
        end else begin
            rb_valid_d[0] <= rb_valid_0; rb_pc_d[0] <= rb_pc_0; rb_inst_d[0] <= rb_inst_0;
            rb_idx_d[0] <= rb_idx_0; rb_data_d[0] <= rb_data_0; rb_trap_d[0] <= rb_trap_0;
            rb_valid_d[1] <= rb_valid_1; rb_pc_d[1] <= rb_pc_1; rb_inst_d[1] <= rb_inst_1;
            rb_idx_d[1] <= rb_idx_1; rb_data_d[1] <= rb_data_1; rb_trap_d[1] <= rb_trap_1;
            rb_valid_d[2] <= rb_valid_2; rb_pc_d[2] <= rb_pc_2; rb_inst_d[2] <= rb_inst_2;
            rb_idx_d[2] <= rb_idx_2; rb_data_d[2] <= rb_data_2; rb_trap_d[2] <= rb_trap_2;
            rb_valid_d[3] <= rb_valid_3; rb_pc_d[3] <= rb_pc_3; rb_inst_d[3] <= rb_inst_3;
            rb_idx_d[3] <= rb_idx_3; rb_data_d[3] <= rb_data_3; rb_trap_d[3] <= rb_trap_3;
            rb_valid_d[4] <= rb_valid_4; rb_pc_d[4] <= rb_pc_4; rb_inst_d[4] <= rb_inst_4;
            rb_idx_d[4] <= rb_idx_4; rb_data_d[4] <= rb_data_4; rb_trap_d[4] <= rb_trap_4;
            rb_valid_d[5] <= rb_valid_5; rb_pc_d[5] <= rb_pc_5; rb_inst_d[5] <= rb_inst_5;
            rb_idx_d[5] <= rb_idx_5; rb_data_d[5] <= rb_data_5; rb_trap_d[5] <= rb_trap_5;
            rb_valid_d[6] <= rb_valid_6; rb_pc_d[6] <= rb_pc_6; rb_inst_d[6] <= rb_inst_6;
            rb_idx_d[6] <= rb_idx_6; rb_data_d[6] <= rb_data_6; rb_trap_d[6] <= rb_trap_6;
            rb_valid_d[7] <= rb_valid_7; rb_pc_d[7] <= rb_pc_7; rb_inst_d[7] <= rb_inst_7;
            rb_idx_d[7] <= rb_idx_7; rb_data_d[7] <= rb_data_7; rb_trap_d[7] <= rb_trap_7;
        end
    end

    //==========================================================================
    // Instruction Format Detection
    //==========================================================================

    // Check if instruction is compressed (16-bit)
    function automatic logic is_compressed(input logic [31:0] inst);
        return (inst[1:0] != 2'b11);
    endfunction

    // Check if instruction is a floating-point operation
    function automatic logic is_fp_instruction(input logic [31:0] inst);
        logic [6:0] opcode;
        opcode = inst[6:0];
        return (opcode == 7'b0000111) || (opcode == 7'b0100111) ||
               (opcode == 7'b1010011) || (opcode == 7'b1000011) ||
               (opcode == 7'b1000111) || (opcode == 7'b1001011) ||
               (opcode == 7'b1001111);
    endfunction

    // Check if rd is a floating-point register for this instruction
    function automatic logic rd_is_fp(input logic [31:0] inst);
        logic [6:0] opcode;
        opcode = inst[6:0];
        if (opcode == 7'b0000111) return 1;  // LOAD-FP -> FP reg
        if (opcode == 7'b1000011 || opcode == 7'b1000111 ||
            opcode == 7'b1001011 || opcode == 7'b1001111) return 1;
        if (opcode == 7'b1010011) begin
            logic [6:0] funct7;
            funct7 = inst[31:25];
            if (funct7 == 7'b1110000 || funct7 == 7'b1100000 || funct7 == 7'b1010000)
                return 0;
            return 1;
        end
        return 0;
    endfunction

    // Check if instruction is a vector operation (RVV)
    function automatic logic is_vector_instruction(input logic [31:0] inst);
        logic [6:0] opcode;
        logic [2:0] width;
        opcode = inst[6:0];
        width = inst[14:12];

        if (opcode == 7'b1010111) return 1;
        if (opcode == 7'b0000111 && (width == 3'b000 || width >= 3'b101)) return 1;
        if (opcode == 7'b0100111 && (width == 3'b000 || width >= 3'b101)) return 1;

        return 0;
    endfunction

    // Check if instruction is vsetvli/vsetivli/vsetvl (writes to integer rd)
    function automatic logic is_vset_instruction(input logic [31:0] inst);
        logic [6:0] opcode;
        logic [2:0] funct3;
        opcode = inst[6:0];
        funct3 = inst[14:12];
        return (opcode == 7'b1010111) && (funct3 == 3'b111);
    endfunction

    // Check if vector instruction writes to vector register
    function automatic logic vd_is_vector(input logic [31:0] inst);
        if (is_vset_instruction(inst)) return 0;
        return is_vector_instruction(inst);
    endfunction

    //==========================================================================
    // Register Address Extraction
    //==========================================================================

    function automatic logic [4:0] get_rs1(input logic [31:0] inst);
        return inst[19:15];
    endfunction

    function automatic logic [4:0] get_rs2(input logic [31:0] inst);
        return inst[24:20];
    endfunction

    function automatic logic [4:0] get_rd_from_inst(input logic [31:0] inst);
        return inst[11:7];
    endfunction

    function automatic logic [4:0] get_rd_compressed(input logic [15:0] inst);
        logic [1:0] op;
        op = inst[1:0];
        if (op == 2'b00) begin
            return {2'b01, inst[4:2]};
        end else begin
            return inst[11:7];
        end
    endfunction

    // Check if instruction writes to rd
    function automatic logic writes_rd(input logic [31:0] inst);
        logic [6:0] opcode;
        opcode = inst[6:0];
        if (opcode == 7'b1100011 || opcode == 7'b0100011 || opcode == 7'b0100111)
            return 0;
        return 1;
    endfunction

    // Check if instruction uses rs1
    function automatic logic uses_rs1(input logic [31:0] inst);
        logic [6:0] opcode;
        opcode = inst[6:0];
        if (opcode == 7'b0110111 || opcode == 7'b0010111 || opcode == 7'b1101111)
            return 0;
        return 1;
    endfunction

    // Check if instruction uses rs2
    function automatic logic uses_rs2(input logic [31:0] inst);
        logic [6:0] opcode;
        opcode = inst[6:0];
        if (opcode == 7'b0110011 || opcode == 7'b1100011 || opcode == 7'b0100011 ||
            opcode == 7'b0100111 || opcode == 7'b1010011 ||
            opcode == 7'b1000011 || opcode == 7'b1000111 || opcode == 7'b1001011 || opcode == 7'b1001111)
            return 1;
        return 0;
    endfunction

    //==========================================================================
    // Register Name Formatting
    //==========================================================================

    function automatic string reg_str(input logic [4:0] addr);
        if (addr < 10)
            return $sformatf(" x%0d", addr);
        else
            return $sformatf("x%0d", addr);
    endfunction

    function automatic string fp_reg_str(input logic [4:0] addr);
        if (addr < 10)
            return $sformatf(" f%0d", addr);
        else
            return $sformatf("f%0d", addr);
    endfunction

    function automatic string vec_reg_str(input logic [4:0] addr);
        if (addr < 10)
            return $sformatf(" v%0d", addr);
        else
            return $sformatf("v%0d", addr);
    endfunction

    function automatic string format_rd(input logic [31:0] inst, input logic [4:0] addr);
        if (vd_is_vector(inst))
            return vec_reg_str(addr);
        else if (rd_is_fp(inst))
            return fp_reg_str(addr);
        else
            return reg_str(addr);
    endfunction

    function automatic logic show_vector_data(input logic [31:0] inst);
        return vd_is_vector(inst);
    endfunction

    // Log a single retired instruction
    task automatic log_retired_inst(
        input logic [31:0] pc,
        input logic [31:0] inst,
        input logic [6:0]  idx,
        input logic [127:0] data,
        input logic        trap
    );
        logic [4:0] rs1_addr, rs2_addr, rd_addr, rd_from_inst;
        logic [31:0] rs1_val, rs2_val, rd_val;
        string trap_str;
        logic valid_rd_write;
        logic compressed;
        string rd_name;

        inst_count++;

        compressed = is_compressed(inst);

        if (compressed) begin
            rd_from_inst = get_rd_compressed(inst[15:0]);
            rs1_addr = rd_from_inst;
            rs2_addr = inst[6:2];
        end else begin
            rs1_addr = get_rs1(inst);
            rs2_addr = get_rs2(inst);
            rd_from_inst = get_rd_from_inst(inst);
        end

        rd_addr = idx[4:0];
        rs1_val = regfile[rs1_addr];
        rs2_val = regfile[rs2_addr];
        rd_val = data[31:0];

        trap_str = trap ? " TRAP" : "";

        valid_rd_write = writes_rd(inst) && (vd_is_vector(inst) || rd_from_inst != 0);

        if (compressed) begin
            $fwrite(fd, "%8d %8d  %08h  %04h    ", inst_count, cycle_count, pc, inst[15:0]);
        end else begin
            $fwrite(fd, "%8d %8d  %08h  %08h", inst_count, cycle_count, pc, inst);
        end

        if (valid_rd_write) begin
            rd_name = format_rd(inst, rd_from_inst);
            if (show_vector_data(inst)) begin
                // Use vecregfile (shadow VRF) for correct architectural state.
                // The rb_data from RetirementBuffer lacks byte-enable info, so tail
                // elements appear as zeros for reductions (BUG-014). The vecregfile
                // reads directly from the hardware VRF which applies byte-enable
                // correctly (tail undisturbed when VTA=0).
                $fwrite(fd, "  %s=0x%032x", rd_name, vecregfile[rd_from_inst]);
            end else begin
                $fwrite(fd, "  %s=0x%08x", rd_name, rd_val);
            end
        end else begin
            $fwrite(fd, "              ");
        end

        if (!compressed && uses_rs1(inst)) begin
            $fwrite(fd, "  %s:0x%08x", reg_str(rs1_addr), rs1_val);
        end else begin
            $fwrite(fd, "                ");
        end

        if (!compressed && uses_rs2(inst)) begin
            $fwrite(fd, "  %s:0x%08x", reg_str(rs2_addr), rs2_val);
        end

        $fwrite(fd, "%s\n", trap_str);
        $fflush(fd);
    endtask

    initial begin
        if ($value$plusargs("TRACE_FILE=%s", trace_file)) begin
            fd = $fopen(trace_file, "w");
            if (fd) begin
                tracing_enabled = 1;
                $display("[Tracer] Logging retired instructions to: %s", trace_file);
                $fwrite(fd, "# Instruction Trace Log - Coral RVV Core (Retirement)\n");
                $fwrite(fd, "# Format: order cycle pc inst [rd=value] [rs1:value] [rs2:value]\n");
                $fwrite(fd, "# Note: Shows COMMITTED instructions (not speculated)\n");
                $fwrite(fd, "# Source register values are from shadow regfile (architectural state)\n");
                $fwrite(fd, "#------------------------------------------------------------------------------\n");
                $fflush(fd);
            end else begin
                $display("[Tracer] ERROR: Could not open %s", trace_file);
            end
        end
    end

    final begin
        if (fd) begin
            $fclose(fd);
            $display("[Tracer] Trace complete: %s (%0d instructions retired)", trace_file, inst_count);
        end
    end

    // Process DELAYED retirement ports on each clock edge.
    // The 1-cycle delay ensures vecregfile has been updated (at negedge)
    // with the VRF state after the instruction's write (at posedge).
    always @(posedge clk) begin
        if (tracing_enabled && resetn) begin
            cycle_count++;

            // Process delayed retirement ports in order (0-7)
            if (rb_valid_d[0]) log_retired_inst(rb_pc_d[0], rb_inst_d[0], rb_idx_d[0], rb_data_d[0], rb_trap_d[0]);
            if (rb_valid_d[1]) log_retired_inst(rb_pc_d[1], rb_inst_d[1], rb_idx_d[1], rb_data_d[1], rb_trap_d[1]);
            if (rb_valid_d[2]) log_retired_inst(rb_pc_d[2], rb_inst_d[2], rb_idx_d[2], rb_data_d[2], rb_trap_d[2]);
            if (rb_valid_d[3]) log_retired_inst(rb_pc_d[3], rb_inst_d[3], rb_idx_d[3], rb_data_d[3], rb_trap_d[3]);
            if (rb_valid_d[4]) log_retired_inst(rb_pc_d[4], rb_inst_d[4], rb_idx_d[4], rb_data_d[4], rb_trap_d[4]);
            if (rb_valid_d[5]) log_retired_inst(rb_pc_d[5], rb_inst_d[5], rb_idx_d[5], rb_data_d[5], rb_trap_d[5]);
            if (rb_valid_d[6]) log_retired_inst(rb_pc_d[6], rb_inst_d[6], rb_idx_d[6], rb_data_d[6], rb_trap_d[6]);
            if (rb_valid_d[7]) log_retired_inst(rb_pc_d[7], rb_inst_d[7], rb_idx_d[7], rb_data_d[7], rb_trap_d[7]);
        end
    end

endmodule
