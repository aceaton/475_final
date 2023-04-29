//========================================================================
// imuldiv-MulDivReqMsg : Multiplier/Divider Request Message
//========================================================================
// A multiplier/divider request message contains input data and the
// desired operation and is sent to a multipler/divider unit. The unit
// will respond with a multiplier/divider response message.
//
// Message Format:
//
//   66  64 63       32 31        0
//  +------+-----------+-----------+
//  | func | operand b | operand a |
//  +------+-----------+-----------+
//

`ifndef IMULDIV_MULDIVREQ_MSG_V
`define IMULDIV_MULDIVREQ_MSG_V

//------------------------------------------------------------------------
// Message defines
//------------------------------------------------------------------------

// Size of message

`define IMULDIV_MULDIVREQ_MSG_SZ         67

// Size and enums for each field

`define IMULDIV_MULDIVREQ_MSG_FUNC_SZ    3
`define IMULDIV_MULDIVREQ_MSG_FUNC_MUL   3'd0
`define IMULDIV_MULDIVREQ_MSG_FUNC_DIV   3'd1
`define IMULDIV_MULDIVREQ_MSG_FUNC_DIVU  3'd2
`define IMULDIV_MULDIVREQ_MSG_FUNC_REM   3'd3
`define IMULDIV_MULDIVREQ_MSG_FUNC_REMU  3'd4
`define IMULDIV_MULDIVREQ_MSG_FUNC_MULU  3'd5
`define IMULDIV_MULDIVREQ_MSG_FUNC_MULSU 3'd6


`define IMULDIV_MULDIVREQ_MSG_A_SZ       32
`define IMULDIV_MULDIVREQ_MSG_B_SZ       32

// Location of each field

`define IMULDIV_MULDIVREQ_MSG_FUNC_FIELD 66:64
`define IMULDIV_MULDIVREQ_MSG_A_FIELD    63:32
`define IMULDIV_MULDIVREQ_MSG_B_FIELD    31:0

//------------------------------------------------------------------------
// Convert message to bits
//------------------------------------------------------------------------

module imuldiv_MulDivReqMsgToBits
(
  // Input message

  input [`IMULDIV_MULDIVREQ_MSG_FUNC_SZ-1:0] func,
  input [`IMULDIV_MULDIVREQ_MSG_A_SZ-1:0]    a,
  input [`IMULDIV_MULDIVREQ_MSG_B_SZ-1:0]    b,

  // Output bits

  output [`IMULDIV_MULDIVREQ_MSG_SZ-1:0] bits
);

  assign bits[`IMULDIV_MULDIVREQ_MSG_FUNC_FIELD] = func;
  assign bits[`IMULDIV_MULDIVREQ_MSG_A_FIELD]    = a;
  assign bits[`IMULDIV_MULDIVREQ_MSG_B_FIELD]    = b;

endmodule

//------------------------------------------------------------------------
// Convert message from bits
//------------------------------------------------------------------------

module imuldiv_MulDivReqMsgFromBits
(
  // Input bits

  input [`IMULDIV_MULDIVREQ_MSG_SZ-1:0] bits,

  // Output message

  output [`IMULDIV_MULDIVREQ_MSG_FUNC_SZ-1:0] func,
  output [`IMULDIV_MULDIVREQ_MSG_A_SZ-1:0]    a,
  output [`IMULDIV_MULDIVREQ_MSG_B_SZ-1:0]    b
);

  assign func = bits[`IMULDIV_MULDIVREQ_MSG_FUNC_FIELD];
  assign a    = bits[`IMULDIV_MULDIVREQ_MSG_A_FIELD];
  assign b    = bits[`IMULDIV_MULDIVREQ_MSG_B_FIELD];

endmodule

//------------------------------------------------------------------------
// Convert message to string
//------------------------------------------------------------------------

`ifndef SYNTHESIS
module imuldiv_MulDivReqMsgToStr
(
  input [`IMULDIV_MULDIVREQ_MSG_SZ-1:0] msg
);

  // Extract fields

  wire [`IMULDIV_MULDIVREQ_MSG_FUNC_SZ-1:0] func = msg[`IMULDIV_MULDIVREQ_MSG_FUNC_FIELD];
  wire [`IMULDIV_MULDIVREQ_MSG_A_SZ-1:0]    a    = msg[`IMULDIV_MULDIVREQ_MSG_A_FIELD];
  wire [`IMULDIV_MULDIVREQ_MSG_B_SZ-1:0]    b    = msg[`IMULDIV_MULDIVREQ_MSG_B_FIELD];

  // Short names

  localparam mul   = `IMULDIV_MULDIVREQ_MSG_FUNC_MUL;
  localparam div   = `IMULDIV_MULDIVREQ_MSG_FUNC_DIV;
  localparam divu  = `IMULDIV_MULDIVREQ_MSG_FUNC_DIVU;
  localparam rem   = `IMULDIV_MULDIVREQ_MSG_FUNC_REM;
  localparam remu  = `IMULDIV_MULDIVREQ_MSG_FUNC_REMU;

  // Full string sized for 20 characters

  reg [20*8-1:0] full_str;
  always @(*) begin

    if ( msg === `IMULDIV_MULDIVREQ_MSG_SZ'bx )
      $sformat( full_str, "x            ");
    else begin
      case ( func )
        mul     : $sformat( full_str, "mul  %d, %d", a, b );
        div     : $sformat( full_str, "div  %d, %d", a, b );
        divu    : $sformat( full_str, "divu %d, %d", a, b );
        rem     : $sformat( full_str, "rem  %d, %d", a, b );
        remu    : $sformat( full_str, "remu %d, %d", a, b );
        default : $sformat( full_str, "undefined func" );
      endcase
    end

  end

  // Tiny string sized for 2 characters

  reg [2*8-1:0] tiny_str;
  always @(*) begin

    if ( msg === `IMULDIV_MULDIVREQ_MSG_SZ'bx )
      $sformat( tiny_str, "x ");
    else begin
      case ( func )
        mul     : $sformat( tiny_str, "* "  );
        div     : $sformat( tiny_str, "/ "  );
        divu    : $sformat( tiny_str, "/u"  );
        rem     : $sformat( tiny_str, "%% " );
        remu    : $sformat( tiny_str, "%%u" );
        default : $sformat( tiny_str, "??"  );
      endcase
    end

  end

endmodule
`endif /* SYNTHESIS */

`endif /* IMULDIV_MULDIVREQ_MSG_V */


