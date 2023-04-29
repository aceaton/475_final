//=========================================================================
// 7-Stage RISCV ALU
//=========================================================================

`ifndef RISCV_CORE_DPATH_ALU_V
`define RISCV_CORE_DPATH_ALU_V

//-------------------------------------------------------------------------
// addsub unit
//-------------------------------------------------------------------------

module riscv_CoreDpathAluAddSub
(
  input      [ 1:0] addsub_fn, // 00 = add, 01 = sub, 10 = slt, 11 = sltu
  input      [31:0] alu_a,     // A operand
  input      [31:0] alu_b,     // B operand
  output reg [31:0] result     // result
);

  // We use one adder to perform both additions and subtractions
  wire [31:0] xB  = ( addsub_fn != 2'b00 ) ? ( ~alu_b + 1 ) : alu_b;
  wire [31:0] sum = alu_a + xB;

  wire diffSigns = alu_a[31] ^ alu_b[31];

  always @(*)
  begin

    if (( addsub_fn == 2'b00 ) || ( addsub_fn == 2'b01 ))
      result = sum;

    // Logic for signed set less than
    else if ( addsub_fn == 2'b10 )
    begin

      // If the signs of alu_a and alu_b are different then one is
      // negative and one is positive. If alu_a is the positive one then
      // it is not less than alu_b, and if alu_a is the negative one then
      // it is less than alu_b.

      if ( diffSigns )
        if ( alu_a[31] == 1'b0 )    // alu_a is positive
          result = { 31'b0, 1'b0 };
        else                        // alu_a is negative
          result = { 31'b0, 1'b1 };

      // If the signs of alu_a and alu_b are the same then we look at the
      // result from (alu_a - alu_b). If this is positive then alu_a is
      // not less than alu_b, and if this is negative then alu_a is
      // indeed less than alu_b.

      else
        if ( sum[31] == 1'b0 )      // (alu_a - alu_b) is positive
          result = { 31'b0, 1'b0 };
        else                        // (alu_a - alu_b) is negative
          result = { 31'b0, 1'b1 };

    end

    // Logic for unsigned set less than
    else if ( addsub_fn == 2'b11 )

      // If the MSB of alu_a and alu_b are different then the one with a
      // one in the MSB is greater than the other. If alu_a has a one in
      // the MSB then it is not less than alu_b, and if alu_a has a zero
      // in the MSB then it is less than alu_b.

      if ( diffSigns )
        if ( alu_a[31] == 1'b1 )    // alu_a is the greater one
          result = { 31'b0, 1'b0 };
        else                        // alu_a is the smaller one
          result = { 31'b0, 1'b1 };

      // If the MSB of alu_a and alu_b are the same then we look at the
      // result from (alu_a - alu_b). If this is positive then alu_a is
      // not less than alu_b, and if this is negative then alu_a is
      // indeed less than alu_b.

      else
        if ( sum[31] == 1'b0 )      // (alu_a - alu_b) is positive
          result = { 31'b0, 1'b0 };
        else                        // (alu_a - alu_b) is negative
          result = { 31'b0, 1'b1 };

    else
      result = 32'bx;

  end

endmodule

//-------------------------------------------------------------------------
// shifter unit
//-------------------------------------------------------------------------

module riscv_CoreDpathAluShifter
(
  input  [ 1:0] shift_fn,  // 00 = lsl, 01 = lsr, 11 = asr
  input  [31:0] alu_a,     // Shift ammount
  input  [31:0] alu_b,     // Operand to shift
  output [31:0] result     // result
);

  // We need this to make sure that we get a signed right shift
  wire signed [31:0] signed_alu_b = alu_b;
  wire signed [31:0] signed_result = signed_alu_b >>> alu_a[4:0];

  assign result
    = ( shift_fn == 2'b00 ) ? ( alu_b << alu_a[4:0] ) :
      ( shift_fn == 2'b01 ) ? ( alu_b >> alu_a[4:0] ) :
      ( shift_fn == 2'b11 ) ? signed_result :
                              ( 32'bx );

endmodule

//-------------------------------------------------------------------------
// logical unit
//-------------------------------------------------------------------------

module riscv_CoreDpathAluLogical
(
  input  [1:0]  logical_fn, // 00 = and, 01 = or, 10 = xor, 11 = nor
  input  [31:0] alu_a,
  input  [31:0] alu_b,
  output [31:0] result
);

  assign result
    = ( logical_fn == 2'b00 ) ?  ( alu_a & alu_b ) :
      ( logical_fn == 2'b01 ) ?  ( alu_a | alu_b ) :
      ( logical_fn == 2'b10 ) ?  ( alu_a ^ alu_b ) :
      ( logical_fn == 2'b11 ) ? ~( alu_a | alu_b ) :
                                 ( 32'bx );

endmodule

//------------------------------------------------------------------------
// muldiv unit
//------------------------------------------------------------------------

module riscv_CoreDpathAluMulDiv
(
  input      [ 2:0] muldiv_fn, // 00 = mul, 01 = div, 10 = divu, 11 = rem, 100 = remu
  input      [31:0] alu_a,     // A operand
  input      [31:0] alu_b,     // B operand
  output     [31:0] result     // result
);

  wire              negative   = ( alu_a[31] ^ alu_b[31] );

  wire       [31:0] alu_a_u    = ( alu_a[31] == 1'b1 ) ? ( ~alu_a + 1 )
                               :                         alu_a;
  wire       [31:0] alu_b_u    = ( alu_b[31] == 1'b1 ) ? ( ~alu_b + 1 )
                               :                         alu_b;

  wire       [31:0] product    = alu_a * alu_b;
  wire       [31:0] quotientu  = alu_a / alu_b;
  wire       [31:0] remainderu = alu_a % alu_b;

  wire       [31:0] quotient_raw   = alu_a_u / alu_b_u;
  wire       [31:0] remainder_raw  = alu_a_u % alu_b_u;

  wire       [31:0] quotient       = negative  ? ( ~quotient_raw + 1 )
                                   :             quotient_raw;

  // Remainder is same sign as dividend
  wire       [31:0] remainder      = alu_a[31] ? ( ~remainder_raw + 1 )
                                   :             remainder_raw;

  assign result = ( muldiv_fn == 3'd0 ) ? product
                : ( muldiv_fn == 3'd1 ) ? quotient
                : ( muldiv_fn == 3'd2 ) ? quotientu
                : ( muldiv_fn == 3'd3 ) ? remainder
                : ( muldiv_fn == 3'd4 ) ? remainderu
                :                         32'bx;

endmodule

//-------------------------------------------------------------------------
// Main alu
//-------------------------------------------------------------------------

module riscv_CoreDpathAlu
(
  input  [31:0] in0,
  input  [31:0] in1,
  input  [ 3:0] fn,
  output [31:0] out
);

  // -- Decoder ----------------------------------------------------------

  reg [1:0] out_mux_sel;
  reg [1:0] fn_addsub;
  reg [1:0] fn_shifter;
  reg [1:0] fn_logical;
  reg [2:0] fn_muldiv;

  reg [10:0] cs;

  always @(*)
  begin

    cs = 11'bx;
    case ( fn )
      4'd0  : cs = { 2'd0, 2'b00, 2'bxx, 2'bxx, 3'bxx  }; // ADD
      4'd1  : cs = { 2'd0, 2'b01, 2'bxx, 2'bxx, 3'bxx  }; // SUB
      4'd2  : cs = { 2'd1, 2'bxx, 2'b00, 2'bxx, 3'bxx  }; // SLL
      4'd3  : cs = { 2'd2, 2'bxx, 2'bxx, 2'b01, 3'bxx  }; // OR
      4'd4  : cs = { 2'd0, 2'b10, 2'bxx, 2'bxx, 3'bxx  }; // SLT
      4'd5  : cs = { 2'd0, 2'b11, 2'bxx, 2'bxx, 3'bxx  }; // SLTU
      4'd6  : cs = { 2'd2, 2'bxx, 2'bxx, 2'b00, 3'bxx  }; // AND
      4'd7  : cs = { 2'd2, 2'bxx, 2'bxx, 2'b10, 3'bxx  }; // XOR
      4'd8  : cs = { 2'd2, 2'bxx, 2'bxx, 2'b11, 3'bxx  }; // NOR
      4'd9  : cs = { 2'd1, 2'bxx, 2'b01, 2'bxx, 3'bxx  }; // SRL
      4'd10 : cs = { 2'd1, 2'bxx, 2'b11, 2'bxx, 3'bxx  }; // SRA
      4'd11 : cs = { 2'd3, 2'bxx, 2'bxx, 2'bxx, 3'b000 }; // MUL
      4'd12 : cs = { 2'd3, 2'bxx, 2'bxx, 2'bxx, 3'b001 }; // DIV
      4'd13 : cs = { 2'd3, 2'bxx, 2'bxx, 2'bxx, 3'b010 }; // DIVU
      4'd14 : cs = { 2'd3, 2'bxx, 2'bxx, 2'bxx, 3'b011 }; // REM
      4'd15 : cs = { 2'd3, 2'bxx, 2'bxx, 2'bxx, 3'b100 }; // REMU
    endcase

    { out_mux_sel, fn_addsub, fn_shifter, fn_logical, fn_muldiv } = cs;

  end

  // -- Functional units -------------------------------------------------

  wire [31:0] addsub_out;

  riscv_CoreDpathAluAddSub addsub
  (
    .addsub_fn  (fn_addsub),
    .alu_a      (in0),
    .alu_b      (in1),
    .result     (addsub_out)
  );

  wire [31:0] shifter_out;

  riscv_CoreDpathAluShifter shifter
  (
    .shift_fn   (fn_shifter),
    .alu_a      (in1),
    .alu_b      (in0),
    .result     (shifter_out)
  );

  wire [31:0] logical_out;

  riscv_CoreDpathAluLogical logical
  (
    .logical_fn (fn_logical),
    .alu_a      (in0),
    .alu_b      (in1),
    .result     (logical_out)
  );

  wire [31:0] muldiv_out;

  riscv_CoreDpathAluMulDiv muldiv
  (
    .muldiv_fn  (fn_muldiv),
    .alu_a      (in0),
    .alu_b      (in1),
    .result     (muldiv_out)
  );

  // -- Final output mux -------------------------------------------------

  assign out = ( out_mux_sel == 2'd0 ) ? addsub_out
             : ( out_mux_sel == 2'd1 ) ? shifter_out
             : ( out_mux_sel == 2'd2 ) ? logical_out
             : ( out_mux_sel == 2'd3 ) ? muldiv_out
             :                           32'bx;

endmodule

`endif

