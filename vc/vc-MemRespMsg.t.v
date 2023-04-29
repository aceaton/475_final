//========================================================================
// Unit Tests: Memory Response Message
//========================================================================

`include "vc-MemRespMsg.v"
`include "vc-Test.v"

module tester;
  `VC_TEST_SUITE_BEGIN( "vc-MemRespMsg" )

  //----------------------------------------------------------------------
  // Local parameters
  //----------------------------------------------------------------------

  localparam c_read  = `VC_MEM_RESP_MSG_TYPE_READ;
  localparam c_write = `VC_MEM_RESP_MSG_TYPE_WRITE;

  //----------------------------------------------------------------------
  // TestFullStr_data32
  //----------------------------------------------------------------------

  reg [`VC_MEM_RESP_MSG_SZ(32)-1:0] t1_msg_test;
  reg [`VC_MEM_RESP_MSG_SZ(32)-1:0] t1_msg_ref;

  vc_MemRespMsgToStr#(32) t1_mem_resp_msg_to_str( t1_msg_test );

  task t1_do_test
  (
    input [`VC_MEM_RESP_MSG_TYPE_SZ(32)-1:0] type,
    input [`VC_MEM_RESP_MSG_LEN_SZ(32)-1:0]  len,
    input [`VC_MEM_RESP_MSG_DATA_SZ(32)-1:0] data
  );
  begin

    // Create a wire and set msg fields using `defines

    t1_msg_test[`VC_MEM_RESP_MSG_TYPE_FIELD(32)] = type;
    t1_msg_test[`VC_MEM_RESP_MSG_LEN_FIELD(32)]  = len;
    t1_msg_test[`VC_MEM_RESP_MSG_DATA_FIELD(32)] = data;

    // Create a wire and set msg fields using concatentation

    t1_msg_ref = { type, len, data };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( t1_mem_resp_msg_to_str.full_str, t1_msg_test, t1_msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 1, "TestFullStr_data32" )
  begin

    // Create read messages

    t1_do_test( c_read,  2'd1, 32'h0a0b0c0d );
    t1_do_test( c_read,  2'd2, 32'h0b0c0d0e );
    t1_do_test( c_read,  2'd0, 32'h0c0d0e0f );

    // Create write messages

    t1_do_test( c_write, 2'dx, 32'hxxxxxxxx );
    t1_do_test( c_write, 2'dx, 32'hxxxxxxxx );
    t1_do_test( c_write, 2'dx, 32'hxxxxxxxx );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // TestTinyStr_data32
  //----------------------------------------------------------------------

  reg [`VC_MEM_RESP_MSG_SZ(32)-1:0] t2_msg_test;
  reg [`VC_MEM_RESP_MSG_SZ(32)-1:0] t2_msg_ref;

  vc_MemRespMsgToStr#(32) t2_mem_resp_msg_to_str( t2_msg_test );

  task t2_do_test
  (
    input [`VC_MEM_RESP_MSG_TYPE_SZ(32)-1:0] type,
    input [`VC_MEM_RESP_MSG_LEN_SZ(32)-1:0]  len,
    input [`VC_MEM_RESP_MSG_DATA_SZ(32)-1:0] data
  );
  begin

    // Create a wire and set msg fields using `defines

    t2_msg_test[`VC_MEM_RESP_MSG_TYPE_FIELD(32)] = type;
    t2_msg_test[`VC_MEM_RESP_MSG_LEN_FIELD(32)]  = len;
    t2_msg_test[`VC_MEM_RESP_MSG_DATA_FIELD(32)] = data;

    // Create a wire and set msg fields using concatentation

    t2_msg_ref = { type, len, data };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( t2_mem_resp_msg_to_str.tiny_str, t2_msg_test, t2_msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 2, "TestTinyStr_data32" )
  begin

    // Create read messages

    t2_do_test( c_read,  2'd1, 32'h0a0b0c0d );
    t2_do_test( c_read,  2'd2, 32'h0b0c0d0e );
    t2_do_test( c_read,  2'd0, 32'h0c0d0e0f );

    // Create write messages

    t2_do_test( c_write, 2'dx, 32'hxxxxxxxx );
    t2_do_test( c_write, 2'dx, 32'hxxxxxxxx );
    t2_do_test( c_write, 2'dx, 32'hxxxxxxxx );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // TestFullStr_data64
  //----------------------------------------------------------------------

  reg [`VC_MEM_RESP_MSG_SZ(64)-1:0] t3_msg_test;
  reg [`VC_MEM_RESP_MSG_SZ(64)-1:0] t3_msg_ref;

  vc_MemRespMsgToStr#(64) t3_mem_resp_msg_to_str( t3_msg_test );

  task t3_do_test
  (
    input [`VC_MEM_RESP_MSG_TYPE_SZ(64)-1:0] type,
    input [`VC_MEM_RESP_MSG_LEN_SZ(64)-1:0]  len,
    input [`VC_MEM_RESP_MSG_DATA_SZ(64)-1:0] data
  );
  begin

    // Create a wire and set msg fields using `defines

    t3_msg_test[`VC_MEM_RESP_MSG_TYPE_FIELD(64)] = type;
    t3_msg_test[`VC_MEM_RESP_MSG_LEN_FIELD(64)]  = len;
    t3_msg_test[`VC_MEM_RESP_MSG_DATA_FIELD(64)] = data;

    // Create a wire and set msg fields using concatentation

    t3_msg_ref = { type, len, data };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( t3_mem_resp_msg_to_str.full_str, t3_msg_test, t3_msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 3, "TestFullStr_data64" )
  begin

    // Create read messages

    t3_do_test( c_read,  2'd1, 64'h_0a0b0c0d_0a0b0c0d );
    t3_do_test( c_read,  2'd2, 64'h_0b0c0d0e_0b0c0d0e );
    t3_do_test( c_read,  2'd0, 64'h_0c0d0e0f_0c0d0e0f );

    // Create write messages

    t3_do_test( c_write, 2'dx, 64'h_xxxxxxxx_xxxxxxxx );
    t3_do_test( c_write, 2'dx, 64'h_xxxxxxxx_xxxxxxxx );
    t3_do_test( c_write, 2'dx, 64'h_xxxxxxxx_xxxxxxxx );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 3 )
endmodule

