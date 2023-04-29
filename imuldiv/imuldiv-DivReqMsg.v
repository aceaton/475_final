//========================================================================
// imuldiv-DivReqMsg : Divider Request Message
//========================================================================
// A divider request message contains input data and the
// desired operation and is sent to a divider unit. The unit
// will respond with a divider response message.
//
// Message Format:
//
//     64 63       32 31        0
//  +----+-----------+-----------+
//  | fn | operand b | operand a |
//  +----+-----------+-----------+
//

`ifndef IMULDIV_DIVREQ_MSG_V
`define IMULDIV_DIVREQ_MSG_V

//------------------------------------------------------------------------
// Message defines
//------------------------------------------------------------------------

// Size of message

`define IMULDIV_DIVREQ_MSG_SZ              65

// Size and enums for each field

`define IMULDIV_DIVREQ_MSG_FUNC_SZ         1
`define IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED   1'd0
`define IMULDIV_DIVREQ_MSG_FUNC_SIGNED     1'd1

`define IMULDIV_DIVREQ_MSG_A_SZ            32
`define IMULDIV_DIVREQ_MSG_B_SZ            32

// Location of each field

`define IMULDIV_DIVREQ_MSG_FUNC_FIELD      64
`define IMULDIV_DIVREQ_MSG_A_FIELD         63:32
`define IMULDIV_DIVREQ_MSG_B_FIELD         31:0

//------------------------------------------------------------------------
// Convert message to bits
//------------------------------------------------------------------------

module imuldiv_DivReqMsgToBits
(
  // Input message

  input [`IMULDIV_DIVREQ_MSG_FUNC_SZ-1:0] func,
  input [`IMULDIV_DIVREQ_MSG_A_SZ-1:0]    a,
  input [`IMULDIV_DIVREQ_MSG_B_SZ-1:0]    b,

  // Output bits

  output [`IMULDIV_DIVREQ_MSG_SZ-1:0] bits
);

  assign bits[`IMULDIV_DIVREQ_MSG_FUNC_FIELD] = func;
  assign bits[`IMULDIV_DIVREQ_MSG_A_FIELD]    = a;
  assign bits[`IMULDIV_DIVREQ_MSG_B_FIELD]    = b;

endmodule

//------------------------------------------------------------------------
// Convert message from bits
//------------------------------------------------------------------------

module imuldiv_DivReqMsgFromBits
(
  // Input bits

  input [`IMULDIV_DIVREQ_MSG_SZ-1:0] bits,

  // Output message

  output [`IMULDIV_DIVREQ_MSG_FUNC_SZ-1:0] func,
  output [`IMULDIV_DIVREQ_MSG_A_SZ-1:0]    a,
  output [`IMULDIV_DIVREQ_MSG_B_SZ-1:0]    b
);

  assign func = bits[`IMULDIV_DIVREQ_MSG_FUNC_FIELD];
  assign a    = bits[`IMULDIV_DIVREQ_MSG_A_FIELD];
  assign b    = bits[`IMULDIV_DIVREQ_MSG_B_FIELD];

endmodule

//------------------------------------------------------------------------
// Convert message to string
//------------------------------------------------------------------------

`ifndef SYNTHESIS
module imuldiv_DivReqMsgToStr
(
  input [`IMULDIV_DIVREQ_MSG_SZ-1:0] msg
);

  // Extract fields

  wire [`IMULDIV_DIVREQ_MSG_FUNC_SZ-1:0] func = msg[`IMULDIV_DIVREQ_MSG_FUNC_FIELD];
  wire [`IMULDIV_DIVREQ_MSG_A_SZ-1:0]    a    = msg[`IMULDIV_DIVREQ_MSG_A_FIELD];
  wire [`IMULDIV_DIVREQ_MSG_B_SZ-1:0]    b    = msg[`IMULDIV_DIVREQ_MSG_B_FIELD];

  // Short names

  localparam fn_unsigned = `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED;
  localparam fn_signed   = `IMULDIV_DIVREQ_MSG_FUNC_SIGNED;

  // Full string sized for 20 characters

  reg [20*8-1:0] full_str;
  always @(*) begin

    if ( msg === `IMULDIV_DIVREQ_MSG_SZ'bx )
      $sformat( full_str, "x            ");
    else begin
      case ( func )
        fn_signed   : $sformat( full_str, "div   %d, %d", a, b );
        fn_unsigned : $sformat( full_str, "divu  %d, %d", a, b );
        default     : $sformat( full_str, "undefined func" );
      endcase
    end

  end

  // Tiny string sized for 2 characters

  reg [2*8-1:0] tiny_str;
  always @(*) begin

    if ( msg === `IMULDIV_DIVREQ_MSG_SZ'bx )
      $sformat( tiny_str, "x ");
    else begin
      case ( func )
        fn_signed   : $sformat( tiny_str, "/ "  );
        fn_unsigned : $sformat( tiny_str, "/u"  );
        default     : $sformat( tiny_str, "??"  );
      endcase
    end

  end

endmodule
`endif /* SYNTHESIS */

`endif /* IMULDIV_MULDIVREQ_MSG_V */


