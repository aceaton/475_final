//========================================================================
// Simulator for Iterative MulDiv Unit
//========================================================================

`include "imuldiv-MulDivReqMsg.v"
`include "imuldiv-IntMulDivIterative.v"

//------------------------------------------------------------------------
// Simulator
//------------------------------------------------------------------------

module sim;

  // VCD Dump
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  // Generate Clock

  reg clk = 1'b0;

  always #5 clk = ~clk;


  // MulDiv Unit

  reg   [2:0] src_msg_fn;
  reg  [31:0] src_msg_a;
  reg  [31:0] src_msg_b;
  reg         src_val = 1'b0;
  wire        src_rdy;

  wire [63:0] sink_msg;
  wire        sink_val;
  wire        sink_rdy = 1'b1; // Always ready to accept result

  wire        muldivreq_go  = src_val && src_rdy;
  wire        muldivresp_go = sink_val && sink_rdy;

  reg reset = 1'b1;
  reg [1023:0] op_type;

  imuldiv_IntMulDivIterative imuldiv
  (
    .clk                    (clk),
    .reset                  (reset),
    .muldivreq_msg_fn       (src_msg_fn),
    .muldivreq_msg_a        (src_msg_a),
    .muldivreq_msg_b        (src_msg_b),
    .muldivreq_val          (src_val),
    .muldivreq_rdy          (src_rdy),
    .muldivresp_msg_result  (sink_msg),
    .muldivresp_val         (sink_val),
    .muldivresp_rdy         (sink_rdy)
  );

  // Initial Block

  initial begin

    // Reset signal

    #10 reset = 1'b0;

    // Parse Arguments

    if ( !$value$plusargs( "op=%s", op_type ) ) begin
      $display( "No operation specified! {mul,div,divu,rem,remu}" ); $finish;
    end

    case ( op_type )

      "mul"  : src_msg_fn = `IMULDIV_MULDIVREQ_MSG_FUNC_MUL;
      "div"  : src_msg_fn = `IMULDIV_MULDIVREQ_MSG_FUNC_DIV;
      "divu" : src_msg_fn = `IMULDIV_MULDIVREQ_MSG_FUNC_DIVU;
      "rem"  : src_msg_fn = `IMULDIV_MULDIVREQ_MSG_FUNC_REM;
      "remu" : src_msg_fn = `IMULDIV_MULDIVREQ_MSG_FUNC_REMU;
      default:
       begin
        $display( "Illegal operation! {mul,div,divu,rem,remu}" );
        $finish;
       end

    endcase

    if ( !$value$plusargs( "a=%d", src_msg_a ) ) begin
      $display( "No operand A specified!" ); $finish;
    end

    if ( !$value$plusargs( "b=%d", src_msg_b ) ) begin
      $display( "No operand B specified!" ); $finish;
    end

    // Set request valid high

    src_val = 1'b1;

  end

  // Count Clock Cycles

  reg        busy = 1'b0;
  reg [31:0] cycle_count = 32'b0;

  always @ ( posedge clk ) begin

    // Computation has started

    if ( muldivreq_go ) begin
      busy <= 1'b1;
    end

    // Result is ready, display output and cycle count

    else if ( muldivresp_go ) begin

      case ( src_msg_fn )
        `IMULDIV_MULDIVREQ_MSG_FUNC_MUL  : $display( "%h * %h = %h", src_msg_a, src_msg_b, sink_msg );
        `IMULDIV_MULDIVREQ_MSG_FUNC_DIV  : $display( "%h / %h = %h", src_msg_a, src_msg_b, sink_msg[31:0] );
        `IMULDIV_MULDIVREQ_MSG_FUNC_DIVU : $display( "%h /u %h = %h", src_msg_a, src_msg_b, sink_msg[31:0] );
        `IMULDIV_MULDIVREQ_MSG_FUNC_REM  : $display( "%h %% %h = %h", src_msg_a, src_msg_b, sink_msg[63:32] );
        `IMULDIV_MULDIVREQ_MSG_FUNC_REMU : $display( "%h %%u %h = %h", src_msg_a, src_msg_b, sink_msg[63:32] );
      endcase

      $display( "Cycle Count = %d", cycle_count );

      $finish;
    end

    // Reset val signal after operands have been accepted

    if ( src_val ) begin
      src_val <= 1'b0;
    end

    // If computation has started, start counting cycles. We need to
    // count starting the clock edge when new operands are flopped in to
    // accurately measure the total clock cycles since the simulation
    // terminates before the final clock cycle can be flopped into the register.

    if ( muldivreq_go || busy ) begin
      cycle_count <= cycle_count + 1;
    end
  end

endmodule
