//==============================================================================
// Coral NPU Top-Level Testbench
//==============================================================================
// Clean, consolidated testbench using AXI tasks library.
//
// Test Result Convention:
//   a0 (x10) = -1 (0xFFFFFFFF) -> FAIL
//   a0 (x10) = 0 or positive  -> PASS
//
// Usage:
//   make                           # Run with default embedded test
//   make TEST=tests/build/foo.mem  # Run with external test from .mem file
//   make RVV=1 TEST=...            # Run with RVV + Verification core
//
// Core Selection:
//   Define USE_RVV_VERIFICATION to use RvvCoreMiniVerificationAxi
//   Otherwise uses CoreMiniAxi (scalar only)
//==============================================================================

`timescale 1ns/1ps

module tb_top;

    //==========================================================================
    // Test Program Configuration
    //==========================================================================
    // Set via runtime plusargs: +TEST_FILE=path/to/test.mem
    string PROGRAM_FILE;

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;   // 100 MHz
    parameter MAX_CYCLES = 50000; // Default timeout (can be overridden by +TIMEOUT=N)

    // Runtime configurable timeout
    int timeout_cycles = MAX_CYCLES;

    //==========================================================================
    // Clock and Reset
    //==========================================================================
    logic clk = 0;
    logic resetn = 0;
    integer cycle_count = 0;

    always #(CLK_PERIOD/2) clk = ~clk;
    always @(posedge clk) cycle_count <= cycle_count + 1;

    //==========================================================================
    // AXI Slave Interface (Testbench -> DUT for programming)
    //==========================================================================
    logic        axi_awvalid, axi_awready;
    logic [31:0] axi_awaddr;
    logic [2:0]  axi_awprot;
    logic [5:0]  axi_awid;
    logic [7:0]  axi_awlen;
    logic [2:0]  axi_awsize;
    logic [1:0]  axi_awburst;
    logic        axi_awlock;
    logic [3:0]  axi_awcache, axi_awqos, axi_awregion;

    logic         axi_wvalid, axi_wready;
    logic [127:0] axi_wdata;
    logic         axi_wlast;
    logic [15:0]  axi_wstrb;

    logic       axi_bvalid, axi_bready;
    logic [5:0] axi_bid;
    logic [1:0] axi_bresp;

    logic        axi_arvalid, axi_arready;
    logic [31:0] axi_araddr;
    logic [2:0]  axi_arprot;
    logic [5:0]  axi_arid;
    logic [7:0]  axi_arlen;
    logic [2:0]  axi_arsize;
    logic [1:0]  axi_arburst;
    logic        axi_arlock;
    logic [3:0]  axi_arcache, axi_arqos, axi_arregion;

    logic         axi_rvalid, axi_rready;
    logic [127:0] axi_rdata;
    logic [5:0]   axi_rid;
    logic [1:0]   axi_rresp;
    logic         axi_rlast;

    //==========================================================================
    // AXI Master Interface (DUT -> External Memory)
    //==========================================================================
    logic        m_awvalid, m_awready;
    logic [31:0] m_awaddr;
    logic [2:0]  m_awprot;
    logic [5:0]  m_awid;
    logic [7:0]  m_awlen;
    logic [2:0]  m_awsize;
    logic [1:0]  m_awburst;
    logic        m_awlock;
    logic [3:0]  m_awcache, m_awqos, m_awregion;

    logic         m_wvalid, m_wready;
    logic [127:0] m_wdata;
    logic         m_wlast;
    logic [15:0]  m_wstrb;

    logic       m_bvalid, m_bready;
    logic [5:0] m_bid;
    logic [1:0] m_bresp;

    logic        m_arvalid, m_arready;
    logic [31:0] m_araddr;
    logic [2:0]  m_arprot;
    logic [5:0]  m_arid;
    logic [7:0]  m_arlen;
    logic [2:0]  m_arsize;
    logic [1:0]  m_arburst;
    logic        m_arlock;
    logic [3:0]  m_arcache, m_arqos, m_arregion;

    logic         m_rvalid, m_rready;
    logic [127:0] m_rdata;
    logic [5:0]   m_rid;
    logic [1:0]   m_rresp;
    logic         m_rlast;

    //==========================================================================
    // Debug Signals from DUT
    //==========================================================================
    logic        debug_rf_wr0_valid, debug_rf_wr1_valid, debug_rf_wr2_valid;
    logic        debug_rf_wr3_valid, debug_rf_wr4_valid, debug_rf_wr5_valid;
    logic [4:0]  debug_rf_wr0_addr, debug_rf_wr1_addr, debug_rf_wr2_addr;
    logic [4:0]  debug_rf_wr3_addr, debug_rf_wr4_addr, debug_rf_wr5_addr;
    logic [31:0] debug_rf_wr0_data, debug_rf_wr1_data, debug_rf_wr2_data;
    logic [31:0] debug_rf_wr3_data, debug_rf_wr4_data, debug_rf_wr5_data;

    // Shadow register file for verification
    logic [31:0] regfile [0:31];

    // Shadow vector register file for verification (fixes WAW tracer bug)
    logic [127:0] vecregfile [0:31];

    // Core status signals
    logic core_halted, core_fault, core_wfi;

    // tohost monitoring (for RISC-V tests convention)
    logic [127:0] tohost_data;
    logic [31:0] tohost_value;
    logic tohost_detected;

`ifdef USE_RVV_VERIFICATION
    // Additional debug signals for tracing
    logic [3:0] debug_en;
    logic [31:0] debug_addr[4];
    logic [31:0] debug_inst[4];
    logic [31:0] debug_cycles;
