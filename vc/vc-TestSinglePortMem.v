//========================================================================
// Verilog Components: Test Memory
//========================================================================
// This is single ported test memory that can handles almost arbitrary
// memory request messages and returns memory response messages.

`ifndef VC_TEST_SINGLE_PORT_MEM_V
`define VC_TEST_SINGLE_PORT_MEM_V

`include "vc-MemReqMsg.v"
`include "vc-MemRespMsg.v"
`include "vc-Assert.v"

//------------------------------------------------------------------------
// Single port test memory
//------------------------------------------------------------------------

module vc_TestSinglePortMem
#(
  parameter p_mem_sz  = 1024, // size of physical memory in bytes
  parameter p_addr_sz = 8,    // size of mem message address in bits
  parameter p_data_sz = 32,   // size of mem message data in bits

  // Local constants not meant to be set from outside the module
  parameter c_req_msg_sz  = `VC_MEM_REQ_MSG_SZ(p_addr_sz,p_data_sz),
  parameter c_resp_msg_sz = `VC_MEM_RESP_MSG_SZ(p_data_sz)
)(
  input clk,
  input reset,

  // Memory request interface

  input                      memreq_val,
  output                     memreq_rdy,
  input  [c_req_msg_sz-1:0]  memreq_msg,

  // Memory response interface

  output                     memresp_val,
  input                      memresp_rdy,
  output [c_resp_msg_sz-1:0] memresp_msg
);

  //----------------------------------------------------------------------
  // Local parameters
  //----------------------------------------------------------------------

  // Size of a physical address for the memory in bits

  localparam c_physical_byte_addr_sz = $clog2(p_mem_sz);

  // Size of data entry in bytes

  localparam c_data_byte_sz = (p_data_sz/8);

  // Number of data entries in memory

  localparam c_num_blocks = p_mem_sz/c_data_byte_sz;

  // Size of block address in bits

  localparam c_physical_block_addr_sz = $clog2(c_num_blocks);

  // Size of block offset in bits

  localparam c_block_offset_sz = $clog2(c_data_byte_sz);

  // Shorthand for the message types

  localparam c_read  = `VC_MEM_REQ_MSG_TYPE_READ;
  localparam c_write = `VC_MEM_REQ_MSG_TYPE_WRITE;

  // Shorthand for the message field sizes

  localparam c_req_msg_type_sz  = `VC_MEM_REQ_MSG_TYPE_SZ(p_addr_sz,p_data_sz);
  localparam c_req_msg_addr_sz  = `VC_MEM_REQ_MSG_ADDR_SZ(p_addr_sz,p_data_sz);
  localparam c_req_msg_len_sz   = `VC_MEM_REQ_MSG_LEN_SZ(p_addr_sz,p_data_sz);
  localparam c_req_msg_data_sz  = `VC_MEM_REQ_MSG_DATA_SZ(p_addr_sz,p_data_sz);

  localparam c_resp_msg_type_sz = `VC_MEM_RESP_MSG_TYPE_SZ(p_data_sz);
  localparam c_resp_msg_len_sz  = `VC_MEM_RESP_MSG_LEN_SZ(p_data_sz);
  localparam c_resp_msg_data_sz = `VC_MEM_RESP_MSG_DATA_SZ(p_data_sz);

  //----------------------------------------------------------------------
  // Unpack the request message
  //----------------------------------------------------------------------

  wire [c_req_msg_type_sz-1:0] memreq_msg_type;
  wire [c_req_msg_addr_sz-1:0] memreq_msg_addr;
  wire [c_req_msg_len_sz-1:0]  memreq_msg_len;
  wire [c_req_msg_data_sz-1:0] memreq_msg_data;

  vc_MemReqMsgFromBits#(p_addr_sz,p_data_sz) memreq_msg_from_bits
  (
    .bits (memreq_msg),
    .type (memreq_msg_type),
    .addr (memreq_msg_addr),
    .len  (memreq_msg_len),
    .data (memreq_msg_data)
  );

  //----------------------------------------------------------------------
  // Memory request buffers
  //----------------------------------------------------------------------

  reg                         memreq_val_M;
  reg [c_req_msg_type_sz-1:0] memreq_msg_type_M;
  reg [c_req_msg_addr_sz-1:0] memreq_msg_addr_M;
  reg [c_req_msg_len_sz-1:0]  memreq_msg_len_M;
  reg [c_req_msg_data_sz-1:0] memreq_msg_data_M;

  always @( posedge clk ) begin

    // Ensure that the valid bit is reset appropriately

    if ( reset ) begin
      memreq_val_M <= 1'b0;
    end else if ( memresp_rdy ) begin
      memreq_val_M <= memreq_val;
    end

    // Stall the pipeline if the response interface is not ready

    if ( memresp_rdy ) begin
      memreq_msg_type_M <= memreq_msg_type;
      memreq_msg_addr_M <= memreq_msg_addr;
      memreq_msg_len_M  <= memreq_msg_len;
      memreq_msg_data_M <= memreq_msg_data;
    end

  end

  // Create a strict pipeline such that the whole pipelipe stalls if the
  // reponse interface is not ready. We do this by disabling the write of
  // the request buffer above if the response interface is not ready, and
  // we also directly wire the response ready signal to the request ready
  // signal.

  assign memreq_rdy = memresp_rdy;

  //----------------------------------------------------------------------
  // Actual memory array
  //----------------------------------------------------------------------

  reg [p_data_sz-1:0] m[c_num_blocks-1:0];

  //----------------------------------------------------------------------
  // Handle request and create response
  //----------------------------------------------------------------------

  // Handle case where length is zero which actually represents a full
  // width access.

  wire [c_req_msg_len_sz:0] memreq_msg_len_modified_M
    = ( memreq_msg_len_M == 0 ) ? (c_req_msg_data_sz/8)
    :                             memreq_msg_len_M;

  // Caculate the physical byte address for the request. Notice that we
  // truncate the higher order bits that are beyond the size of the
  // physical memory.

  wire [c_physical_byte_addr_sz-1:0] physical_byte_addr_M
    = memreq_msg_addr_M[c_physical_byte_addr_sz-1:0];

  // Read the data. We use a behavioral for loop to allow us to flexibly
  // handle arbitrary alignment and lengths. This is a combinational
  // always block so that we can immediately readout the results.
  // We always read out the appropriate block combinationally and shift
  // according to the number of bytes we want to read from the block
  // offset to obtain the read data output.

  wire [c_physical_block_addr_sz-1:0] physical_block_addr_M
    = physical_byte_addr_M/c_data_byte_sz;

  wire [c_block_offset_sz-1:0] block_offset_M
    = physical_byte_addr_M[c_block_offset_sz-1:0];

  wire [p_data_sz-1:0] read_block_M
    = m[physical_block_addr_M];

  wire [c_resp_msg_data_sz-1:0] read_data_M
    = read_block_M >> (block_offset_M*8);

