//==============================================================================
// AXI Slave Memory - Simple AXI4 Memory Model
//==============================================================================
// This module acts as an AXI slave (external memory)
// Responds to read/write requests from the CoreMiniAxi master interface
//==============================================================================

module axi_slave_memory #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 128,
    parameter ID_WIDTH   = 6,
    parameter STRB_WIDTH = DATA_WIDTH/8,
    parameter MEM_SIZE   = 16*1024*1024,  // 16MB
    parameter BASE_ADDR  = 32'h10000000   // Base address offset
)(
    input  logic clk,
    input  logic resetn,

    // AXI Write Address Channel
    input  logic                    awvalid,
    output logic                    awready,
    input  logic [ADDR_WIDTH-1:0]   awaddr,
    input  logic [2:0]              awprot,
    input  logic [ID_WIDTH-1:0]     awid,
    input  logic [7:0]              awlen,
    input  logic [2:0]              awsize,
    input  logic [1:0]              awburst,
    input  logic                    awlock,
    input  logic [3:0]              awcache,
    input  logic [3:0]              awqos,
    input  logic [3:0]              awregion,

    // AXI Write Data Channel
    input  logic                    wvalid,
    output logic                    wready,
    input  logic [DATA_WIDTH-1:0]   wdata,
    input  logic                    wlast,
    input  logic [STRB_WIDTH-1:0]   wstrb,

    // AXI Write Response Channel
    output logic                    bvalid,
    input  logic                    bready,
    output logic [ID_WIDTH-1:0]     bid,
    output logic [1:0]              bresp,

    // AXI Read Address Channel
    input  logic                    arvalid,
    output logic                    arready,
    input  logic [ADDR_WIDTH-1:0]   araddr,
    input  logic [2:0]              arprot,
    input  logic [ID_WIDTH-1:0]     arid,
    input  logic [7:0]              arlen,
    input  logic [2:0]              arsize,
    input  logic [1:0]              arburst,
    input  logic                    arlock,
    input  logic [3:0]              arcache,
    input  logic [3:0]              arqos,
    input  logic [3:0]              arregion,

    // AXI Read Data Channel
    output logic                    rvalid,
    input  logic                    rready,
    output logic [DATA_WIDTH-1:0]   rdata,
    output logic [ID_WIDTH-1:0]     rid,
    output logic [1:0]              rresp,
    output logic                    rlast
);

    //==========================================================================
    // Memory Storage (byte-addressable)
    //==========================================================================
    logic [7:0] memory [0:MEM_SIZE-1];

    //==========================================================================
    // Internal State
    //==========================================================================
    logic [ADDR_WIDTH-1:0] write_addr_reg;
    logic [ID_WIDTH-1:0]   write_id_reg;
    logic [ADDR_WIDTH-1:0] read_addr_reg;
    logic [ID_WIDTH-1:0]   read_id_reg;

    // Current write address/ID (handles same-cycle awvalid+wvalid)
    wire [ADDR_WIDTH-1:0] current_write_addr = (awvalid && awready) ? awaddr : write_addr_reg;
    wire [ID_WIDTH-1:0]   current_write_id   = (awvalid && awready) ? awid : write_id_reg;

    // Aligned addresses (byte lanes are relative to aligned address for wide bus)
    wire [ADDR_WIDTH-1:0] aligned_write_addr = current_write_addr & ~(STRB_WIDTH - 1);
    wire [ADDR_WIDTH-1:0] aligned_read_addr  = araddr & ~(STRB_WIDTH - 1);

    // Memory array indices (subtract base address)
    wire [ADDR_WIDTH-1:0] write_idx = aligned_write_addr - BASE_ADDR;
    wire [ADDR_WIDTH-1:0] read_idx  = aligned_read_addr - BASE_ADDR;

    //==========================================================================
    // Write Address Channel - Always ready
    //==========================================================================
    assign awready = 1'b1;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            write_addr_reg <= 0;
            write_id_reg   <= 0;
        end else begin
            if (awvalid && awready) begin
                write_addr_reg <= awaddr;
                write_id_reg   <= awid;
                $display("[%0t] MEM: Write address captured: 0x%08h", $time, awaddr);
            end
        end
    end

    //==========================================================================
    // Write Data Channel - Always ready, writes to memory
    //==========================================================================
    assign wready = 1'b1;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            // Initialize memory to zero
            for (int i = 0; i < MEM_SIZE; i++) begin
                memory[i] <= 8'h00;
            end
        end else begin
            if (wvalid && wready) begin
                // Write data to memory based on strobe (wstrb lanes relative to aligned address)
                for (int i = 0; i < STRB_WIDTH; i++) begin
                    if (wstrb[i] && (write_idx + i) < MEM_SIZE) begin
                        memory[write_idx + i] <= wdata[i*8 +: 8];
                        $display("[%0t] MEM:   Writing memory[0x%08h] = 0x%02h (addr=0x%08h)",
                                 $time, write_idx + i, wdata[i*8 +: 8], aligned_write_addr + i);
                    end
                end
                $display("[%0t] MEM: Write data: addr=0x%08h (aligned=0x%08h, idx=0x%08h), data=0x%032h, wstrb=0x%04h",
                         $time, current_write_addr, aligned_write_addr, write_idx, wdata, wstrb);
            end
        end
    end

    //==========================================================================
    // Write Response Channel - Send response after write data
    //==========================================================================
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            bvalid <= 1'b0;
            bid    <= 0;
            bresp  <= 2'b00;  // OKAY
        end else begin
            if (wvalid && wready && wlast) begin
                bvalid <= 1'b1;
                bid    <= current_write_id;
                bresp  <= 2'b00;  // OKAY
            end else if (bvalid && bready) begin
                bvalid <= 1'b0;
            end
        end
    end

    //==========================================================================
    // Read Address Channel - Always ready
    //==========================================================================
    assign arready = 1'b1;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            read_addr_reg <= 0;
            read_id_reg   <= 0;
        end else begin
            if (arvalid && arready) begin
                read_addr_reg <= araddr;
                read_id_reg   <= arid;
                $display("[%0t] MEM: Read address captured: 0x%08h", $time, araddr);
            end
        end
    end

    //==========================================================================
    // Read Data Channel - Send data on next cycle
    //==========================================================================
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            rvalid <= 1'b0;
            rdata  <= 0;
            rid    <= 0;
            rresp  <= 2'b00;
            rlast  <= 1'b0;
        end else begin
            if (arvalid && arready) begin
                // Read data from memory (128 bits / 16 bytes)
                // Read from memory array using index
                for (int i = 0; i < STRB_WIDTH; i++) begin
                    if ((read_idx + i) < MEM_SIZE) begin
                        rdata[i*8 +: 8] <= memory[read_idx + i];
                    end else begin
                        rdata[i*8 +: 8] <= 8'h00;
                    end
                end
                rvalid <= 1'b1;
                rid    <= arid;
                rresp  <= 2'b00;  // OKAY
                rlast  <= 1'b1;
                $display("[%0t] MEM: Read data: addr=0x%08h (aligned=0x%08h, idx=0x%08h), data=0x%032h",
                         $time, araddr, aligned_read_addr, read_idx, rdata);
            end else if (rvalid && rready) begin
                rvalid <= 1'b0;
                rlast  <= 1'b0;
            end
        end
    end

    //==========================================================================
    // Debug: Monitor specific memory locations
    //==========================================================================
    initial begin
        $display("AXI Slave Memory initialized: %0d MB", MEM_SIZE/(1024*1024));
    end

    // Task to dump memory contents at specific address
    task dump_memory(
        input logic [ADDR_WIDTH-1:0] addr,
        input int num_bytes
    );
        begin
            $display("[%0t] Memory dump at 0x%08h:", $time, addr);
            for (int i = 0; i < num_bytes; i += 16) begin
                $write("  0x%08h: ", addr + i);
                for (int j = 0; j < 16 && (i+j) < num_bytes; j++) begin
                    $write("%02h ", memory[addr + i + j]);
                end
                $write("\n");
            end
        end
    endtask

endmodule
