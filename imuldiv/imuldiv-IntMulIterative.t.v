//========================================================================
// Test for Muldiv Unit
//========================================================================

`include "imuldiv-MulDivReqMsg.v"
`include "imuldiv-IntMulIterative.v"
`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-Test.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module imuldiv_IntMulIterative_helper
(
  input       clk,
  input       reset,
  output      done
);

  wire [66:0] src_msg;
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

  vc_TestRandDelaySource#(67,1024,3) src
  (
    .clk   (clk),
    .reset (reset),
    .msg   (src_msg),
    .val   (src_val),
    .rdy   (src_rdy),
    .done  (src_done)
  );

  imuldiv_MulDivReqMsgFromBits msgfrombits
  (
    .bits (src_msg),
    .func (),
    .a    (src_msg_a),
    .b    (src_msg_b)
  );

  imuldiv_IntMulIterative imul
  (
    .clk                (clk),
    .reset              (reset),
    .mulreq_msg_a       (src_msg_a),
    .mulreq_msg_b       (src_msg_b),
    .mulreq_val         (src_val),
    .mulreq_rdy         (src_rdy),
    .mulresp_msg_result (sink_msg),
    .mulresp_val        (sink_val),
    .mulresp_rdy        (sink_rdy)
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

  `VC_TEST_SUITE_BEGIN( "imuldiv-IntMulIterative" )

  reg  t0_reset = 1'b1;
  wire t0_done;

  imuldiv_IntMulIterative_helper t0
  (
    .clk   (clk),
    .reset (t0_reset),
    .done  (t0_done)
  );

  `VC_TEST_CASE_BEGIN( 1, "mul" )
  begin

    t0.src.src.m[0] = 67'h0_00000000_00000000; t0.sink.sink.m[0] = 64'h00000000_00000000;
    t0.src.src.m[1] = 67'h0_00000001_00000001; t0.sink.sink.m[1] = 64'h00000000_00000001;
    t0.src.src.m[2] = 67'h0_ffffffff_00000001; t0.sink.sink.m[2] = 64'hffffffff_ffffffff;
    t0.src.src.m[3] = 67'h0_00000001_ffffffff; t0.sink.sink.m[3] = 64'hffffffff_ffffffff;
    t0.src.src.m[4] = 67'h0_ffffffff_ffffffff; t0.sink.sink.m[4] = 64'h00000000_00000001;
    t0.src.src.m[5] = 67'h0_00000008_00000003; t0.sink.sink.m[5] = 64'h00000000_00000018;
    t0.src.src.m[6] = 67'h0_fffffff8_00000008; t0.sink.sink.m[6] = 64'hffffffff_ffffffc0;
    t0.src.src.m[7] = 67'h0_fffffff8_fffffff8; t0.sink.sink.m[7] = 64'h00000000_00000040;
    t0.src.src.m[8] = 67'h0_0deadbee_10000000; t0.sink.sink.m[8] = 64'h00deadbe_e0000000;
    t0.src.src.m[9] = 67'h0_deadbeef_10000000; t0.sink.sink.m[9] = 64'hfdeadbee_f0000000;

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #10000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 1 )

endmodule
