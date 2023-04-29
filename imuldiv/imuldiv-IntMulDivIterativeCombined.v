//========================================================================
// Lab 1 - Iterative Combined MulDiv Unit
//========================================================================

`ifndef RISCV_INT_MULDIV_ITERATIVE_COMB_V
`define RISCV_INT_MULDIV_ITERATIVE_COMB_V

`include "imuldiv-MulDivReqMsg.v"

module imuldiv_IntMulDivIterativeComb
(

  input         clk,
  input         reset,

  input   [2:0] muldivreq_msg_fn,
  input  [31:0] muldivreq_msg_a,
  input  [31:0] muldivreq_msg_b,
  input         muldivreq_val,
  output        muldivreq_rdy,

  output [63:0] muldivresp_msg_result,
  output        muldivresp_val,
  input         muldivresp_rdy
);

  wire    [4:0] counter;
  wire          sign;
  wire          rem_sign;
  wire          b_lsb;
  wire          diff_msb;
  wire          sign_en;
  wire          a_en;
  wire          result_en;
  wire          cntr_mux_sel;
  wire          op_sign_mux_sel;
  wire          a_mux_1_sel;
  wire          a_mux_2_sel;
  wire          b_mux_sel;
  wire          res_mux_1_sel;
  wire          res_mux_2_sel;
  wire          addsub_fn;
  wire    [1:0] addsub_mux_sel;
  wire          res_mul_sign_mux_sel;
  wire          res_div_sign_mux_sel;
  wire          res_rem_sign_mux_sel;
  wire          res_mux_sel;

  imuldiv_IntMulDivIterativeCombDpath dpath
  (
    .clk                   (clk),
    .reset                 (reset),
    .muldivreq_msg_a       (muldivreq_msg_a),
    .muldivreq_msg_b       (muldivreq_msg_b),
    .muldivresp_msg_result (muldivresp_msg_result),
    .counter               (counter),
    .sign                  (sign),
    .rem_sign              (rem_sign),
    .b_lsb                 (b_lsb),
    .diff_msb              (diff_msb),
    .sign_en               (sign_en),
    .a_en                  (a_en),
    .result_en             (result_en),
    .cntr_mux_sel          (cntr_mux_sel),
    .op_sign_mux_sel       (op_sign_mux_sel),
    .a_mux_1_sel           (a_mux_1_sel),
    .a_mux_2_sel           (a_mux_2_sel),
    .b_mux_sel             (b_mux_sel),
    .res_mux_1_sel         (res_mux_1_sel),
    .res_mux_2_sel         (res_mux_2_sel),
    .addsub_fn             (addsub_fn),
    .addsub_mux_sel        (addsub_mux_sel),
    .res_mul_sign_mux_sel  (res_mul_sign_mux_sel),
    .res_div_sign_mux_sel  (res_div_sign_mux_sel),
    .res_rem_sign_mux_sel  (res_rem_sign_mux_sel),
    .res_mux_sel           (res_mux_sel)
  );

  imuldiv_IntMulDivIterativeCombCtrl ctrl
  (
    .clk                  (clk),
    .reset                (reset),
    .muldivreq_msg_fn     (muldivreq_msg_fn),
    .muldivreq_val        (muldivreq_val),
    .muldivreq_rdy        (muldivreq_rdy),
    .muldivresp_val       (muldivresp_val),
    .muldivresp_rdy       (muldivresp_rdy),
    .counter              (counter),
    .sign                 (sign),
    .rem_sign             (rem_sign),
    .b_lsb                (b_lsb),
    .diff_msb             (diff_msb),
    .sign_en              (sign_en),
    .a_en                 (a_en),
    .result_en            (result_en),
    .cntr_mux_sel         (cntr_mux_sel),
    .op_sign_mux_sel      (op_sign_mux_sel),
    .a_mux_1_sel          (a_mux_1_sel),
    .a_mux_2_sel          (a_mux_2_sel),
    .b_mux_sel            (b_mux_sel),
    .res_mux_1_sel        (res_mux_1_sel),
    .res_mux_2_sel        (res_mux_2_sel),
    .addsub_fn            (addsub_fn),
    .addsub_mux_sel       (addsub_mux_sel),
    .res_mul_sign_mux_sel (res_mul_sign_mux_sel),
    .res_div_sign_mux_sel (res_div_sign_mux_sel),
    .res_rem_sign_mux_sel (res_rem_sign_mux_sel),
    .res_mux_sel          (res_mux_sel)
  );

endmodule

//------------------------------------------------------------------------
// Datapath
//------------------------------------------------------------------------

module imuldiv_IntMulDivIterativeCombDpath
(
  input         clk,
  input         reset,

  // Operands and Result

  input  [31:0] muldivreq_msg_a,
  input  [31:0] muldivreq_msg_b,
  output [63:0] muldivresp_msg_result,

  // Datapath Outputs

  output  [4:0] counter,
  output        sign,
  output        rem_sign,
  output        b_lsb,
  output        diff_msb,

  // Control Inputs

  input         sign_en,
  input         a_en,
  input         result_en,
  input         cntr_mux_sel,
  input         op_sign_mux_sel,
  input         a_mux_1_sel,
  input         a_mux_2_sel,
  input         b_mux_sel,
  input         res_mux_1_sel,
  input         res_mux_2_sel,
  input         addsub_fn,
  input   [1:0] addsub_mux_sel,
  input         res_mul_sign_mux_sel,
  input         res_div_sign_mux_sel,
  input         res_rem_sign_mux_sel,
  input         res_mux_sel
);

  //----------------------------------------------------------------------
  // Control Definitions
  //----------------------------------------------------------------------

  localparam op_x         = 1'dx;
  localparam op_load      = 1'd0;
  localparam op_next      = 1'd1;

  localparam a_x          = 1'dx;
  localparam a_shift      = 1'd0;
  localparam a_addsub     = 1'd1;

  localparam a_load       = 1'd0;
  localparam a_next       = 1'd1;

  localparam res_x        = 1'dx;
  localparam res_zero     = 1'd0;
  localparam res_b        = 1'd1;

  localparam res_load     = 1'd0;
  localparam res_next     = 1'd1;

  localparam addsub_x     = 2'dx;
  localparam addsub_old   = 2'd0;
  localparam addsub_shift = 2'd1;
  localparam addsub_mul   = 2'd2;
  localparam addsub_div   = 2'd3;

  localparam sign_x       = 1'dx;
  localparam sign_u       = 1'd0;
  localparam sign_s       = 1'd1;

  localparam fn_x         = 1'dx;
  localparam fn_mul       = 1'd0;
  localparam fn_div       = 1'd1;

  //----------------------------------------------------------------------
  // Pre-Flop Combinational Logic
  //----------------------------------------------------------------------

  // Counter Mux

  wire [4:0] counter_mux_out
    = ( cntr_mux_sel == op_load ) ? 31
    : ( cntr_mux_sel == op_next ) ? counter_reg - 1'b1
    :                               5'bx;

  assign counter = counter_reg;

  // Sign of Result

  wire   sign_next     = muldivreq_msg_a[31] ^ muldivreq_msg_b[31];

  wire   rem_sign_next = muldivreq_msg_a[31];

  assign sign        = sign_reg;

  assign rem_sign    = rem_sign_reg;

  // Unsigned Operands

  wire [31:0] unsigned_a
    = ( muldivreq_msg_a[31] && op_sign_mux_sel ) ? ~muldivreq_msg_a + 1'b1
    :                                              muldivreq_msg_a;

  wire [31:0] unsigned_b
    = ( muldivreq_msg_b[31] && op_sign_mux_sel ) ? ~muldivreq_msg_b + 1'b1
    :                                              muldivreq_msg_b;

  // Operand Muxes

  wire [64:0] a_mux_1_out
    = ( a_mux_1_sel == a_shift )  ? a_shift_out
    : ( a_mux_1_sel == a_addsub ) ? addsub_mux_out
    :                               65'bx;

  wire [64:0] a_mux_2_out
    = ( a_mux_2_sel == a_load )   ? { 33'b0, unsigned_a }
    : ( a_mux_2_sel == a_next )   ? a_mux_1_out
    :                               65'bx;

  wire [31:0] b_mux_out
    = ( b_mux_sel   == op_load )  ? unsigned_b
    : ( b_mux_sel   == op_next )  ? b_shift_out
    :                               32'bx;

  // Result Mux

  wire [64:0] result_mux_1_out
    = ( res_mux_1_sel == res_zero ) ? 65'b0
    : ( res_mux_1_sel == res_b )    ? { 1'b0, unsigned_b, 32'b0 }
    :                                 65'bx;

  wire [64:0] result_mux_2_out
    = ( res_mux_2_sel == res_load ) ? result_mux_1_out
    : ( res_mux_2_sel == res_next ) ? addsub_mux_out
    :                                 65'bx;

  //----------------------------------------------------------------------
  // Sequential Logic
  //----------------------------------------------------------------------

  reg  [4:0] counter_reg;
  reg        sign_reg;
  reg        rem_sign_reg;
  reg [64:0] a_reg;
  reg [31:0] b_reg;
  reg [64:0] result_reg;

  always @ ( posedge clk ) begin
    if ( sign_en ) begin
      sign_reg     <= sign_next;
      rem_sign_reg <= rem_sign_next;
    end

    if ( a_en ) begin
      a_reg <= a_mux_2_out;
    end

    if ( result_en ) begin
      result_reg <= result_mux_2_out;
    end

    counter_reg  <= counter_mux_out;
    b_reg        <= b_mux_out;
  end

  //----------------------------------------------------------------------
  // Post-Flop Combinational Logic
  //----------------------------------------------------------------------

  // Operand Shifters

  wire [64:0] a_shift_out = a_reg << 1;

  wire [31:0] b_shift_out = b_reg >> 1;

  // AddSub Unit

  wire [64:0] addsub_out
    = ( addsub_fn == fn_mul ) ? ( a_reg + result_reg )
    : ( addsub_fn == fn_div ) ? ( a_shift_out - result_reg )
    :                           65'bx;

  wire [64:0] addsub_mux_out
    = ( addsub_mux_sel == addsub_old )   ? result_reg
    : ( addsub_mux_sel == addsub_shift ) ? a_shift_out
    : ( addsub_mux_sel == addsub_mul )   ? addsub_out
    : ( addsub_mux_sel == addsub_div )   ? { addsub_out[64:1], 1'b1 }
    :                                      65'bx;

  // Control Bits

  assign b_lsb    = b_reg[0];

  assign diff_msb = addsub_out[64];

  // Signed Result Muxes

  wire [63:0] signed_res_mul_mux_out
    = ( res_mul_sign_mux_sel == sign_u ) ? result_reg[63:0]
    : ( res_mul_sign_mux_sel == sign_s ) ? ~result_reg[63:0] + 1'b1
    :                                      64'bx;

  wire [31:0] signed_res_div_mux_out
    = ( res_div_sign_mux_sel == sign_u ) ? a_reg[31:0]
    : ( res_div_sign_mux_sel == sign_s ) ? ~a_reg[31:0] + 1'b1
    :                                      32'bx;

  wire [31:0] signed_res_rem_mux_out
    = ( res_rem_sign_mux_sel == sign_u ) ? a_reg[63:32]
    : ( res_rem_sign_mux_sel == sign_s ) ? ~a_reg[63:32] + 1'b1
    :                                      32'bx;

  // Final Result

  assign muldivresp_msg_result
    = ( res_mux_sel == fn_mul ) ? signed_res_mul_mux_out
    : ( res_mux_sel == fn_div ) ? { signed_res_rem_mux_out, signed_res_div_mux_out }
    :                             64'bx;

endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntMulDivIterativeCombCtrl
(
  input        clk,
  input        reset,

  // Opcode

  input  [2:0] muldivreq_msg_fn,

  // Request val/rdy

  input        muldivreq_val,
  output       muldivreq_rdy,

  // Response val/rdy

  output       muldivresp_val,
  input        muldivresp_rdy,

  // Datapath Inputs

  input  [4:0] counter,
  input        sign,
  input        rem_sign,
  input        b_lsb,
  input        diff_msb,

  // Control Outputs

  output       sign_en,
  output       a_en,
  output       result_en,
  output       cntr_mux_sel,
  output       op_sign_mux_sel,
  output       a_mux_1_sel,
  output       a_mux_2_sel,
  output       b_mux_sel,
  output       res_mux_1_sel,
  output       res_mux_2_sel,
  output       addsub_fn,
  output [1:0] addsub_mux_sel,
  output       res_mul_sign_mux_sel,
  output       res_div_sign_mux_sel,
  output       res_rem_sign_mux_sel,
  output       res_mux_sel
);

  //----------------------------------------------------------------------
  // State Definitions
  //----------------------------------------------------------------------

  localparam STATE_IDLE = 2'd0;
  localparam STATE_CALC = 2'd1;
  localparam STATE_SIGN = 2'd2;

  //----------------------------------------------------------------------
  // State Update
  //----------------------------------------------------------------------

  reg [1:0] state_reg;
  reg [2:0] fn_reg;

  always @ ( posedge clk ) begin
    if ( reset ) begin
      state_reg <= STATE_IDLE;
    end
    else begin
      if ( fn_en ) begin
        fn_reg  <= muldivreq_msg_fn;
      end
      state_reg <= state_next;
    end
  end

  //----------------------------------------------------------------------
  // State Transitions
  //----------------------------------------------------------------------

  reg [1:0] state_next;

  always @ ( * ) begin

    state_next = state_reg;

    case ( state_reg )

      STATE_IDLE:
        if ( muldivreq_go ) begin
          state_next = STATE_CALC;
        end

      STATE_CALC:
        if ( is_calc_done ) begin
          state_next = STATE_SIGN;
        end

      STATE_SIGN:
        if ( muldivresp_go ) begin
          state_next = STATE_IDLE;
        end

    endcase

  end

  //----------------------------------------------------------------------
  // Control Definitions
  //----------------------------------------------------------------------

  localparam n            = 1'd0;
  localparam y            = 1'd1;

  localparam op_x         = 1'dx;
  localparam op_load      = 1'd0;
  localparam op_next      = 1'd1;

  localparam a_x          = 1'dx;
  localparam a_shift      = 1'd0;
  localparam a_addsub     = 1'd1;

  localparam a_load       = 1'd0;
  localparam a_next       = 1'd1;

  localparam res_x        = 1'dx;
  localparam res_zero     = 1'd0;
  localparam res_b        = 1'd1;

  localparam res_load     = 1'd0;
  localparam res_next     = 1'd1;

  localparam addsub_x     = 2'dx;
  localparam addsub_old   = 2'd0;
  localparam addsub_shift = 2'd1;
  localparam addsub_mul   = 2'd2;
  localparam addsub_div   = 2'd3;

  //----------------------------------------------------------------------
  // Output Control Signals
  //----------------------------------------------------------------------

  localparam cs_size = 10;
  reg [cs_size-1:0] cs;

  // Helper Signals

  wire is_mul = ( fn_reg == `IMULDIV_MULDIVREQ_MSG_FUNC_MUL );
  wire is_div = ( fn_reg == `IMULDIV_MULDIVREQ_MSG_FUNC_DIV )
             || ( fn_reg == `IMULDIV_MULDIVREQ_MSG_FUNC_DIVU );
  wire is_rem = ( fn_reg == `IMULDIV_MULDIVREQ_MSG_FUNC_REM )
             || ( fn_reg == `IMULDIV_MULDIVREQ_MSG_FUNC_REMU );

  // State Definitions

  always @ ( * ) begin

    case ( state_reg )

      //                 req resp sign a  res     fn cntr,    a        b        res
      //                 rdy val  en   en en      en mux_sel, mux_sel  mux_sel  mux_sel
      STATE_IDLE: cs = { y,  n,   y,   y, y,      y, op_load, op_load, op_load, op_load };
      STATE_CALC: cs = { n,  n,   n,   y, is_mul, n, op_next, op_next, op_next, op_next };
      STATE_SIGN: cs = { n,  y,   n,   n, n,      n, op_x,    op_x,    op_x,    op_x    };

    endcase

  end

  // Signal Parsing

  assign muldivreq_rdy        = cs[9];
  assign muldivresp_val       = cs[8];
  assign sign_en              = cs[7];
  assign a_en                 = cs[6];
  assign result_en            = cs[5];
  wire   fn_en                = cs[4];
  assign cntr_mux_sel         = cs[3];
  assign op_sign_mux_sel      = ( muldivreq_msg_fn == `IMULDIV_MULDIVREQ_MSG_FUNC_MUL )
                             || ( muldivreq_msg_fn == `IMULDIV_MULDIVREQ_MSG_FUNC_DIV )
                             || ( muldivreq_msg_fn == `IMULDIV_MULDIVREQ_MSG_FUNC_REM );
  assign a_mux_1_sel          = is_div || is_rem;
  assign a_mux_2_sel          = cs[2];
  assign b_mux_sel            = cs[1];
  assign res_mux_1_sel        = ( muldivreq_msg_fn == `IMULDIV_MULDIVREQ_MSG_FUNC_DIV )
                             || ( muldivreq_msg_fn == `IMULDIV_MULDIVREQ_MSG_FUNC_DIVU )
                             || ( muldivreq_msg_fn == `IMULDIV_MULDIVREQ_MSG_FUNC_REM )
                             || ( muldivreq_msg_fn == `IMULDIV_MULDIVREQ_MSG_FUNC_REMU );
  assign res_mux_2_sel        = cs[0];
  assign addsub_fn            = is_div || is_rem;

  assign addsub_mux_sel
    = ( is_mul && b_lsb )     ? addsub_mul
    : ( is_mul && !b_lsb )    ? addsub_old
    : ( ( is_div || is_rem ) && !diff_msb ) ? addsub_div
    : ( ( is_div || is_rem ) && diff_msb )  ? addsub_shift
    :                           2'bx;

  assign res_mul_sign_mux_sel = ( fn_reg == `IMULDIV_MULDIVREQ_MSG_FUNC_MUL ) && sign;
  assign res_div_sign_mux_sel = ( ( fn_reg == `IMULDIV_MULDIVREQ_MSG_FUNC_DIV )
                             ||   ( fn_reg == `IMULDIV_MULDIVREQ_MSG_FUNC_REM ) )
                             &&     sign;
  assign res_rem_sign_mux_sel = ( ( fn_reg == `IMULDIV_MULDIVREQ_MSG_FUNC_DIV )
                             ||   ( fn_reg == `IMULDIV_MULDIVREQ_MSG_FUNC_REM ) )
                             &&     rem_sign;
  assign res_mux_sel          = is_div || is_rem;

  // Transition Triggers

  wire muldivreq_go  = muldivreq_val  && muldivreq_rdy;
  wire muldivresp_go = muldivresp_val && muldivresp_rdy;
  wire is_calc_done  = ( counter == 5'b0 );

endmodule

`endif
