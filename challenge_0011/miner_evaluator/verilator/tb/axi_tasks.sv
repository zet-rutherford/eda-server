//==============================================================================
// AXI Tasks Library - Reusable AXI Transaction Tasks
//==============================================================================
// This file provides tasks for AXI read/write operations.
// Include this file in your testbench and call the tasks directly.
//
// IMPORTANT: These tasks use blocking waits which require --timing in Verilator.
//
// Usage:
//   `include "axi_tasks.sv"
//
//   initial begin
//       axi_init();
//       axi_write_single(32'h00030000, 128'h0);
//       axi_write_burst(32'h0, program_data, 3);
//       axi_read_single(32'h10000000, read_data);
//   end
//==============================================================================

//==========================================================================
// AXI Signal Initialization
//==========================================================================
task automatic axi_init();
    begin
        axi_awvalid  = 0;
        axi_awaddr   = 0;
        axi_awid     = 0;
        axi_awlen    = 0;
        axi_awsize   = 3'b100;  // 16 bytes default
        axi_awburst  = 2'b01;   // INCR
        axi_awprot   = 0;
        axi_awlock   = 0;
        axi_awcache  = 0;
        axi_awqos    = 0;
        axi_awregion = 0;

        axi_wvalid   = 0;
        axi_wdata    = 0;
        axi_wstrb    = 16'hFFFF;
        axi_wlast    = 0;

        axi_bready   = 0;

        axi_arvalid  = 0;
        axi_araddr   = 0;
        axi_arid     = 0;
        axi_arlen    = 0;
        axi_arsize   = 3'b100;
        axi_arburst  = 2'b01;
        axi_arprot   = 0;
        axi_arlock   = 0;
        axi_arcache  = 0;
        axi_arqos    = 0;
        axi_arregion = 0;

        axi_rready   = 0;
    end
endtask

//==========================================================================
// Single-Beat Write Transaction
//==========================================================================
// Writes 128 bits (16 bytes) to the specified address
// Uses Verilator-compatible wait style
//==========================================================================
task automatic axi_write_single(
    input logic [31:0]  addr,
    input logic [127:0] data,
    input logic [15:0]  strb = 16'hFFFF
);
    begin
        // Start transaction
        @(posedge clk);
        axi_awvalid <= 1'b1;
        axi_awaddr  <= addr;
        axi_awlen   <= 8'h0;  // Single beat
        axi_awsize  <= 3'b100;
        axi_awburst <= 2'b01;

        axi_wvalid  <= 1'b1;
        axi_wdata   <= data;
        axi_wstrb   <= strb;
        axi_wlast   <= 1'b1;

        // Wait for address handshake
        @(posedge clk);
        while (!axi_awready) @(posedge clk);
        axi_awvalid <= 1'b0;

        // Wait for data handshake
        while (!axi_wready) @(posedge clk);
        axi_wvalid <= 1'b0;
        axi_wlast  <= 1'b0;

        // Wait for response
        axi_bready <= 1'b1;
        @(posedge clk);
        while (!axi_bvalid) @(posedge clk);
        axi_bready <= 1'b0;

        @(posedge clk);  // Extra cycle for clean-up
    end
endtask

//==========================================================================
// Multi-Beat Burst Write Transaction
//==========================================================================
// Writes multiple 128-bit beats to consecutive addresses
// data_array: Array of 128-bit values
// num_beats: Number of beats (1-256)
//==========================================================================
task automatic axi_write_burst(
    input logic [31:0]  addr,
    input logic [127:0] data_array[],
    input int           num_beats
);
    int i;
    logic addr_done;
    logic data_done;
    int beat_idx;
    begin
        if (num_beats < 1 || num_beats > 256) begin
            $display("[%0t] AXI ERROR: Invalid num_beats=%0d (must be 1-256)", $time, num_beats);
            return;
        end

        addr_done = 0;
        data_done = 0;
        beat_idx = 0;

        // Start address phase
        @(posedge clk);
        axi_awvalid <= 1'b1;
        axi_awaddr  <= addr;
        axi_awlen   <= num_beats - 1;  // AXI len is 0-based
        axi_awsize  <= 3'b100;         // 16 bytes
        axi_awburst <= 2'b01;          // INCR

        // Start first data beat
        axi_wvalid  <= 1'b1;
        axi_wdata   <= data_array[0];
        axi_wstrb   <= 16'hFFFF;
        axi_wlast   <= (num_beats == 1);

        // Process handshakes
        while (!addr_done || !data_done) begin
            @(posedge clk);

            // Handle address channel
            if (axi_awvalid && axi_awready) begin
                axi_awvalid <= 1'b0;
                addr_done = 1;
            end

            // Handle data channel
            if (axi_wvalid && axi_wready) begin
                beat_idx++;
                if (beat_idx >= num_beats) begin
                    // All beats sent
                    axi_wvalid <= 1'b0;
                    axi_wlast  <= 1'b0;
                    data_done = 1;
                end else begin
                    // Send next beat
                    axi_wdata <= data_array[beat_idx];
                    axi_wlast <= (beat_idx == num_beats - 1);
                end
            end
        end

        // Wait for response
        axi_bready <= 1'b1;
        @(posedge clk);
        while (!axi_bvalid) @(posedge clk);
        axi_bready <= 1'b0;

        @(posedge clk);  // Clean-up cycle
    end
endtask

