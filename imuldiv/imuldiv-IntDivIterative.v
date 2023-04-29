//========================================================================
// Lab 1 - Iterative Div Unit
//========================================================================

`ifndef RISCV_INT_DIV_ITERATIVE_V
`define RISCV_INT_DIV_ITERATIVE_V

`include "imuldiv-DivReqMsg.v"

module imuldiv_IntDivIterative
(

  input         clk,
  input         reset,

  input         divreq_msg_fn,
  input  [31:0] divreq_msg_a,
  input  [31:0] divreq_msg_b,
  input         divreq_val,
  output        divreq_rdy,

  output [63:0] divresp_msg_result,
  output        divresp_val,
  input         divresp_rdy
);

  wire    [4:0] counter;
  wire          div_sign;
  wire          rem_sign;
  wire          diff_msb;
  wire          sign_en;
  wire          a_en;
  wire          b_en;
  wire          cntr_mux_sel;
  wire          is_op_signed;
  wire          a_mux_sel;
  wire          sub_mux_sel;
  wire          res_div_sign_mux_sel;
  wire          res_rem_sign_mux_sel;

  imuldiv_IntDivIterativeDpath dpath
  (
    .clk                  (clk),
    .reset                (reset),
    .divreq_msg_a         (divreq_msg_a),
    .divreq_msg_b         (divreq_msg_b),
    .divresp_msg_result   (divresp_msg_result),
    .counter              (counter),
    .div_sign             (div_sign),
    .rem_sign             (rem_sign),
    .diff_msb             (diff_msb),
    .sign_en              (sign_en),
    .a_en                 (a_en),
    .b_en                 (b_en),
    .cntr_mux_sel         (cntr_mux_sel),
    .is_op_signed         (is_op_signed),
    .a_mux_sel            (a_mux_sel),
    .sub_mux_sel          (sub_mux_sel),
    .res_div_sign_mux_sel (res_div_sign_mux_sel),
    .res_rem_sign_mux_sel (res_rem_sign_mux_sel)
  );

  imuldiv_IntDivIterativeCtrl ctrl
  (
    .clk                  (clk),
    .reset                (reset),
    .divreq_msg_fn        (divreq_msg_fn),
    .divreq_val           (divreq_val),
    .divreq_rdy           (divreq_rdy),
    .divresp_val          (divresp_val),
    .divresp_rdy          (divresp_rdy),
    .counter              (counter),
    .div_sign             (div_sign),
    .rem_sign             (rem_sign),
    .diff_msb             (diff_msb),
    .sign_en              (sign_en),
    .a_en                 (a_en),
    .b_en                 (b_en),
    .cntr_mux_sel         (cntr_mux_sel),
    .is_op_signed         (is_op_signed),
    .a_mux_sel            (a_mux_sel),
    .sub_mux_sel          (sub_mux_sel),
    .res_div_sign_mux_sel (res_div_sign_mux_sel),
    .res_rem_sign_mux_sel (res_rem_sign_mux_sel)
  );

endmodule

//------------------------------------------------------------------------
// Datapath
//------------------------------------------------------------------------

module imuldiv_IntDivIterativeDpath
(
  input         clk,
  input         reset,

  // Operands and Result

  input  [31:0] divreq_msg_a,
  input  [31:0] divreq_msg_b,
  output [63:0] divresp_msg_result,

  // Datapath Outputs

  output  [4:0] counter,
  output        div_sign,
  output        rem_sign,
  output        diff_msb,

  // Control Inputs

  input         sign_en,
  input         a_en,
  input         b_en,
  input         cntr_mux_sel,
  input         is_op_signed,
  input         a_mux_sel,
  input         sub_mux_sel,
  input         res_div_sign_mux_sel,
  input         res_rem_sign_mux_sel
);

  //----------------------------------------------------------------------
  // Control Definitions
  //----------------------------------------------------------------------

  localparam op_x     = 1'dx;
  localparam op_load  = 1'd0;
  localparam op_next  = 1'd1;

  localparam sub_x    = 1'dx;
  localparam sub_next = 1'd0;
  localparam sub_old  = 1'd1;

  localparam sign_x   = 1'dx;
  localparam sign_u   = 1'd0;
  localparam sign_s   = 1'd1;

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

  wire   div_sign_next = divreq_msg_a[31] ^ divreq_msg_b[31];

  wire   rem_sign_next = divreq_msg_a[31];

  assign div_sign      = div_sign_reg;

  assign rem_sign      = rem_sign_reg;

  // Unsigned Operands

  wire [31:0] unsigned_a
    = ( divreq_msg_a[31] && is_op_signed ) ? ~divreq_msg_a + 1'b1
    :                                           divreq_msg_a;

  wire [31:0] unsigned_b
    = ( divreq_msg_b[31] && is_op_signed ) ? ~divreq_msg_b + 1'b1
    :                                           divreq_msg_b;

  // Operand Muxes

  wire [64:0] a_mux_out
    = ( a_mux_sel == op_load ) ? { 65'b0, unsigned_a }
    : ( a_mux_sel == op_next ) ? sub_mux_out
    :                            65'bx;

  wire [64:0] b_in = { 1'b0, unsigned_b, 32'b0 };

  //----------------------------------------------------------------------
  // Sequential Logic
  //----------------------------------------------------------------------

  reg  [4:0] counter_reg;
  reg        div_sign_reg;
  reg        rem_sign_reg;
  reg [64:0] a_reg;
  reg [64:0] b_reg;

  always @ ( posedge clk ) begin
    if ( sign_en ) begin
      div_sign_reg   <= div_sign_next;
      rem_sign_reg   <= rem_sign_next;
    end

    if ( a_en ) begin
      a_reg <= a_mux_out;
    end

    if ( b_en ) begin
      b_reg <= b_in;
    end

    counter_reg  <= counter_mux_out;
  end

  //----------------------------------------------------------------------
  // Post-Flop Combinational Logic
  //----------------------------------------------------------------------

  // Operand Shifter

  wire [64:0] a_shift_out = a_reg << 1;

  // Subtractor

  wire [64:0] sub_out = a_shift_out - b_reg;

  wire [64:0] sub_mux_out
    = ( sub_mux_sel == sub_next )  ? { sub_out[64:1], 1'b1 }
    : ( sub_mux_sel == sub_old )   ? a_shift_out
    :                                65'bx;

  // Sign of Difference (was result negative?)

  assign diff_msb = sub_out[64];

  // Signed Result Muxes

  wire [31:0] signed_res_div_mux_out
    = ( res_div_sign_mux_sel == sign_u ) ? a_reg[31:0]
    : ( res_div_sign_mux_sel == sign_s ) ? ~a_reg[31:0] + 1'b1
    :                                     32'bx;

  wire [31:0] signed_res_rem_mux_out
    = ( res_rem_sign_mux_sel == sign_u ) ? a_reg[63:32]
    : ( res_rem_sign_mux_sel == sign_s ) ? ~a_reg[63:32] + 1'b1
    :                                      32'bx;

  // Final Result

  assign divresp_msg_result = { signed_res_rem_mux_out, signed_res_div_mux_out };

endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntDivIterativeCtrl
(
  input        clk,
  input        reset,

  // Opcode

  input        divreq_msg_fn,

  // Request val/rdy

  input        divreq_val,
  output       divreq_rdy,

  // Response val/rdy

  output       divresp_val,
  input        divresp_rdy,

  // Datapath Inputs

  input  [4:0] counter,
  input        div_sign,
  input        rem_sign,
  input        diff_msb,

  // Control Outputs

  output       sign_en,
  output       a_en,
  output       b_en,
  output       cntr_mux_sel,
  output       is_op_signed,
  output       a_mux_sel,
  output       sub_mux_sel,
  output       res_div_sign_mux_sel,
  output       res_rem_sign_mux_sel
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
  reg       fn_reg;

  always @ ( posedge clk ) begin
    if ( reset ) begin
      state_reg <= STATE_IDLE;
    end
    else begin
      if ( fn_en ) begin
        fn_reg  <= divreq_msg_fn;
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
        if ( divreq_go ) begin
          state_next = STATE_CALC;
        end

      STATE_CALC:
        if ( is_calc_done ) begin
          state_next = STATE_SIGN;
        end

      STATE_SIGN:
        if ( divresp_go ) begin
          state_next = STATE_IDLE;
        end

    endcase

  end

  //----------------------------------------------------------------------
  // Control Definitions
  //----------------------------------------------------------------------

  localparam n = 1'd0;
  localparam y = 1'd1;

  localparam op_x    = 1'dx;
  localparam op_load = 1'd0;
  localparam op_next = 1'd1;

  //----------------------------------------------------------------------
  // Output Control Signals
  //----------------------------------------------------------------------

  localparam cs_size = 8;
  reg [cs_size-1:0] cs;

  // State Definitions

  always @ ( * ) begin

    case ( state_reg )

      //                 divreq divresp sign a  b   fn cntr,    a
      //                 rdy    val     en   en en  en mux_sel, mux_sel
      STATE_IDLE: cs = { y,     n,      y,   y, y,  y, op_load, op_load };
      STATE_CALC: cs = { n,     n,      n,   y, n,  n, op_next, op_next };
      STATE_SIGN: cs = { n,     y,      n,   n, n,  n, op_x,    op_x    };

    endcase

  end

  // Signal Parsing

  assign divreq_rdy           = cs[7];
  assign divresp_val          = cs[6];
  assign sign_en              = cs[5];
  assign a_en                 = cs[4];
  assign b_en                 = cs[3];
  wire   fn_en                = cs[2];
  assign cntr_mux_sel         = cs[1];
  assign is_op_signed         = ( divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED );
  assign a_mux_sel            = cs[0];
  assign sub_mux_sel          = diff_msb;
  assign res_div_sign_mux_sel = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED ) && div_sign;
  assign res_rem_sign_mux_sel = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED ) && rem_sign;

  // Transition Triggers

  wire divreq_go     = divreq_val  && divreq_rdy;
  wire divresp_go    = divresp_val && divresp_rdy;
  wire is_calc_done  = ( counter == 5'b0 );

endmodule

`endif