//  integer rd_i;
//  always @(*) begin
//    for ( rd_i = 0; rd_i < memreq_msg_len_modified_M; rd_i = rd_i + 1 ) begin
//      read_data_M[ (rd_i*8) +: 8 ] = read_block_M[ (block_offset_M*8) + (rd_i*8) +: 8 ];
//    end
//  end

  // Write the data if required. Again, we use a behavioral for loop to
  // allow us to flexibly handle arbitrary alignment and lengths. This is
  // a sequential always block so that the write happens on the next edge.

  wire write_en_M = memreq_val_M && ( memreq_msg_type_M == c_write );

  integer wr_i;
  always @( posedge clk ) begin
    if ( write_en_M ) begin
      for ( wr_i = 0; wr_i < memreq_msg_len_modified_M; wr_i = wr_i + 1 ) begin
        m[physical_block_addr_M][ (block_offset_M*8) + (wr_i*8) +: 8 ] <= memreq_msg_data_M[ (wr_i*8) +: 8 ];
      end
    end
  end

  // Create response

  wire [c_resp_msg_type_sz-1:0] memresp_msg_type_M = memreq_msg_type_M;
  wire [c_resp_msg_len_sz-1:0]  memresp_msg_len_M  = memreq_msg_len_M;
  wire [c_resp_msg_data_sz-1:0] memresp_msg_data_M = read_data_M;

  // Response is valid if the request in the request buffer is valid

  assign memresp_val = memreq_val_M;

  //----------------------------------------------------------------------
  // Pack the response message
  //----------------------------------------------------------------------

  vc_MemRespMsgToBits#(p_data_sz) memresp_msg_to_bits
  (
    .type (memresp_msg_type_M),
    .len  (memresp_msg_len_M),
    .data (memresp_msg_data_M),
    .bits (memresp_msg)
  );

  //----------------------------------------------------------------------
  // General assertions
  //----------------------------------------------------------------------

  // val/rdy signals should never be x's

  `VC_ASSERT_NOT_X_POSEDGE_MSG( clk, memreq_val,  "memreq_val"  );
  `VC_ASSERT_NOT_X_POSEDGE_MSG( clk, memresp_rdy, "memresp_rdy" );

endmodule

`endif /* VC_TEST_SINGLE_PORT_MEM_V */

