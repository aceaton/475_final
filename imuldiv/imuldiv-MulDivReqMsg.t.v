//========================================================================
// imuldiv-MulDivReqMsg Unit Tests
//========================================================================

`include "imuldiv-MulDivReqMsg.v"
`include "vc-Test.v"

module tester;
  `VC_TEST_SUITE_BEGIN( "imuldiv-MulDivReqMsg" )

  //----------------------------------------------------------------------
  // Local parameters
  //----------------------------------------------------------------------

  localparam mul  = `IMULDIV_MULDIVREQ_MSG_FUNC_MUL;
  localparam div  = `IMULDIV_MULDIVREQ_MSG_FUNC_DIV;
  localparam divu = `IMULDIV_MULDIVREQ_MSG_FUNC_DIVU;
  localparam rem  = `IMULDIV_MULDIVREQ_MSG_FUNC_REM;
  localparam remu = `IMULDIV_MULDIVREQ_MSG_FUNC_REMU;

  //----------------------------------------------------------------------
  // LcdMsgToString helper module
  //----------------------------------------------------------------------

  reg [`IMULDIV_MULDIVREQ_MSG_SZ-1:0] msg_test;
  reg [`IMULDIV_MULDIVREQ_MSG_SZ-1:0] msg_ref;

  imuldiv_MulDivReqMsgToStr muldivreq_msg_to_str( msg_test );

  //----------------------------------------------------------------------
  // TestBasicFullStr
  //----------------------------------------------------------------------

  // Helper tasks

  task t1_do_test
  (
    input [`IMULDIV_MULDIVREQ_MSG_FUNC_SZ-1:0] func,
    input [`IMULDIV_MULDIVREQ_MSG_A_SZ-1:0]    a,
    input [`IMULDIV_MULDIVREQ_MSG_B_SZ-1:0]    b
  );
  begin

    // Create a wire and set msg fields using `defines

    msg_test[`IMULDIV_MULDIVREQ_MSG_FUNC_FIELD] = func;
    msg_test[`IMULDIV_MULDIVREQ_MSG_A_FIELD]    = a;
    msg_test[`IMULDIV_MULDIVREQ_MSG_B_FIELD]    = b;

    // Create a wire and set msg fields using concatentation

    msg_ref = { func, a, b };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( muldivreq_msg_to_str.full_str, msg_test, msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 1, "TestBasicFullStr" )
  begin

    // Create mul messages

    t1_do_test( mul,  32'd00, 32'd01 );
    t1_do_test( mul,  32'd42, 32'd01 );
    t1_do_test( mul,  32'd18, 32'd68 );

    // Create div messages

    t1_do_test( div,  32'd00, 32'd01 );
    t1_do_test( div,  32'd42, 32'd01 );
    t1_do_test( div,  32'd18, 32'd68 );

    // Create divu messages

    t1_do_test( divu, 32'd00, 32'd01 );
    t1_do_test( divu, 32'd42, 32'd01 );
    t1_do_test( divu, 32'd18, 32'd68 );

    // Create rem messages

    t1_do_test( rem,  32'd00, 32'd01 );
    t1_do_test( rem,  32'd42, 32'd01 );
    t1_do_test( rem,  32'd18, 32'd68 );

    // Create remu messages

    t1_do_test( remu, 32'd00, 32'd01 );
    t1_do_test( remu, 32'd42, 32'd01 );
    t1_do_test( remu, 32'd18, 32'd68 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // TestBasicFullStr
  //----------------------------------------------------------------------

  // Helper tasks

  task t2_do_test
  (
    input [`IMULDIV_MULDIVREQ_MSG_FUNC_SZ-1:0] func,
    input [`IMULDIV_MULDIVREQ_MSG_A_SZ-1:0]    a,
    input [`IMULDIV_MULDIVREQ_MSG_B_SZ-1:0]    b
  );
  begin

    // Create a wire and set msg fields using `defines

    msg_test[`IMULDIV_MULDIVREQ_MSG_FUNC_FIELD] = func;
    msg_test[`IMULDIV_MULDIVREQ_MSG_A_FIELD]    = a;
    msg_test[`IMULDIV_MULDIVREQ_MSG_B_FIELD]    = b;

    // Create a wire and set msg fields using concatentation

    msg_ref = { func, a, b };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( muldivreq_msg_to_str.tiny_str, msg_test, msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 2, "TestBasicTinyStr" )
  begin

    // Create mul messages

    t2_do_test( mul,  32'd00, 32'd01 );
    t2_do_test( mul,  32'd42, 32'd01 );
    t2_do_test( mul,  32'd18, 32'd68 );

    // Create div messages

    t2_do_test( div,  32'd00, 32'd01 );
    t2_do_test( div,  32'd42, 32'd01 );
    t2_do_test( div,  32'd18, 32'd68 );

    // Create divu messages

    t2_do_test( divu, 32'd00, 32'd01 );
    t2_do_test( divu, 32'd42, 32'd01 );
    t2_do_test( divu, 32'd18, 32'd68 );

    // Create rem messages

    t2_do_test( rem,  32'd00, 32'd01 );
    t2_do_test( rem,  32'd42, 32'd01 );
    t2_do_test( rem,  32'd18, 32'd68 );

    // Create remu messages

    t2_do_test( remu, 32'd00, 32'd01 );
    t2_do_test( remu, 32'd42, 32'd01 );
    t2_do_test( remu, 32'd18, 32'd68 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 2 )
endmodule

