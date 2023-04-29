//========================================================================
// Test for Div Unit
//========================================================================

`include "imuldiv-DivReqMsg.v"
`include "imuldiv-IntDivIterative.v"
`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-Test.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module imuldiv_IntDivIterative_helper
(
  input       clk,
  input       reset,
  output      done
);

  wire [64:0] src_msg;
  wire        src_msg_fn;
  wire [31:0] src_msg_a;
  wire [31:0] src_msg_b;
  wire        src_val;
  wire        src_rdy;
  wire        src_done;

  wire [63:0] sink_msg;
  wire        sink_val;
  wire        sink_rdy;
  wire        sink_done;

  assign done = src_done && sink_done;

  vc_TestRandDelaySource#(65,1024,3) src
  (
    .clk   (clk),
    .reset (reset),
    .msg   (src_msg),
    .val   (src_val),
    .rdy   (src_rdy),
    .done  (src_done)
  );

  imuldiv_DivReqMsgFromBits msgfrombits
  (
    .bits (src_msg),
    .func (src_msg_fn),
    .a    (src_msg_a),
    .b    (src_msg_b)
  );

  imuldiv_IntDivIterative idiv
  (
    .clk                 (clk),
    .reset               (reset),
    .divreq_msg_fn       (src_msg_fn),
    .divreq_msg_a        (src_msg_a),
    .divreq_msg_b        (src_msg_b),
    .divreq_val          (src_val),
    .divreq_rdy          (src_rdy),
    .divresp_msg_result  (sink_msg),
    .divresp_val         (sink_val),
    .divresp_rdy         (sink_rdy)
  );

  vc_TestRandDelaySink#(64,1024,3) sink
  (
    .clk   (clk),
    .reset (reset),
    .msg   (sink_msg),
    .val   (sink_val),
    .rdy   (sink_rdy),
    .done  (sink_done)
  );

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module tester;

  // VCD Dump
  //initial begin
  //  $dumpfile("dump.vcd");
  //  $dumpvars;
  //end

  `VC_TEST_SUITE_BEGIN( "imuldiv-IntDivIterative" )

  reg  t0_reset = 1'b1;
  wire t0_done;

  imuldiv_IntDivIterative_helper t0
  (
    .clk   (clk),
    .reset (t0_reset),
    .done  (t0_done)
  );

  `VC_TEST_CASE_BEGIN( 1, "div/rem" )
  begin

    t0.src.src.m[ 0] = 65'h1_00000000_00000001; t0.sink.sink.m[ 0] = 64'h00000000_00000000;
    t0.src.src.m[ 1] = 65'h1_00000001_00000001; t0.sink.sink.m[ 1] = 64'h00000000_00000001;
    t0.src.src.m[ 2] = 65'h1_00000000_ffffffff; t0.sink.sink.m[ 2] = 64'h00000000_00000000;
    t0.src.src.m[ 3] = 65'h1_ffffffff_ffffffff; t0.sink.sink.m[ 3] = 64'h00000000_00000001;
    t0.src.src.m[ 4] = 65'h1_00000222_0000002a; t0.sink.sink.m[ 4] = 64'h00000000_0000000d;
    t0.src.src.m[ 5] = 65'h1_0a01b044_ffffb146; t0.sink.sink.m[ 5] = 64'h00000000_ffffdf76;
    t0.src.src.m[ 6] = 65'h1_00000032_00000222; t0.sink.sink.m[ 6] = 64'h00000032_00000000;
    t0.src.src.m[ 7] = 65'h1_00000222_00000032; t0.sink.sink.m[ 7] = 64'h0000002e_0000000a;
    t0.src.src.m[ 8] = 65'h1_0a01b044_ffffb14a; t0.sink.sink.m[ 8] = 64'h00003372_ffffdf75;
    t0.src.src.m[ 9] = 65'h1_deadbeef_0000beef; t0.sink.sink.m[ 9] = 64'hffffda72_ffffd353;
    t0.src.src.m[10] = 65'h1_f5fe4fbc_00004eb6; t0.sink.sink.m[10] = 64'hffffcc8e_ffffdf75;
    t0.src.src.m[11] = 65'h1_f5fe4fbc_ffffb14a; t0.sink.sink.m[11] = 64'hffffcc8e_0000208b;

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #10000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN( 2, "divu/remu" )
  begin

    t0.src.src.m[ 0] = 65'h0_00000000_00000001; t0.sink.sink.m[ 0] = 64'h00000000_00000000;
    t0.src.src.m[ 1] = 65'h0_00000001_00000001; t0.sink.sink.m[ 1] = 64'h00000000_00000001;
    t0.src.src.m[ 2] = 65'h0_00000000_ffffffff; t0.sink.sink.m[ 2] = 64'h00000000_00000000;
    t0.src.src.m[ 3] = 65'h0_ffffffff_ffffffff; t0.sink.sink.m[ 3] = 64'h00000000_00000001;
    t0.src.src.m[ 4] = 65'h0_00000222_0000002a; t0.sink.sink.m[ 4] = 64'h00000000_0000000d;
    t0.src.src.m[ 5] = 65'h0_0a01b044_00004eba; t0.sink.sink.m[ 5] = 64'h00000000_0000208a;
    t0.src.src.m[ 6] = 65'h0_00000032_00000222; t0.sink.sink.m[ 6] = 64'h00000032_00000000;
    t0.src.src.m[ 7] = 65'h0_00000222_00000032; t0.sink.sink.m[ 7] = 64'h0000002e_0000000a;
    t0.src.src.m[ 8] = 65'h0_0a01b044_ffffb14a; t0.sink.sink.m[ 8] = 64'h0a01b044_00000000;
    t0.src.src.m[ 9] = 65'h0_deadbeef_0000beef; t0.sink.sink.m[ 9] = 64'h0000227f_00012a90;
    t0.src.src.m[10] = 65'h0_f5fe4fbc_00004eb6; t0.sink.sink.m[10] = 64'h000006f0_00032012;
    t0.src.src.m[11] = 65'h0_f5fe4fbc_ffffb14a; t0.sink.sink.m[11] = 64'hf5fe4fbc_00000000;

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #10000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 2 )

endmodule
