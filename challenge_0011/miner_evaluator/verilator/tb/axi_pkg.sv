//==============================================================================
// AXI Package - Common Types and Parameters
//==============================================================================
// This package defines common AXI types, parameters, and constants used
// across the verification environment.
//==============================================================================

package axi_pkg;

    //==========================================================================
    // AXI Parameters
    //==========================================================================
    parameter AXI_ADDR_WIDTH = 32;
    parameter AXI_DATA_WIDTH = 128;
    parameter AXI_ID_WIDTH   = 6;
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;  // 16 bytes

    //==========================================================================
    // AXI Response Codes
    //==========================================================================
    typedef enum logic [1:0] {
        AXI_RESP_OKAY   = 2'b00,
        AXI_RESP_EXOKAY = 2'b01,
        AXI_RESP_SLVERR = 2'b10,
        AXI_RESP_DECERR = 2'b11
    } axi_resp_t;

    //==========================================================================
    // AXI Burst Types
    //==========================================================================
    typedef enum logic [1:0] {
        AXI_BURST_FIXED = 2'b00,
        AXI_BURST_INCR  = 2'b01,
        AXI_BURST_WRAP  = 2'b10
    } axi_burst_t;

    //==========================================================================
    // AXI Size (bytes per beat)
    //==========================================================================
    typedef enum logic [2:0] {
        AXI_SIZE_1B   = 3'b000,
        AXI_SIZE_2B   = 3'b001,
        AXI_SIZE_4B   = 3'b010,
        AXI_SIZE_8B   = 3'b011,
        AXI_SIZE_16B  = 3'b100,
        AXI_SIZE_32B  = 3'b101,
        AXI_SIZE_64B  = 3'b110,
        AXI_SIZE_128B = 3'b111
    } axi_size_t;

    //==========================================================================
    // Coral NPU Memory Map
    //==========================================================================
    parameter ITCM_BASE     = 32'h0000_0000;  // Instruction TCM
    parameter ITCM_SIZE     = 32'h0001_0000;  // 64 KB

    parameter DTCM_BASE     = 32'h0001_0000;  // Data TCM
    parameter DTCM_SIZE     = 32'h0001_0000;  // 64 KB

    parameter CTRL_BASE     = 32'h0000_3000;  // Control registers
    parameter CTRL_PC       = 32'h0000_3000;  // Set PC value
    parameter CTRL_START    = 32'h0000_3008;  // Write to start core
    parameter CTRL_STATUS   = 32'h0000_300C;  // Read status

    parameter EXT_MEM_BASE  = 32'h1000_0000;  // External memory
    parameter EXT_MEM_SIZE  = 32'h0100_0000;  // 16 MB

    //==========================================================================
    // Test Result Signatures (for self-checking tests)
    //==========================================================================
    parameter SIGNATURE_PASS = 32'hCAFE_CAFE;
    parameter SIGNATURE_FAIL = 32'hDEAD_DEAD;
    parameter SIGNATURE_ADDR = 32'h0001_FF00;  // End of DTCM

endpackage
