//========================================================================
// imuldiv-DivReqMsg Unit Tests
//========================================================================

`include "imuldiv-DivReqMsg.v"
`include "vc-Test.v"

module tester;
  `VC_TEST_SUITE_BEGIN( "imuldiv-DivReqMsg" )

  //----------------------------------------------------------------------
  // Local parameters
  //----------------------------------------------------------------------

  localparam fn_signed   = `IMULDIV_DIVREQ_MSG_FUNC_SIGNED;
  localparam fn_unsigned = `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED;

  //----------------------------------------------------------------------
  // LcdMsgToString helper module
  //----------------------------------------------------------------------

  reg [`IMULDIV_DIVREQ_MSG_SZ-1:0] msg_test;
  reg [`IMULDIV_DIVREQ_MSG_SZ-1:0] msg_ref;

  imuldiv_DivReqMsgToStr divreq_msg_to_str( msg_test );

  //----------------------------------------------------------------------
  // TestBasicFullStr
  //----------------------------------------------------------------------

  // Helper tasks

  task t1_do_test
  (
    input [`IMULDIV_DIVREQ_MSG_FUNC_SZ-1:0] func,
    input [`IMULDIV_DIVREQ_MSG_A_SZ-1:0]    a,
    input [`IMULDIV_DIVREQ_MSG_B_SZ-1:0]    b
  );
  begin

    // Create a wire and set msg fields using `defines

    msg_test[`IMULDIV_DIVREQ_MSG_FUNC_FIELD] = func;
    msg_test[`IMULDIV_DIVREQ_MSG_A_FIELD]    = a;
    msg_test[`IMULDIV_DIVREQ_MSG_B_FIELD]    = b;

    // Create a wire and set msg fields using concatentation

    msg_ref = { func, a, b };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( divreq_msg_to_str.full_str, msg_test, msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 1, "TestBasicFullStr" )
  begin

    // Create signed messages

    t1_do_test( fn_signed,  32'd00, 32'd01 );
    t1_do_test( fn_signed,  32'd42, 32'd01 );
    t1_do_test( fn_signed,  32'd18, 32'd68 );

    // Create unsigned messages

    t1_do_test( fn_unsigned, 32'd00, 32'd01 );
    t1_do_test( fn_unsigned, 32'd42, 32'd01 );
    t1_do_test( fn_unsigned, 32'd18, 32'd68 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // TestBasicFullStr
  //----------------------------------------------------------------------

  // Helper tasks

  task t2_do_test
  (
    input [`IMULDIV_DIVREQ_MSG_FUNC_SZ-1:0] func,
    input [`IMULDIV_DIVREQ_MSG_A_SZ-1:0]    a,
    input [`IMULDIV_DIVREQ_MSG_B_SZ-1:0]    b
  );
  begin

    // Create a wire and set msg fields using `defines

    msg_test[`IMULDIV_DIVREQ_MSG_FUNC_FIELD] = func;
    msg_test[`IMULDIV_DIVREQ_MSG_A_FIELD]    = a;
    msg_test[`IMULDIV_DIVREQ_MSG_B_FIELD]    = b;

    // Create a wire and set msg fields using concatentation

    msg_ref = { func, a, b };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( divreq_msg_to_str.tiny_str, msg_test, msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 2, "TestBasicTinyStr" )
  begin

    // Create signed messages

    t1_do_test( fn_signed,  32'd00, 32'd01 );
    t1_do_test( fn_signed,  32'd42, 32'd01 );
    t1_do_test( fn_signed,  32'd18, 32'd68 );

    // Create unsigned messages

    t1_do_test( fn_unsigned, 32'd00, 32'd01 );
    t1_do_test( fn_unsigned, 32'd42, 32'd01 );
    t1_do_test( fn_unsigned, 32'd18, 32'd68 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 2 )
endmodule

