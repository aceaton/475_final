//=========================================================================
// 7-Stage RISCV Register File
//=========================================================================

`ifndef RISCV_CORE_DPATH_VECTORREGFILE_V
`define RISCV_CORE_DPATH_VECTORREGFILE_V

module riscv_CoreDpathVectorRegfile

// WE NEED
// (2x (for each input)):
//      address of rf
//      start of 4 elements to return (does it wrap around)
//      4 outputs
// assumptions:
// 6 bits of address for the vectors (64-element vectors)
(
  input         clk,
  input  [ 4:0] raddr0,    // Read 0 address (combinational input)
  input  [ 5:0] ridx0,     // Read 0 address (combinational input)
  output [31:0] rdata0_0,  // Read 0 data (combinational on raddr)
  output [31:0] rdata0_1,  // Read 0 data (combinational on raddr)
  output [31:0] rdata0_2,  // Read 0 data (combinational on raddr)
  output [31:0] rdata0_3,  // Read 0 data (combinational on raddr)
  input  [ 4:0] raddr1,    // Read 0 address (combinational input)
  input  [ 5:0] ridx1,     // Read 0 address (combinational input)
  output [31:0] rdata1_0,  // Read 0 data (combinational on raddr)
  output [31:0] rdata1_1,  // Read 0 data (combinational on raddr)
  output [31:0] rdata1_2,  // Read 0 data (combinational on raddr)
  output [31:0] rdata1_3,  // Read 0 data (combinational on raddr)
  input         wen_p_0,     // Write enable (sample on rising clk edge)
  input         wen_p_1,     // Write enable (sample on rising clk edge)
  input         wen_p_2,     // Write enable (sample on rising clk edge)
  input         wen_p_3,     // Write enable (sample on rising clk edge)
  input  [ 4:0] waddr_p,   // Write address (sample on rising clk edge)
  input  [ 5:0] widx_p,    // Read 0 address (combinational input)
  input  [31:0] wdata_p_0, // Write data (sample on rising clk edge)
  input  [31:0] wdata_p_1, // Write data (sample on rising clk edge)
  input  [31:0] wdata_p_2, // Write data (sample on rising clk edge)
  input  [31:0] wdata_p_3  // Write data (sample on rising clk edge)
);

  // We use an array of 32 bit register for the regfile itself
  reg [31:0] registers[31:0][63:0];

  // Combinational read ports
  assign rdata0_0 = registers[raddr0][ridx0];
  assign rdata0_1 = registers[raddr0][ridx0+1];
  assign rdata0_2 = registers[raddr0][ridx0+2];
  assign rdata0_3 = registers[raddr0][ridx0+3];

  assign rdata1_0 = registers[raddr1][ridx1];
  assign rdata1_1 = registers[raddr1][ridx1+1];
  assign rdata1_2 = registers[raddr1][ridx1+2];
  assign rdata1_3 = registers[raddr1][ridx1+3];

  // Write port is active only when wen is asserted
  always @( posedge clk )
  begin
    if ( wen_p_0 )
      registers[waddr_p][widx_p] <= wdata_p_0;

    if ( wen_p_1 )
      registers[waddr_p][widx_p+1] <= wdata_p_1;

    if ( wen_p_2 )
      registers[waddr_p][widx_p+2] <= wdata_p_2;

    if ( wen_p_3s )
      registers[waddr_p][widx_p+3] <= wdata_p_3;
      
  end

endmodule

`endif

