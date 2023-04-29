//========================================================================
// Unit Tests: Instruction Type
//========================================================================

`include "riscvlong-InstMsg.v"
`include "vc-Test.v"

module tester;
  `VC_TEST_SUITE_BEGIN( "riscv-InstMsg" )

  //----------------------------------------------------------------------
  // R-type Inst
  //----------------------------------------------------------------------

  reg [`RISCV_INST_MSG_SZ-1:0] t1_msg_test;
  reg [`RISCV_INST_MSG_SZ-1:0] t1_msg_ref;

  riscv_InstMsgDisasm t1_inst_msg_disasm( t1_msg_test );

  task t1_do_test
  (
    input [`RISCV_INST_MSG_OPCODE_SZ-1:0] opcode,
    input [   `RISCV_INST_MSG_RS1_SZ-1:0] rs1,
    input [   `RISCV_INST_MSG_RS2_SZ-1:0] rs2,
    input [    `RISCV_INST_MSG_RD_SZ-1:0] rd,
    input [`RISCV_INST_MSG_FUNCT3_SZ-1:0] funct3,
    input [`RISCV_INST_MSG_FUNCT7_SZ-1:0] funct7
  );
  begin

    // Create a wire and set msg fields using `defines

    t1_msg_test[`RISCV_INST_MSG_OPCODE] = opcode;
    t1_msg_test[   `RISCV_INST_MSG_RS1] = rs1;
    t1_msg_test[   `RISCV_INST_MSG_RS2] = rs2;
    t1_msg_test[    `RISCV_INST_MSG_RD] = rd;
    t1_msg_test[`RISCV_INST_MSG_FUNCT3] = funct3;
    t1_msg_test[`RISCV_INST_MSG_FUNCT7] = funct7;

    // Create a wire and set msg fields using concatentation

    t1_msg_ref = { funct7, rs2, rs1, funct3, rd, opcode };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( t1_inst_msg_disasm.dasm, t1_msg_test, t1_msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 1, "R-type Inst" )
  begin

    t1_do_test( 7'b0110011, 5'd0,  5'd3,  5'd4,  3'b000, 7'b0000000 ); // ADD
    t1_do_test( 7'b0110011, 5'd31, 5'd9,  5'd20, 3'b000, 7'b0100000 ); // SUB
    t1_do_test( 7'b0110011, 5'd19, 5'd12, 5'd0,  3'b001, 7'b0000000 ); // SLL
    t1_do_test( 7'b0110011, 5'd7,  5'd0,  5'd0,  3'b000, 7'b0000001 ); // MUL
    t1_do_test( 7'b0110011, 5'd0,  5'd15, 5'd0,  3'b100, 7'b0000001 ); // DIV

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // I-type Inst
  //----------------------------------------------------------------------

  reg [`RISCV_INST_MSG_SZ-1:0] t2_msg_test;
  reg [`RISCV_INST_MSG_SZ-1:0] t2_msg_ref;

  riscv_InstMsgDisasm t2_inst_msg_disasm( t2_msg_test );

  task t2_do_test
  (
    input [`RISCV_INST_MSG_OPCODE_SZ-1:0] opcode,
    input [   `RISCV_INST_MSG_RS1_SZ-1:0] rs1,
    input [    `RISCV_INST_MSG_RD_SZ-1:0] rd,
    input [`RISCV_INST_MSG_FUNCT3_SZ-1:0] funct3,
    input [   `RISCV_INST_MSG_IMM_SZ-1:0] imm
  );
  begin

    // Create a wire and set msg fields using `defines

    t2_msg_test[   `RISCV_INST_MSG_OPCODE] = opcode;
    t2_msg_test[      `RISCV_INST_MSG_RS1] = rs1;
    t2_msg_test[       `RISCV_INST_MSG_RD] = rd;
    t2_msg_test[   `RISCV_INST_MSG_FUNCT3] = funct3;
    t2_msg_test[ `RISCV_INST_MSG_IMM_SIGN] = imm[11];
    t2_msg_test[ `RISCV_INST_MSG_IMM_10_5] = imm[10:5];
    t2_msg_test[`RISCV_INST_MSG_IMM_4_0_I] = imm[4:0];

    // Create a wire and set msg fields using concatentation

    t2_msg_ref = {imm[11:0], rs1, funct3, rd, opcode};

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( t2_inst_msg_disasm.dasm, t2_msg_test, t2_msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 2, "I-type Inst" )
  begin

    t2_do_test( 7'b0010011, 5'd19, 5'd15, 3'b000, 32'hffff_f8ad );  // ADDI
    t2_do_test( 7'b0010011, 5'd3,  5'd2,  3'b110, 32'h0000_04be );  // ORI
    t2_do_test( 7'b0010011, 5'd30, 5'd12, 3'b011, 32'hffff_fabc );  // SLTI
    t2_do_test( 7'b0010011, 5'd10, 5'd28, 3'b101, 32'h0000_0410 );  // SRAI

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // S-type Inst
  //----------------------------------------------------------------------

  reg [`RISCV_INST_MSG_SZ-1:0] t3_msg_test;
  reg [`RISCV_INST_MSG_SZ-1:0] t3_msg_ref;

  riscv_InstMsgDisasm t3_inst_msg_disasm( t3_msg_test );

  task t3_do_test
  (
    input [`RISCV_INST_MSG_OPCODE_SZ-1:0] opcode,
    input [   `RISCV_INST_MSG_RS1_SZ-1:0] rs1,
    input [   `RISCV_INST_MSG_RS2_SZ-1:0] rs2,
    input [`RISCV_INST_MSG_FUNCT3_SZ-1:0] funct3,
    input [   `RISCV_INST_MSG_IMM_SZ-1:0] imm
  );
  begin

    // Create a wire and set msg fields using `defines

    t3_msg_test[   `RISCV_INST_MSG_OPCODE] = opcode;
    t3_msg_test[      `RISCV_INST_MSG_RS1] = rs1;
    t3_msg_test[      `RISCV_INST_MSG_RS2] = rs2;
    t3_msg_test[   `RISCV_INST_MSG_FUNCT3] = funct3;
    t3_msg_test[ `RISCV_INST_MSG_IMM_SIGN] = imm[11];
    t3_msg_test[ `RISCV_INST_MSG_IMM_10_5] = imm[10:5];
    t3_msg_test[`RISCV_INST_MSG_IMM_4_0_S] = imm[4:0];


    // Create a wire and set msg fields using concatentation

    t3_msg_ref = { imm[11:5], rs2, rs1, funct3, imm[4:0], opcode };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( t3_inst_msg_disasm.dasm, t3_msg_test, t3_msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 3, "S-type Inst" )
  begin

    t3_do_test( 7'b0100011, 5'd12, 5'd0,  3'b010, 32'hffff_ffff ); // SW
    t3_do_test( 7'b0100011, 5'd31, 5'd19, 3'b000, 32'h0000_0120 ); // SB

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // SB-type Inst
  //----------------------------------------------------------------------

  reg [`RISCV_INST_MSG_SZ-1:0] t4_msg_test;
  reg [`RISCV_INST_MSG_SZ-1:0] t4_msg_ref;

  riscv_InstMsgDisasm t4_inst_msg_disasm( t4_msg_test );

  task t4_do_test
  (
    input [`RISCV_INST_MSG_OPCODE_SZ-1:0] opcode,
    input [   `RISCV_INST_MSG_RS1_SZ-1:0] rs1,
    input [   `RISCV_INST_MSG_RS2_SZ-1:0] rs2,
    input [`RISCV_INST_MSG_FUNCT3_SZ-1:0] funct3,
    input [   `RISCV_INST_MSG_IMM_SZ-1:0] imm
  );
  begin

    // Create a wire and set msg fields using `defines

    t4_msg_test[    `RISCV_INST_MSG_OPCODE] = opcode;
    t4_msg_test[       `RISCV_INST_MSG_RS1] = rs1;
    t4_msg_test[       `RISCV_INST_MSG_RS2] = rs2;
    t4_msg_test[    `RISCV_INST_MSG_FUNCT3] = funct3;
    t4_msg_test[  `RISCV_INST_MSG_IMM_SIGN] = imm[12];
    t4_msg_test[ `RISCV_INST_MSG_IMM_11_SB] = imm[11];
    t4_msg_test[  `RISCV_INST_MSG_IMM_10_5] = imm[10:5];
    t4_msg_test[`RISCV_INST_MSG_IMM_4_1_SB] = imm[4:1];


    // Create a wire and set msg fields using concatentation

    t4_msg_ref = { imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( t4_inst_msg_disasm.dasm, t4_msg_test, t4_msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 4, "SB-type Inst" )
  begin

    t4_do_test( 7'b1100011, 5'd17, 5'd30, 3'b000, 32'h0000_0bef ); // BEQ
    t4_do_test( 7'b1100011, 5'd0,  5'd4,  3'b100, 32'hffff_f01c ); // BLT

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // U-type Inst
  //----------------------------------------------------------------------

  reg [`RISCV_INST_MSG_SZ-1:0] t5_msg_test;
  reg [`RISCV_INST_MSG_SZ-1:0] t5_msg_ref;

  riscv_InstMsgDisasm t5_inst_msg_disasm( t5_msg_test );

  task t5_do_test
  (
    input [`RISCV_INST_MSG_OPCODE_SZ-1:0] opcode,
    input [    `RISCV_INST_MSG_RD_SZ-1:0] rd,
    input [   `RISCV_INST_MSG_IMM_SZ-1:0] imm
  );
  begin

    // Create a wire and set msg fields using `defines

    t5_msg_test[     `RISCV_INST_MSG_OPCODE] = opcode;
    t5_msg_test[         `RISCV_INST_MSG_RD] = rd;
    t5_msg_test[`RISCV_INST_MSG_IMM_31_12_U] = imm[31:12];


    // Create a wire and set msg fields using concatentation

    t5_msg_ref = { imm[31:12], rd, opcode };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( t5_inst_msg_disasm.dasm, t5_msg_test, t5_msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 5, "U-type Inst" )
  begin

    t5_do_test( 7'b0110111, 5'd17, 32'hdead_beef ); // LUI
    t5_do_test( 7'b0010111, 5'd0,  32'h4c1b_bea8 ); // AUIPC

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // UJ-type Inst
  //----------------------------------------------------------------------

  reg [`RISCV_INST_MSG_SZ-1:0] t6_msg_test;
  reg [`RISCV_INST_MSG_SZ-1:0] t6_msg_ref;

  riscv_InstMsgDisasm t6_inst_msg_disasm( t6_msg_test );

  task t6_do_test
  (
    input [`RISCV_INST_MSG_OPCODE_SZ-1:0] opcode,
    input [    `RISCV_INST_MSG_RD_SZ-1:0] rd,
    input [   `RISCV_INST_MSG_IMM_SZ-1:0] imm
  );
  begin

    // Create a wire and set msg fields using `defines

    t6_msg_test[      `RISCV_INST_MSG_OPCODE] = opcode;
    t6_msg_test[          `RISCV_INST_MSG_RD] = rd;
    t6_msg_test[    `RISCV_INST_MSG_IMM_SIGN] = imm[20];
    t6_msg_test[`RISCV_INST_MSG_IMM_19_12_UJ] = imm[19:12];
    t6_msg_test[   `RISCV_INST_MSG_IMM_11_UJ] = imm[11];
    t6_msg_test[    `RISCV_INST_MSG_IMM_10_5] = imm[10:5];
    t6_msg_test[  `RISCV_INST_MSG_IMM_4_1_UJ] = imm[4:1];

    // Create a wire and set msg fields using concatentation

    t6_msg_ref = { imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode };

    // Check that both msgs are the same

    #1;
    `VC_TEST_EQ( t6_inst_msg_disasm.dasm, t6_msg_test, t6_msg_ref )
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 6, "UJ-type Inst" )
  begin

    t6_do_test( 7'b1101111, 5'd0,  32'h0004_dfca ); // JAL
    t6_do_test( 7'b1100111, 5'd31, 32'hffff_1042 ); // JALR

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 6 )
endmodule

// vim: set textwidth=0 ts=2 sw=2 sts=2 :