`endif

`ifdef USE_RVV_VERIFICATION
    //==========================================================================
    // Dispatch Debug Signals (speculated - NOT for Spike comparison)
    //==========================================================================
    logic        disp_fire[4];
    logic [31:0] disp_pc[4], disp_inst[4];

    //==========================================================================
    // Retirement Buffer Debug Signals (committed - USE for Spike comparison)
    //==========================================================================
    // 8 retirement ports for retired/committed instructions
    logic        rb_valid[8];
    logic [31:0] rb_pc[8];
    logic [31:0] rb_inst[8];
    logic [6:0]  rb_idx[8];      // Destination register (7-bit for vector regs)
    logic [127:0] rb_data[8];    // Writeback data (128-bit for vector)
    logic        rb_trap[8];     // Trap occurred
`endif

    //==========================================================================
    // Include AXI Tasks
    //==========================================================================
    `include "axi_tasks.sv"

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
`ifdef USE_RVV_VERIFICATION
    RvvCoreMiniVerificationAxi dut (
`else
    CoreMiniAxi dut (
`endif
        .io_aclk(clk),
        .io_aresetn(resetn),

        // AXI Slave (programming interface)
        .io_axi_slave_write_addr_ready(axi_awready),
        .io_axi_slave_write_addr_valid(axi_awvalid),
        .io_axi_slave_write_addr_bits_addr(axi_awaddr),
        .io_axi_slave_write_addr_bits_prot(axi_awprot),
        .io_axi_slave_write_addr_bits_id(axi_awid),
        .io_axi_slave_write_addr_bits_len(axi_awlen),
        .io_axi_slave_write_addr_bits_size(axi_awsize),
        .io_axi_slave_write_addr_bits_burst(axi_awburst),
        .io_axi_slave_write_addr_bits_lock(axi_awlock),
        .io_axi_slave_write_addr_bits_cache(axi_awcache),
        .io_axi_slave_write_addr_bits_qos(axi_awqos),
        .io_axi_slave_write_addr_bits_region(axi_awregion),

        .io_axi_slave_write_data_ready(axi_wready),
        .io_axi_slave_write_data_valid(axi_wvalid),
        .io_axi_slave_write_data_bits_data(axi_wdata),
        .io_axi_slave_write_data_bits_last(axi_wlast),
        .io_axi_slave_write_data_bits_strb(axi_wstrb),

        .io_axi_slave_write_resp_ready(axi_bready),
        .io_axi_slave_write_resp_valid(axi_bvalid),
        .io_axi_slave_write_resp_bits_id(axi_bid),
        .io_axi_slave_write_resp_bits_resp(axi_bresp),

        .io_axi_slave_read_addr_ready(axi_arready),
        .io_axi_slave_read_addr_valid(axi_arvalid),
        .io_axi_slave_read_addr_bits_addr(axi_araddr),
        .io_axi_slave_read_addr_bits_prot(axi_arprot),
        .io_axi_slave_read_addr_bits_id(axi_arid),
        .io_axi_slave_read_addr_bits_len(axi_arlen),
        .io_axi_slave_read_addr_bits_size(axi_arsize),
        .io_axi_slave_read_addr_bits_burst(axi_arburst),
        .io_axi_slave_read_addr_bits_lock(axi_arlock),
        .io_axi_slave_read_addr_bits_cache(axi_arcache),
        .io_axi_slave_read_addr_bits_qos(axi_arqos),
        .io_axi_slave_read_addr_bits_region(axi_arregion),

        .io_axi_slave_read_data_ready(axi_rready),
        .io_axi_slave_read_data_valid(axi_rvalid),
        .io_axi_slave_read_data_bits_data(axi_rdata),
        .io_axi_slave_read_data_bits_id(axi_rid),
        .io_axi_slave_read_data_bits_resp(axi_rresp),
        .io_axi_slave_read_data_bits_last(axi_rlast),

        // AXI Master (external memory)
        .io_axi_master_write_addr_ready(m_awready),
        .io_axi_master_write_addr_valid(m_awvalid),
        .io_axi_master_write_addr_bits_addr(m_awaddr),
        .io_axi_master_write_addr_bits_prot(m_awprot),
        .io_axi_master_write_addr_bits_id(m_awid),
        .io_axi_master_write_addr_bits_len(m_awlen),
        .io_axi_master_write_addr_bits_size(m_awsize),
        .io_axi_master_write_addr_bits_burst(m_awburst),
        .io_axi_master_write_addr_bits_lock(m_awlock),
        .io_axi_master_write_addr_bits_cache(m_awcache),
        .io_axi_master_write_addr_bits_qos(m_awqos),
        .io_axi_master_write_addr_bits_region(m_awregion),

        .io_axi_master_write_data_ready(m_wready),
        .io_axi_master_write_data_valid(m_wvalid),
        .io_axi_master_write_data_bits_data(m_wdata),
        .io_axi_master_write_data_bits_last(m_wlast),
        .io_axi_master_write_data_bits_strb(m_wstrb),

        .io_axi_master_write_resp_ready(m_bready),
        .io_axi_master_write_resp_valid(m_bvalid),
        .io_axi_master_write_resp_bits_id(m_bid),
        .io_axi_master_write_resp_bits_resp(m_bresp),

        .io_axi_master_read_addr_ready(m_arready),
        .io_axi_master_read_addr_valid(m_arvalid),
        .io_axi_master_read_addr_bits_addr(m_araddr),
        .io_axi_master_read_addr_bits_prot(m_arprot),
        .io_axi_master_read_addr_bits_id(m_arid),
        .io_axi_master_read_addr_bits_len(m_arlen),
        .io_axi_master_read_addr_bits_size(m_arsize),
        .io_axi_master_read_addr_bits_burst(m_arburst),
        .io_axi_master_read_addr_bits_lock(m_arlock),
        .io_axi_master_read_addr_bits_cache(m_arcache),
        .io_axi_master_read_addr_bits_qos(m_arqos),
        .io_axi_master_read_addr_bits_region(m_arregion),

        .io_axi_master_read_data_ready(m_rready),
        .io_axi_master_read_data_valid(m_rvalid),
        .io_axi_master_read_data_bits_data(m_rdata),
        .io_axi_master_read_data_bits_id(m_rid),
        .io_axi_master_read_data_bits_resp(m_rresp),
        .io_axi_master_read_data_bits_last(m_rlast),

        // Debug
        .io_debug_regfile_writeData_0_valid(debug_rf_wr0_valid),
        .io_debug_regfile_writeData_0_bits_addr(debug_rf_wr0_addr),
        .io_debug_regfile_writeData_0_bits_data(debug_rf_wr0_data),
        .io_debug_regfile_writeData_1_valid(debug_rf_wr1_valid),
        .io_debug_regfile_writeData_1_bits_addr(debug_rf_wr1_addr),
        .io_debug_regfile_writeData_1_bits_data(debug_rf_wr1_data),
        .io_debug_regfile_writeData_2_valid(debug_rf_wr2_valid),
        .io_debug_regfile_writeData_2_bits_addr(debug_rf_wr2_addr),
        .io_debug_regfile_writeData_2_bits_data(debug_rf_wr2_data),
        .io_debug_regfile_writeData_3_valid(debug_rf_wr3_valid),
        .io_debug_regfile_writeData_3_bits_addr(debug_rf_wr3_addr),
        .io_debug_regfile_writeData_3_bits_data(debug_rf_wr3_data),
        .io_debug_regfile_writeData_4_valid(debug_rf_wr4_valid),
        .io_debug_regfile_writeData_4_bits_addr(debug_rf_wr4_addr),
        .io_debug_regfile_writeData_4_bits_data(debug_rf_wr4_data),
        .io_debug_regfile_writeData_5_valid(debug_rf_wr5_valid),
        .io_debug_regfile_writeData_5_bits_addr(debug_rf_wr5_addr),
        .io_debug_regfile_writeData_5_bits_data(debug_rf_wr5_data),

`ifdef USE_RVV_VERIFICATION
        // Dispatch debug outputs (for instruction tracing)
        .io_debug_dispatch_0_instFire(disp_fire[0]),
        .io_debug_dispatch_0_instAddr(disp_pc[0]),
        .io_debug_dispatch_0_instInst(disp_inst[0]),
        .io_debug_dispatch_1_instFire(disp_fire[1]),
        .io_debug_dispatch_1_instAddr(disp_pc[1]),
        .io_debug_dispatch_1_instInst(disp_inst[1]),
        .io_debug_dispatch_2_instFire(disp_fire[2]),
        .io_debug_dispatch_2_instAddr(disp_pc[2]),
        .io_debug_dispatch_2_instInst(disp_inst[2]),
        .io_debug_dispatch_3_instFire(disp_fire[3]),
        .io_debug_dispatch_3_instAddr(disp_pc[3]),
        .io_debug_dispatch_3_instInst(disp_inst[3]),
        // Additional debug outputs
        .io_debug_en(debug_en),
        .io_debug_addr_0(debug_addr[0]),
        .io_debug_addr_1(debug_addr[1]),
        .io_debug_addr_2(debug_addr[2]),
        .io_debug_addr_3(debug_addr[3]),
        .io_debug_inst_0(debug_inst[0]),
        .io_debug_inst_1(debug_inst[1]),
        .io_debug_inst_2(debug_inst[2]),
        .io_debug_inst_3(debug_inst[3]),
        .io_debug_cycles(debug_cycles),

        // Retirement buffer outputs (committed instructions - for Spike comparison)
        .io_debug_rb_inst_0_valid(rb_valid[0]),
        .io_debug_rb_inst_0_bits_pc(rb_pc[0]),
        .io_debug_rb_inst_0_bits_inst(rb_inst[0]),
        .io_debug_rb_inst_0_bits_idx(rb_idx[0]),
        .io_debug_rb_inst_0_bits_data(rb_data[0]),
        .io_debug_rb_inst_0_bits_trap(rb_trap[0]),
        .io_debug_rb_inst_1_valid(rb_valid[1]),
        .io_debug_rb_inst_1_bits_pc(rb_pc[1]),
        .io_debug_rb_inst_1_bits_inst(rb_inst[1]),
        .io_debug_rb_inst_1_bits_idx(rb_idx[1]),
        .io_debug_rb_inst_1_bits_data(rb_data[1]),
        .io_debug_rb_inst_1_bits_trap(rb_trap[1]),
        .io_debug_rb_inst_2_valid(rb_valid[2]),
        .io_debug_rb_inst_2_bits_pc(rb_pc[2]),
        .io_debug_rb_inst_2_bits_inst(rb_inst[2]),
        .io_debug_rb_inst_2_bits_idx(rb_idx[2]),
        .io_debug_rb_inst_2_bits_data(rb_data[2]),
        .io_debug_rb_inst_2_bits_trap(rb_trap[2]),
        .io_debug_rb_inst_3_valid(rb_valid[3]),
        .io_debug_rb_inst_3_bits_pc(rb_pc[3]),
        .io_debug_rb_inst_3_bits_inst(rb_inst[3]),
        .io_debug_rb_inst_3_bits_idx(rb_idx[3]),
        .io_debug_rb_inst_3_bits_data(rb_data[3]),
        .io_debug_rb_inst_3_bits_trap(rb_trap[3]),
        .io_debug_rb_inst_4_valid(rb_valid[4]),
        .io_debug_rb_inst_4_bits_pc(rb_pc[4]),
        .io_debug_rb_inst_4_bits_inst(rb_inst[4]),
        .io_debug_rb_inst_4_bits_idx(rb_idx[4]),
        .io_debug_rb_inst_4_bits_data(rb_data[4]),
        .io_debug_rb_inst_4_bits_trap(rb_trap[4]),
        .io_debug_rb_inst_5_valid(rb_valid[5]),
        .io_debug_rb_inst_5_bits_pc(rb_pc[5]),
        .io_debug_rb_inst_5_bits_inst(rb_inst[5]),
        .io_debug_rb_inst_5_bits_idx(rb_idx[5]),
        .io_debug_rb_inst_5_bits_data(rb_data[5]),
        .io_debug_rb_inst_5_bits_trap(rb_trap[5]),
        .io_debug_rb_inst_6_valid(rb_valid[6]),
        .io_debug_rb_inst_6_bits_pc(rb_pc[6]),
        .io_debug_rb_inst_6_bits_inst(rb_inst[6]),
        .io_debug_rb_inst_6_bits_idx(rb_idx[6]),
        .io_debug_rb_inst_6_bits_data(rb_data[6]),
        .io_debug_rb_inst_6_bits_trap(rb_trap[6]),
        .io_debug_rb_inst_7_valid(rb_valid[7]),
        .io_debug_rb_inst_7_bits_pc(rb_pc[7]),
        .io_debug_rb_inst_7_bits_inst(rb_inst[7]),
        .io_debug_rb_inst_7_bits_idx(rb_idx[7]),
        .io_debug_rb_inst_7_bits_data(rb_data[7]),
        .io_debug_rb_inst_7_bits_trap(rb_trap[7]),
`endif

        // Core status
        .io_halted(core_halted),
        .io_fault(core_fault),
        .io_wfi(core_wfi),

        .io_irq(1'b0),
        .io_te(1'b0)  // Normal mode: core reset/cg controlled by CSR (allows program loading before core starts)
    );

    //==========================================================================
    // External Memory Model
    //==========================================================================
    axi_slave_memory #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(128),
        .ID_WIDTH(6),
        .MEM_SIZE(16*1024*1024)
    ) ext_mem (
        .clk(clk),
        .resetn(resetn),
        .awvalid(m_awvalid), .awready(m_awready), .awaddr(m_awaddr),
        .awprot(m_awprot), .awid(m_awid), .awlen(m_awlen),
        .awsize(m_awsize), .awburst(m_awburst), .awlock(m_awlock),
        .awcache(m_awcache), .awqos(m_awqos), .awregion(m_awregion),
        .wvalid(m_wvalid), .wready(m_wready), .wdata(m_wdata),
        .wlast(m_wlast), .wstrb(m_wstrb),
        .bvalid(m_bvalid), .bready(m_bready), .bid(m_bid), .bresp(m_bresp),
        .arvalid(m_arvalid), .arready(m_arready), .araddr(m_araddr),
        .arprot(m_arprot), .arid(m_arid), .arlen(m_arlen),
        .arsize(m_arsize), .arburst(m_arburst), .arlock(m_arlock),
        .arcache(m_arcache), .arqos(m_arqos), .arregion(m_arregion),
        .rvalid(m_rvalid), .rready(m_rready), .rdata(m_rdata),
        .rid(m_rid), .rresp(m_rresp), .rlast(m_rlast)
    );

`ifdef USE_RVV_VERIFICATION
    //==========================================================================
    // Instruction Tracer (logs RETIRED/COMMITTED instructions)
    //==========================================================================
    // Uses retirement buffer signals for accurate tracing of committed instructions
    // Source register values are looked up from the shadow regfile
    retirement_tracer tracer (
        .clk(clk),
        .resetn(resetn),
        .regfile(regfile),      // Shadow regfile for source register value lookups
        .vecregfile(vecregfile), // Shadow vector regfile for correct vector values (WAW fix)
        // Retirement buffer port 0
        .rb_valid_0(rb_valid[0]), .rb_pc_0(rb_pc[0]), .rb_inst_0(rb_inst[0]),
        .rb_idx_0(rb_idx[0]), .rb_data_0(rb_data[0]), .rb_trap_0(rb_trap[0]),
        // Retirement buffer port 1
        .rb_valid_1(rb_valid[1]), .rb_pc_1(rb_pc[1]), .rb_inst_1(rb_inst[1]),
        .rb_idx_1(rb_idx[1]), .rb_data_1(rb_data[1]), .rb_trap_1(rb_trap[1]),
        // Retirement buffer port 2
        .rb_valid_2(rb_valid[2]), .rb_pc_2(rb_pc[2]), .rb_inst_2(rb_inst[2]),
        .rb_idx_2(rb_idx[2]), .rb_data_2(rb_data[2]), .rb_trap_2(rb_trap[2]),
        // Retirement buffer port 3
        .rb_valid_3(rb_valid[3]), .rb_pc_3(rb_pc[3]), .rb_inst_3(rb_inst[3]),
        .rb_idx_3(rb_idx[3]), .rb_data_3(rb_data[3]), .rb_trap_3(rb_trap[3]),
        // Retirement buffer port 4
        .rb_valid_4(rb_valid[4]), .rb_pc_4(rb_pc[4]), .rb_inst_4(rb_inst[4]),
        .rb_idx_4(rb_idx[4]), .rb_data_4(rb_data[4]), .rb_trap_4(rb_trap[4]),
        // Retirement buffer port 5
        .rb_valid_5(rb_valid[5]), .rb_pc_5(rb_pc[5]), .rb_inst_5(rb_inst[5]),
        .rb_idx_5(rb_idx[5]), .rb_data_5(rb_data[5]), .rb_trap_5(rb_trap[5]),
        // Retirement buffer port 6
        .rb_valid_6(rb_valid[6]), .rb_pc_6(rb_pc[6]), .rb_inst_6(rb_inst[6]),
        .rb_idx_6(rb_idx[6]), .rb_data_6(rb_data[6]), .rb_trap_6(rb_trap[6]),
        // Retirement buffer port 7
        .rb_valid_7(rb_valid[7]), .rb_pc_7(rb_pc[7]), .rb_inst_7(rb_inst[7]),
        .rb_idx_7(rb_idx[7]), .rb_data_7(rb_data[7]), .rb_trap_7(rb_trap[7])
    );
`endif

    //==========================================================================
    // Register File Monitor
    //==========================================================================
    always_ff @(posedge clk) begin
        if (!resetn) begin
            for (int i = 0; i < 32; i++) regfile[i] <= 32'h0;
        end else begin
            if (debug_rf_wr0_valid && debug_rf_wr0_addr != 0) begin
                regfile[debug_rf_wr0_addr] <= debug_rf_wr0_data;
            end
            if (debug_rf_wr1_valid && debug_rf_wr1_addr != 0) begin
                regfile[debug_rf_wr1_addr] <= debug_rf_wr1_data;
            end
            if (debug_rf_wr2_valid && debug_rf_wr2_addr != 0) begin
                regfile[debug_rf_wr2_addr] <= debug_rf_wr2_data;
            end
            if (debug_rf_wr3_valid && debug_rf_wr3_addr != 0) begin
                regfile[debug_rf_wr3_addr] <= debug_rf_wr3_data;
            end
            if (debug_rf_wr4_valid && debug_rf_wr4_addr != 0) begin
                regfile[debug_rf_wr4_addr] <= debug_rf_wr4_data;
            end
            if (debug_rf_wr5_valid && debug_rf_wr5_addr != 0) begin
                regfile[debug_rf_wr5_addr] <= debug_rf_wr5_data;
            end
        end
    end

`ifdef USE_RVV_VERIFICATION
    //==========================================================================
    // Vector Register File Shadow (disabled - not needed for this challenge)
    //==========================================================================
    always_ff @(negedge clk) begin
        if (!resetn) begin
            for (int i = 0; i < 32; i++) vecregfile[i] <= 128'h0;
        end
    end
`endif

    //==========================================================================
    // Debug: Monitor dispatch and writeback activity
    //==========================================================================
    integer disp_count = 0;
    integer wb_count = 0;
    always @(posedge clk) begin
        if (resetn) begin
`ifdef USE_RVV_VERIFICATION
            if (disp_fire[0]) begin
                disp_count++;
                if (disp_count <= 20) $display("[%0t] DISPATCH[0]: PC=%08h INST=%08h", $time, disp_pc[0], disp_inst[0]);
            end
            if (disp_fire[1]) begin
                disp_count++;
                if (disp_count <= 20) $display("[%0t] DISPATCH[1]: PC=%08h INST=%08h", $time, disp_pc[1], disp_inst[1]);
            end
`endif
            if (debug_rf_wr0_valid) begin
                wb_count++;
                if (wb_count <= 20) $display("[%0t] WRITEBACK[0]: x%0d = %08h", $time, debug_rf_wr0_addr, debug_rf_wr0_data);
            end
            if (debug_rf_wr1_valid) begin
                wb_count++;
                if (wb_count <= 20) $display("[%0t] WRITEBACK[1]: x%0d = %08h", $time, debug_rf_wr1_addr, debug_rf_wr1_data);
            end
        end
    end

    //==========================================================================
    // Main Test Sequence
    //==========================================================================
    // Default test program (can be replaced by loading from .mem file)
    //
    // Test: DTCM + External Memory operations
    //   addi x5, x0, 100      # x5 = 100
    //   lui  x6, 0x10         # x6 = 0x10000 (DTCM)
    //   sw   x5, 0(x6)        # Store to DTCM
    //   lw   x7, 0(x6)        # Load from DTCM
    //   addi x8, x0, 50       # x8 = 50
    //   add  x9, x7, x8       # x9 = 150
    //   lui  x12, 0x10000     # x12 = 0x10000000 (ext mem)
    //   sw   x9, 0(x12)       # Store to ext mem
    //   lw   x10, 0(x12)      # Load from ext mem (a0 = result)
    //   sub  x11, x10, x5     # x11 = 50
    //   # Self-check: a0 should be 0x96 (150), which is positive = PASS
    //   wfi

    logic [127:0] prog_beat0, prog_beat1, prog_beat2;
    logic [31:0] test_result;
    logic [31:0] program_mem [0:16383];  // Up to 64KB / 4 = 16K words
    integer num_words;
    integer fd;
    integer i;
    integer last_wb_count;  // For stall detection

    // Task to load memory from .mem file
    task automatic load_mem_section(
        input string filename,
        input logic [31:0] base_addr,
        input string section_name
    );
        integer word_count;
        integer file_handle;
        string line;
        logic [31:0] addr;
        logic [127:0] beat;
        begin
            // Check if file exists by trying to open it
            file_handle = $fopen(filename, "r");
            if (file_handle == 0) begin
                // File doesn't exist - not an error for optional sections
                return;
            end

            $display("[%0t] Loading %s from: %s", $time, section_name, filename);

            // Count lines in the file
            word_count = 0;
            while (!$feof(file_handle)) begin
                if ($fgets(line, file_handle))
                    word_count = word_count + 1;
            end
            $fclose(file_handle);

            if (word_count == 0) return;

            // Read hex file into memory array
            $readmemh(filename, program_mem);
            $display("[%0t]   Read %0d words (%0d bytes)", $time, word_count, word_count * 4);

            // Write via AXI (4 words = 16 bytes per beat)
            addr = base_addr;
            for (i = 0; i < word_count; i = i + 4) begin
                // Pack 4 words into 128-bit beat
                // For DTCM data: reverse byte order within 128-bit beat to match
                // Google's RTL TCM128 byte ordering (read path reverses bytes)
                if (section_name == "data") begin
                    // For DTCM: words go to correct positions, no transformation needed
                    // The TCM128 byte reversal cancels out in SRAM_1 read path
                    beat[31:0]   = (i   < word_count) ? program_mem[i]   : 32'h0;
                    beat[63:32]  = (i+1 < word_count) ? program_mem[i+1] : 32'h0;
                    beat[95:64]  = (i+2 < word_count) ? program_mem[i+2] : 32'h0;
                    beat[127:96] = (i+3 < word_count) ? program_mem[i+3] : 32'h0;
                    $display("[%0t]   DTCM write to 0x%08h: %08h %08h %08h %08h",
                             $time, addr, beat[31:0], beat[63:32], beat[95:64], beat[127:96]);
                end else begin
                    // Code section: normal order
                    beat[31:0]   = (i   < word_count) ? program_mem[i]   : 32'h0;
                    beat[63:32]  = (i+1 < word_count) ? program_mem[i+1] : 32'h0;
                    beat[95:64]  = (i+2 < word_count) ? program_mem[i+2] : 32'h0;
                    beat[127:96] = (i+3 < word_count) ? program_mem[i+3] : 32'h0;
                    // Debug: Print first few ITCM writes
                    if (i < 16) begin
                        $display("[%0t]   ITCM write to 0x%08h: %08h %08h %08h %08h",
                                 $time, addr, beat[31:0], beat[63:32], beat[95:64], beat[127:96]);
                    end
                end
                axi_write_single(addr, beat);
                addr = addr + 16;
            end
            $display("[%0t]   Loaded to 0x%08h", $time, base_addr);
        end
    endtask

    // Task to load program from .mem file (and optionally .data.mem)
    task automatic load_program_from_file(input string filename);
        string data_filename;
        integer len;
        begin
            // Load code to ITCM (0x0000_0000)
            load_mem_section(filename, 32'h0000_0000, "code");

            // Try to load data section to DTCM (0x0001_0000)
            // Data file is same name with .data.mem instead of .mem
            len = filename.len();
            if (len > 4 && filename.substr(len-4, len-1) == ".mem") begin
                data_filename = {filename.substr(0, len-5), ".data.mem"};
                load_mem_section(data_filename, 32'h0001_0000, "data");
            end
        end
    endtask

    initial begin
        // Parse runtime plusargs for test file
        if (!$value$plusargs("TEST_FILE=%s", PROGRAM_FILE)) begin
            PROGRAM_FILE = "";  // Use embedded test if not specified
        end

        // Parse runtime plusargs for timeout
        if (!$value$plusargs("TIMEOUT=%d", timeout_cycles)) begin
            timeout_cycles = MAX_CYCLES;  // Use default if not specified
        end

        $display("===========================================================");
        $display(" Coral NPU Testbench");
        $display("===========================================================");
        if (PROGRAM_FILE != "") begin
            $display(" Test: %s", PROGRAM_FILE);
        end else begin
            $display(" Test: embedded");
        end

        // Initialize memory to X
        for (i = 0; i < 16384; i = i + 1) program_mem[i] = 32'hxxxxxxxx;

        // Default embedded test program
        prog_beat0 = {32'h00032383, 32'h00532023, 32'h00010337, 32'h06400293};
        prog_beat1 = {32'h00962023, 32'h10000637, 32'h008384b3, 32'h03200413};
        prog_beat2 = {32'h00000013, 32'h10500073, 32'h405505b3, 32'h00062503};

        // Initialize
        axi_init();

        // Reset sequence
        $display("[%0t] Applying reset...", $time);
        repeat(10) @(posedge clk);
        resetn <= 1'b1;
        $display("[%0t] Reset released", $time);
        repeat(5) @(posedge clk);

        // Load program (from file or use embedded)
        if (PROGRAM_FILE != "") begin
            load_program_from_file(PROGRAM_FILE);
        end else begin
            $display("[%0t] Loading embedded test program to ITCM...", $time);
            axi_write_single(32'h0000_0000, prog_beat0);
            axi_write_single(32'h0000_0010, prog_beat1);
            axi_write_single(32'h0000_0020, prog_beat2);
        end

        // DEBUG: Verify memory content by reading it back via AXI
        begin
            logic [127:0] readback_data;
            $display("[%0t] DEBUG: Reading back ITCM via AXI (BEFORE execution)...", $time);
            axi_read_single(32'h0000_0000, readback_data);
            $display("[%0t]   ITCM[0x00000] = %032h", $time, readback_data);
            axi_read_single(32'h0000_0010, readback_data);
            $display("[%0t]   ITCM[0x00010] = %032h", $time, readback_data);
        end

        // Set PC and start
        // CSR is at 0x30000:
        //   0x30000: resetReg[31:0] (bit 0=reset, bit 1=clock gate) + pcStartReg[63:32]
        //   0x30008: statusReg (read-only)
        $display("[%0t] Starting execution (PC=0)...", $time);

        // DEBUG: Read CSR before write to see initial value
        begin
            logic [127:0] csr_readback;
            axi_read_single(32'h0003_0000, csr_readback);
            $display("[%0t] DEBUG CSR BEFORE: resetReg=0x%08h (reset=%b, cg=%b)",
                     $time, csr_readback[31:0], csr_readback[0], csr_readback[1]);
        end

        // Follow Google's cocotb sequence exactly:
        // Step 1: Release clock gate first (keep reset asserted)
        // resetReg[0]=reset, resetReg[1]=cg
        // Value 0x1 = reset=1, cg=0 (clock running, reset held)
        $display("[%0t] Step 1: Release clock gate (reset still asserted)...", $time);
        axi_write_single(32'h0003_0000, 128'h1);
        repeat(5) @(posedge clk);  // Let clock stabilize

        // Step 2: Release reset
        // Value 0x0 = reset=0, cg=0 (clock running, reset released)
        $display("[%0t] Step 2: Release reset...", $time);
        axi_write_single(32'h0003_0000, 128'h0);

        // DEBUG: Read CSR after write to verify
        begin
            logic [127:0] csr_readback;
            axi_read_single(32'h0003_0000, csr_readback);
            $display("[%0t] DEBUG CSR AFTER:  resetReg=0x%08h (reset=%b, cg=%b)",
                     $time, csr_readback[31:0], csr_readback[0], csr_readback[1]);
            if (csr_readback[1]) begin
                $display("[%0t] WARNING: Clock gate still enabled! Core may not run.", $time);
            end
        end

        // Monitor core status at start
        @(posedge clk);
        $display("[%0t] Core status: halted=%b fault=%b wfi=%b", $time, core_halted, core_fault, core_wfi);
`ifdef USE_RVV_VERIFICATION
        $display("[%0t] Debug signals: en=%04b cycles=%0d addr[0]=%08h inst[0]=%08h",
                 $time, debug_en, debug_cycles, debug_addr[0], debug_inst[0]);
`endif

        // Wait for completion (with early exit on WFI or tohost write)
        // tohost at program address 0x10000 = AXI address 0x0001_0000
        tohost_detected = 0;
        last_wb_count = 0;  // Initialize for stall detection

        for (int cycle = 0; cycle < timeout_cycles; cycle++) begin
            @(posedge clk);
            if (core_wfi) begin
                $display("[%0t] Core entered WFI after %0d cycles", $time, cycle);
                break;
            end

            // Check tohost every 1000 cycles (after initial startup)
            if (cycle > 1000 && cycle % 1000 == 0) begin
                axi_read_single(32'h0001_0000, tohost_data);
                tohost_value = tohost_data[31:0];
                if (tohost_value != 0) begin
                    $display("[%0t] tohost detected: 0x%08h after %0d cycles", $time, tohost_value, cycle);
                    tohost_detected = 1;
                    // In RISC-V test convention: tohost=1 means PASS, tohost>1 means FAIL
                    if (tohost_value == 1) begin
                        $display("[%0t] tohost=1: TEST PASSED (riscv-tests convention)", $time);
                    end else begin
                        $display("[%0t] tohost=%0d: TEST FAILED - test #%0d failed", $time, tohost_value, tohost_value >> 1);
                    end
                    break;
                end
            end

            // Print status every 100 cycles for first 500 cycles
            if (cycle < 500 && cycle % 100 == 0) begin
`ifdef USE_RVV_VERIFICATION
                $display("[%0t] Cycle %0d: halted=%b fault=%b wfi=%b disp=%0d wb=%0d en=%04b cycles=%0d",
                         $time, cycle, core_halted, core_fault, core_wfi, disp_count, wb_count, debug_en, debug_cycles);
`else
                $display("[%0t] Cycle %0d: halted=%b fault=%b wfi=%b disp=%0d wb=%0d",
                         $time, cycle, core_halted, core_fault, core_wfi, disp_count, wb_count);
`endif
            end

`ifdef USE_RVV_VERIFICATION
            // Trace ALL vector instruction dispatch to RVV core
            // Detect stall: no writebacks for 100 cycles means we're stuck
            if (cycle > 100 && cycle % 100 == 0) begin
                if (wb_count == last_wb_count && !core_wfi && !core_halted) begin
                    $display("");
                    $display("!!! STALL DETECTED at cycle %0d !!!", cycle);
                    $display("  disp_count=%0d  wb_count=%0d (no change)", disp_count, wb_count);
                    $display("  Last dispatched PCs: disp_pc[0]=0x%08h disp_pc[1]=0x%08h", disp_pc[0], disp_pc[1]);
                end
                last_wb_count = wb_count;
            end
`endif
        end

        // Check result: a0 (x10) determines PASS/FAIL
        test_result = regfile[10];

        // DEBUG: Read back DTCM after execution to see stored debug values
        if (PROGRAM_FILE != "") begin
            logic [127:0] readback_data;
            $display("[%0t] DEBUG: Reading back DTCM via AXI (AFTER execution)...", $time);
            axi_read_single(32'h0001_0100, readback_data);
            $display("[%0t]   DTCM[0x10100] = %032h (lw result stored here)", $time, readback_data);
        end

        $display("");
        $display("===========================================================");
        $display(" Core Status: halted=%b fault=%b wfi=%b", core_halted, core_fault, core_wfi);
        $display(" Debug Stats: dispatch_count=%0d  writeback_count=%0d", disp_count, wb_count);
        $display(" Test Result: a0 (x10) = 0x%08h (%0d)", test_result, $signed(test_result));
        if (tohost_detected)
            $display(" tohost: 0x%08h", tohost_value);
        $display("===========================================================");

        // Determine pass/fail using both mechanisms
        if (tohost_detected) begin
            // RISC-V tests convention: tohost=1 means PASS
            if (tohost_value == 1) begin
                $display(" STATUS: PASS (tohost=1)");
            end else begin
                $display(" STATUS: *** FAIL *** (tohost=%0d, test #%0d failed)", tohost_value, tohost_value >> 1);
            end
        end else if ($signed(test_result) == -1) begin
            $display(" STATUS: *** FAIL ***");
            // Show which test failed (stored in a1/x11 by our test env)
            $display(" Failed test number: %0d (from a1/x11)", regfile[11]);
        end else begin
            $display(" STATUS: PASS");
        end

        $display("===========================================================");
        $display("");

        $finish;
    end

    //==========================================================================
    // Waveform Dump
    //==========================================================================
    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(1, tb_top);
    end

    //==========================================================================
    // Timeout
    //==========================================================================
    initial begin
        #5000000;  // 5000us = enough for 50000+ cycles at 100MHz
        $display("ERROR: Global timeout!");
        $finish;
    end

endmodule
