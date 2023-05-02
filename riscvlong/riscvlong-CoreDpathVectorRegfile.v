// //=========================================================================
// // 7-Stage RISCV Register File
// //=========================================================================

// `ifndef RISCV_CORE_DPATH_VECTORREGFILE_V
// `define RISCV_CORE_DPATH_VECTORREGFILE_V

// module riscv_CoreDpathVectorRegfile

// // WE NEED
// // (2x (for each input)):
// //      address of rf
// //      start of 4 elements to return (does it wrap around)
// //      4 outputs
// // assumptions:
// // 6 bits of address for the vectors (64-element vectors)
// (
//   input         clk,
//   input  [ 4:0] raddr0,    // Read 0 address (combinational input)
//   input  [ 5:0] ridx0,     // Read 0 address (combinational input)
//   output [31:0] rdata0_0,  // Read 0 data (combinational on raddr)
//   output [31:0] rdata0_1,  // Read 0 data (combinational on raddr)
//   output [31:0] rdata0_2,  // Read 0 data (combinational on raddr)
//   output [31:0] rdata0_3,  // Read 0 data (combinational on raddr)
//   input  [ 4:0] raddr1,    // Read 0 address (combinational input)
//   input  [ 5:0] ridx1,     // Read 0 address (combinational input)
//   output [31:0] rdata1_0,  // Read 0 data (combinational on raddr)
//   output [31:0] rdata1_1,  // Read 0 data (combinational on raddr)
//   output [31:0] rdata1_2,  // Read 0 data (combinational on raddr)
//   output [31:0] rdata1_3,  // Read 0 data (combinational on raddr)
//   input         wen_p_0,     // Write enable (sample on rising clk edge)
//   input         wen_p_1,     // Write enable (sample on rising clk edge)
//   input         wen_p_2,     // Write enable (sample on rising clk edge)
//   input         wen_p_3,     // Write enable (sample on rising clk edge)
//   input  [ 4:0] waddr_p,   // Write address (sample on rising clk edge)
//   input  [ 5:0] widx_p,    // Read 0 address (combinational input)
//   input  [31:0] wdata_p_0, // Write data (sample on rising clk edge)
//   input  [31:0] wdata_p_1, // Write data (sample on rising clk edge)
//   input  [31:0] wdata_p_2, // Write data (sample on rising clk edge)
//   input  [31:0] wdata_p_3  // Write data (sample on rising clk edge)
// );

//   // We use an array of 32 bit register for the regfile itself
//   reg [31:0] registers[31:0][63:0];

//   // Combinational read ports
//   assign rdata0_0 = registers[raddr0][ridx0];
//   assign rdata0_1 = registers[raddr0][ridx0+1];
//   assign rdata0_2 = registers[raddr0][ridx0+2];
//   assign rdata0_3 = registers[raddr0][ridx0+3];

//   assign rdata1_0 = registers[raddr1][ridx1];
//   assign rdata1_1 = registers[raddr1][ridx1+1];
//   assign rdata1_2 = registers[raddr1][ridx1+2];
//   assign rdata1_3 = registers[raddr1][ridx1+3];

//   // Write port is active only when wen is asserted
//   always @( posedge clk )
//   begin
//     if ( wen_p_0 )
//       registers[waddr_p][widx_p] <= wdata_p_0;

//     if ( wen_p_1 )
//       registers[waddr_p][widx_p+1] <= wdata_p_1;

//     if ( wen_p_2 )
//       registers[waddr_p][widx_p+2] <= wdata_p_2;

//     if ( wen_p_3s )
//       registers[waddr_p][widx_p+3] <= wdata_p_3;
      
//   end

// endmodule

// `endif


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
  input  [ 4:0] v_raddr0,    // Read 0 address (combinational input)
  input  [ 5:0] v_ridx0,     // Read 0 address (combinational input)
  output [127:0] v_rdata0,  // Read 0 data (combinational on raddr)
  input  [ 4:0] v_raddr1,    // Read 0 address (combinational input)
  input  [ 5:0] v_ridx1,     // Read 0 address (combinational input)
  output [127:0] v_rdata1,  // Read 0 data (combinational on raddr)
  input   [1:0] v_lanes,
  // input         v_wen_p_0,     // Write enable (sample on rising clk edge)
  // input         v_wen_p_1,     // Write enable (sample on rising clk edge)
  // input         v_wen_p_2,     // Write enable (sample on rising clk edge)
  input         v_wen_p,     // Write enable (sample on rising clk edge)
  input  [ 4:0] v_waddr_p,   // Write address (sample on rising clk edge)
  input  [ 5:0] v_widx_p,    // Read 0 address (combinational input)
  input  [127:0] v_wdata_p, // Write data (sample on rising clk edge)
  input v_rinter0,
  input v_rinter1,
  input v_winter
);

  // We use an array of 32 bit register for the regfile itself
  reg [31:0] registers[32:0][63:0];

  wire [5:0] a0 
    = (v_rinter0) ? 6'd32
    :             {1'd0,v_raddr0};
  
  wire [5:0] a1 
    = (v_rinter1) ? 6'd32
    :             {1'd0,v_raddr1};

  wire [5:0] wr
    = (v_winter) ? 6'd32
    :             {1'd0,v_waddr_p};

  // Combinational read ports
  assign v_rdata0[31:0] = registers[a0][v_ridx0];
  assign v_rdata0[63:32] = registers[a0][v_ridx0+5'd1];
  assign v_rdata0[95:64] = registers[a0][v_ridx0+5'd2];
  assign v_rdata0[127:96] = registers[a0][v_ridx0+5'd3];

  assign v_rdata1[31:0] = registers[a1][v_ridx1];
  assign v_rdata1[63:32] = registers[a1][v_ridx1+5'd1];
  assign v_rdata1[95:64] = registers[a1][v_ridx1+5'd2];
  assign v_rdata1[127:96] = registers[a1][v_ridx1+5'd3];

  // Write port is active only when wen is asserted
  always @( posedge clk )
  begin
    if ( v_lanes >= 0 && v_wen_p)
      registers[wr][v_widx_p] <= v_wdata_p[31:0];

    if ( v_lanes >= 1 && v_wen_p)
      registers[wr][v_widx_p+5'd1] <= v_wdata_p[63:32];

    if ( v_lanes >= 2 && v_wen_p)
      registers[wr][v_widx_p+5'd2] <= v_wdata_p[95:64];

    if ( v_lanes >= 3 && v_wen_p)
      registers[wr][v_widx_p+5'd3] <= v_wdata_p[127:96];
      
  end

endmodule

`endif