//==========================================================================
// Single-Beat Read Transaction
//==========================================================================
// Reads 128 bits (16 bytes) from the specified address
//==========================================================================
task automatic axi_read_single(
    input  logic [31:0]  addr,
    output logic [127:0] data
);
    begin
        // Address phase
        @(posedge clk);
        axi_arvalid <= 1'b1;
        axi_araddr  <= addr;
        axi_arlen   <= 8'h0;  // Single beat
        axi_arsize  <= 3'b100;
        axi_arburst <= 2'b01;

        // Wait for address handshake
        @(posedge clk);
        while (!axi_arready) @(posedge clk);
        axi_arvalid <= 1'b0;

        // Data phase
        axi_rready <= 1'b1;
        @(posedge clk);
        while (!axi_rvalid) @(posedge clk);
        data = axi_rdata;
        axi_rready <= 1'b0;

        @(posedge clk);  // Clean-up cycle
    end
endtask

//==========================================================================
// Helper: Write 32-bit Word
//==========================================================================
// Convenience task to write a single 32-bit word (pads to 128-bit)
//==========================================================================
task automatic axi_write_word(
    input logic [31:0] addr,
    input logic [31:0] data
);
    logic [127:0] wide_data;
    logic [15:0]  strb;
    int byte_offset;
    begin
        byte_offset = addr[3:0];  // Offset within 16-byte aligned region
        wide_data = 128'h0;
        strb = 16'h0;

        // Place 32-bit word at correct position
        case (byte_offset[3:2])
            2'b00: begin wide_data[31:0]   = data; strb = 16'h000F; end
            2'b01: begin wide_data[63:32]  = data; strb = 16'h00F0; end
            2'b10: begin wide_data[95:64]  = data; strb = 16'h0F00; end
            2'b11: begin wide_data[127:96] = data; strb = 16'hF000; end
        endcase

        axi_write_single(addr & ~32'hF, wide_data, strb);
    end
endtask

//==========================================================================
// Helper: Read 32-bit Word
//==========================================================================
task automatic axi_read_word(
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [127:0] wide_data;
    int byte_offset;
    begin
        axi_read_single(addr & ~32'hF, wide_data);
        byte_offset = addr[3:0];

        case (byte_offset[3:2])
            2'b00: data = wide_data[31:0];
            2'b01: data = wide_data[63:32];
            2'b10: data = wide_data[95:64];
            2'b11: data = wide_data[127:96];
        endcase
    end
endtask

//==========================================================================
// Coral NPU Specific: Load Program to ITCM
//==========================================================================
// Loads instruction data to ITCM starting at address 0
// program_data: Array of 32-bit instructions
// num_instr: Number of instructions to load
//==========================================================================
task automatic coral_load_program(
    input logic [31:0] program_data[],
    input int          num_instr
);
    logic [127:0] burst_data[];
    int num_beats;
    int i, j;
    begin
        // Pack 32-bit instructions into 128-bit beats (4 instructions per beat)
        num_beats = (num_instr + 3) / 4;
        burst_data = new[num_beats];

        for (i = 0; i < num_beats; i++) begin
            burst_data[i] = 128'h0;
            for (j = 0; j < 4; j++) begin
                if (i*4 + j < num_instr) begin
                    burst_data[i][j*32 +: 32] = program_data[i*4 + j];
                end else begin
                    burst_data[i][j*32 +: 32] = 32'h0000_0013;  // NOP
                end
            end
        end

        $display("[%0t] Loading %0d instructions (%0d beats) to ITCM", $time, num_instr, num_beats);
        axi_write_burst(32'h0000_0000, burst_data, num_beats);
        $display("[%0t] Program loaded", $time);
    end
endtask

//==========================================================================
// Coral NPU Specific: Set PC and Start Execution
//==========================================================================
task automatic coral_start(
    input logic [31:0] start_pc = 32'h0
);
    begin
        // Set PC (register at 0x00003000)
        $display("[%0t] Setting PC to 0x%08h", $time, start_pc);
        axi_write_single(32'h0000_3000, {96'h0, start_pc});

        // Start core (register at 0x00003008)
        $display("[%0t] Starting core execution", $time);
        axi_write_single(32'h0000_3008, {96'h0, 32'h1});
    end
endtask

//==========================================================================
// Coral NPU Specific: Wait for Completion (cycle-based)
//==========================================================================
// Waits for specified number of cycles
// Returns cycle count when done
//==========================================================================
task automatic coral_wait_cycles(
    input  int max_cycles,
    output int cycles_waited
);
    begin
        cycles_waited = 0;
        repeat (max_cycles) begin
            @(posedge clk);
            cycles_waited++;
        end
    end
endtask

//==========================================================================
// Coral NPU Specific: Check Test Signature
//==========================================================================
// Reads the signature location and checks for PASS/FAIL
// This task reads from DTCM via AXI slave
// Returns: 0 = PASS, 1 = FAIL, 2 = UNKNOWN
//==========================================================================
task automatic coral_check_signature(
    output int result,
    output logic [31:0] signature
);
    begin
        // Read signature from DTCM (0x0001FF00)
        // Note: This requires AXI slave read path to DTCM
        // For now, use register file shadow for verification
        result = 2;  // UNKNOWN - need AXI read path
        signature = 32'h0;
        $display("[%0t] Signature check: Using register verification instead", $time);
    end
endtask
