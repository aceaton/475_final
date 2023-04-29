//========================================================================
// RISCV Instruction Type
//========================================================================
// Instruction types are similar to message types but are strictly used
// for communication between the control and datapath of a RISCV-based
// processor. Instruction "messages" can be unpacked into the various
// fields as defined by the RISCV ISA, as well as be constructed from
// specifying each field explicitly. The 32-bit instruction has different
// fields depending on the format of the instruction used. The following
// are the various instruction encoding formats used in the RISCV ISA.
//
// R-type:
//
//   31                 25 24             20 19     15 14    12 11                 7 6      0
//  +---------------------+-----------------+---------+--------+--------------------+--------+
//  |       funct7        |       rs2       |   rs1   | funct3 |         rd         | opcode |
//  +---------------------+-----------------+---------+--------+--------------------+--------+
//
// I-type:
//
//   31                                   20 19     15 14    12 11                 7 6      0
//  +---------------------+-----------------+---------+--------+--------------------+--------+
//  |               imm[11:0]               |   rs1   | funct3 |         rd         | opcode |
//  +---------------------+-----------------+---------+--------+--------------------+--------+
//
// S-type:
//
//   31                 25 24             20 19     15 14    12 11                 7 6      0
//  +---------------------+-----------------+---------+--------+--------------------+--------+
//  |      imm[11:5]      |       rs2       |   rs1   | funct3 |      imm[4:0]      | opcode |
//  +---------------------+-----------------+---------+--------+--------------------+--------+
//
// SB-type:
//
//   31        30       25 24             20 19     15 14    12 11       8         7 6      0
//  +---------+-----------+-----------------+---------+--------+----------+---------+--------+
//  | imm[12] | imm[10:5] |       rs2       |   rs1   | funct3 | imm[4:1] | imm[11] | opcode |
//  +---------+-----------+-----------------+---------+--------+----------+---------+--------+
//
// U-type:
//
//   31                                                      12 11                 7 6      0
//  +----------------------------------------------------------+--------------------+--------+
//  |                        imm[31:12]                        |         rd         | opcode |
//  +----------------------------------------------------------+--------------------+--------+
//
// UJ-type:
//
//   31        30               21        20 19              12 11                 7 6      0
//  +---------+-------------------+---------+------------------+--------------------+--------+
//  | imm[20] |     imm[10:1]     | imm[11] |    imm[19:12]    |          rd        | opcode |
//  +---------+-------------------+---------+------------------+--------------------+--------+
//
// The instruction type also defines a list of instruction encodings in
// the RISCV ISA, which are used to decode instructions in the control unit.

`ifndef RISCV_INST_MSG_V
`define RISCV_INST_MSG_V

//------------------------------------------------------------------------
// Instruction fields
//------------------------------------------------------------------------

`define RISCV_INST_MSG_OPCODE   6:0
`define RISCV_INST_MSG_RD       11:7
`define RISCV_INST_MSG_FUNCT3   14:12
`define RISCV_INST_MSG_RS1      19:15
`define RISCV_INST_MSG_RS2      24:20
`define RISCV_INST_MSG_FUNCT7   31:25
`define RISCV_INST_MSG_SHAMT    24:20

// A lot of shit here
`define RISCV_INST_MSG_IMM_SIGN     31:31
`define RISCV_INST_MSG_IMM_10_5     30:25
`define RISCV_INST_MSG_IMM_4_0_I    24:20
`define RISCV_INST_MSG_IMM_4_0_S    11:7
`define RISCV_INST_MSG_IMM_11_SB    7:7
`define RISCV_INST_MSG_IMM_4_1_SB   11:8
`define RISCV_INST_MSG_IMM_31_12_U  31:12
`define RISCV_INST_MSG_IMM_19_12_UJ 19:12
`define RISCV_INST_MSG_IMM_11_UJ    20:20
`define RISCV_INST_MSG_IMM_4_1_UJ   24:21

//------------------------------------------------------------------------
// Field sizes
//------------------------------------------------------------------------

`define RISCV_INST_MSG_SZ           32

`define RISCV_INST_MSG_OPCODE_SZ    7
`define RISCV_INST_MSG_RS1_SZ       5
`define RISCV_INST_MSG_RS2_SZ       5
`define RISCV_INST_MSG_RD_SZ        5
`define RISCV_INST_MSG_FUNCT3_SZ    3
`define RISCV_INST_MSG_FUNCT7_SZ    7
`define RISCV_INST_MSG_IMM_SZ       32
`define RISCV_INST_MSG_SHAMT_SZ     5

//------------------------------------------------------------------------
// Instruction opcodes
//------------------------------------------------------------------------

// RISCV32I
`define RISCV_INST_MSG_LUI      32'b???????_?????_?????_???_?????_0110111
`define RISCV_INST_MSG_AUIPC    32'b???????_?????_?????_???_?????_0010111
`define RISCV_INST_MSG_JAL      32'b???????_?????_?????_???_?????_1101111
`define RISCV_INST_MSG_JALR     32'b???????_?????_?????_000_?????_1100111
`define RISCV_INST_MSG_BEQ      32'b???????_?????_?????_000_?????_1100011
`define RISCV_INST_MSG_BNE      32'b???????_?????_?????_001_?????_1100011
`define RISCV_INST_MSG_BLT      32'b???????_?????_?????_100_?????_1100011
`define RISCV_INST_MSG_BGE      32'b???????_?????_?????_101_?????_1100011
`define RISCV_INST_MSG_BLTU     32'b???????_?????_?????_110_?????_1100011
`define RISCV_INST_MSG_BGEU     32'b???????_?????_?????_111_?????_1100011
`define RISCV_INST_MSG_LB       32'b???????_?????_?????_000_?????_0000011
`define RISCV_INST_MSG_LH       32'b???????_?????_?????_001_?????_0000011
`define RISCV_INST_MSG_LW       32'b???????_?????_?????_010_?????_0000011
`define RISCV_INST_MSG_LBU      32'b???????_?????_?????_100_?????_0000011
`define RISCV_INST_MSG_LHU      32'b???????_?????_?????_101_?????_0000011
`define RISCV_INST_MSG_SB       32'b???????_?????_?????_000_?????_0100011
`define RISCV_INST_MSG_SH       32'b???????_?????_?????_001_?????_0100011
`define RISCV_INST_MSG_SW       32'b???????_?????_?????_010_?????_0100011
`define RISCV_INST_MSG_ADDI     32'b???????_?????_?????_000_?????_0010011
`define RISCV_INST_MSG_NOP      32'b0000000_00000_00000_000_00000_0010011
  // DO NOT IMPLEMENT THE *NOP* INSTRUCTION IN YOUR CONTROL MODULE.
`define RISCV_INST_MSG_SLTI     32'b???????_?????_?????_010_?????_0010011
`define RISCV_INST_MSG_SLTIU    32'b???????_?????_?????_011_?????_0010011
`define RISCV_INST_MSG_XORI     32'b???????_?????_?????_100_?????_0010011
`define RISCV_INST_MSG_ORI      32'b???????_?????_?????_110_?????_0010011
`define RISCV_INST_MSG_ANDI     32'b???????_?????_?????_111_?????_0010011
`define RISCV_INST_MSG_SLLI     32'b0000000_?????_?????_001_?????_0010011
`define RISCV_INST_MSG_SRLI     32'b0000000_?????_?????_101_?????_0010011
`define RISCV_INST_MSG_SRAI     32'b0100000_?????_?????_101_?????_0010011
`define RISCV_INST_MSG_ADD      32'b0000000_?????_?????_000_?????_0110011
`define RISCV_INST_MSG_SUB      32'b0100000_?????_?????_000_?????_0110011
`define RISCV_INST_MSG_SLL      32'b0000000_?????_?????_001_?????_0110011
`define RISCV_INST_MSG_SLT      32'b0000000_?????_?????_010_?????_0110011
`define RISCV_INST_MSG_SLTU     32'b0000000_?????_?????_011_?????_0110011
`define RISCV_INST_MSG_XOR      32'b0000000_?????_?????_100_?????_0110011
`define RISCV_INST_MSG_SRL      32'b0000000_?????_?????_101_?????_0110011
`define RISCV_INST_MSG_SRA      32'b0100000_?????_?????_101_?????_0110011
`define RISCV_INST_MSG_OR       32'b0000000_?????_?????_110_?????_0110011
`define RISCV_INST_MSG_AND      32'b0000000_?????_?????_111_?????_0110011
`define RISCV_INST_MSG_CSRW     32'b???????_?????_?????_001_00000_1110011   // pseudo inst based on CSRRW.
// Omitted: FENCE, FENCE.I, ECALL, EBREAK, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI
// RISCV32M
`define RISCV_INST_MSG_MUL      32'b0000001_?????_?????_000_?????_0110011
`define RISCV_INST_MSG_MULH     32'b0000001_?????_?????_001_?????_0110011  // not supported.
`define RISCV_INST_MSG_MULHSU   32'b0000001_?????_?????_010_?????_0110011  // not supported.
`define RISCV_INST_MSG_MULHU    32'b0000001_?????_?????_011_?????_0110011  // not supported.
`define RISCV_INST_MSG_DIV      32'b0000001_?????_?????_100_?????_0110011
`define RISCV_INST_MSG_DIVU     32'b0000001_?????_?????_101_?????_0110011
`define RISCV_INST_MSG_REM      32'b0000001_?????_?????_110_?????_0110011
`define RISCV_INST_MSG_REMU     32'b0000001_?????_?????_111_?????_0110011

//------------------------------------------------------------------------
// Control bundle
//------------------------------------------------------------------------

`define RISCV_INST_MSG_CS_SZ      39
`define RISCV_INST_MSG_INST_VAL   38:38
`define RISCV_INST_MSG_J_EN       37:37
`define RISCV_INST_MSG_BR_SEL     36:34
`define RISCV_INST_MSG_PC_SEL     33:32
`define RISCV_INST_MSG_OP0_SEL    31:30
`define RISCV_INST_MSG_RS1_EN     29:29
`define RISCV_INST_MSG_OP1_SEL    28:26
`define RISCV_INST_MSG_RS2_EN     25:25
`define RISCV_INST_MSG_ALU_FN     24:21
`define RISCV_INST_MSG_MULDIV_FN  20:18
`define RISCV_INST_MSG_MULDIV_EN  17:17
`define RISCV_INST_MSG_MULDIV_SEL 16:16
`define RISCV_INST_MSG_EX_SEL     15:15
`define RISCV_INST_MSG_MEM_REQ    14:13
`define RISCV_INST_MSG_MEM_LEN    12:11
`define RISCV_INST_MSG_MEM_SEL    10:8
`define RISCV_INST_MSG_WB_SEL     7:7
`define RISCV_INST_MSG_RF_WEN     6:6
`define RISCV_INST_MSG_RF_WADDR   5:1
`define RISCV_INST_MSG_CSR_WEN    0:0

//------------------------------------------------------------------------
// Convert message to bits
//------------------------------------------------------------------------

/*
module riscv_RegRegInstMsgToBits
(
  // Input message

  input [`RISCV_INST_MSG_OPCODE_SZ-1:0] opcode,
  input [    `RISCV_INST_MSG_RS_SZ-1:0] rs,
  input [    `RISCV_INST_MSG_RT_SZ-1:0] rt,
  input [    `RISCV_INST_MSG_RD_SZ-1:0] rd,
  input [ `RISCV_INST_MSG_SHAMT_SZ-1:0] shamt,
  input [  `RISCV_INST_MSG_FUNC_SZ-1:0] func,

  // Output message

  output [`RISCV_INST_MSG_SZ-1:0] msg
);

  assign msg[`RISCV_INST_MSG_OPCODE] = opcode;
  assign msg[    `RISCV_INST_MSG_RS] = rs;
  assign msg[    `RISCV_INST_MSG_RT] = rt;
  assign msg[    `RISCV_INST_MSG_RD] = rd;
  assign msg[ `RISCV_INST_MSG_SHAMT] = shamt;
  assign msg[  `RISCV_INST_MSG_FUNC] = func;

endmodule

module riscv_RegImmInstMsgToBits
(
  // Input message

  input [`RISCV_INST_MSG_OPCODE_SZ-1:0] opcode,
  input [    `RISCV_INST_MSG_RS_SZ-1:0] rs,
  input [    `RISCV_INST_MSG_RT_SZ-1:0] rt,
  input [   `RISCV_INST_MSG_IMM_SZ-1:0] imm,

  // Output message

  output [`RISCV_INST_MSG_SZ-1:0] msg
);

  assign msg[`RISCV_INST_MSG_OPCODE] = opcode;
  assign msg[    `RISCV_INST_MSG_RS] = rs;
  assign msg[    `RISCV_INST_MSG_RT] = rt;
  assign msg[   `RISCV_INST_MSG_IMM] = imm;

endmodule

module riscv_TargInstMsgToBits
(
  // Input message

  input [`RISCV_INST_MSG_OPCODE_SZ-1:0] opcode,
  input [`RISCV_INST_MSG_TARGET_SZ-1:0] target,

  // Output message

  output [`RISCV_INST_MSG_SZ-1:0] msg
);

  assign msg[`RISCV_INST_MSG_OPCODE] = opcode;
  assign msg[`RISCV_INST_MSG_TARGET] = target;

endmodule
    */

//------------------------------------------------------------------------
// Convert message from bits
//------------------------------------------------------------------------

module riscv_InstMsgFromBits
(
  // Input message

  input [`RISCV_INST_MSG_SZ-1:0] msg,

  // Output message

  output [  `RISCV_INST_MSG_OPCODE_SZ-1:0] opcode,
  output [     `RISCV_INST_MSG_RS1_SZ-1:0] rs1,
  output [     `RISCV_INST_MSG_RS2_SZ-1:0] rs2,
  output [      `RISCV_INST_MSG_RD_SZ-1:0] rd,
  output [  `RISCV_INST_MSG_FUNCT7_SZ-1:0] funct7,
  output [  `RISCV_INST_MSG_FUNCT3_SZ-1:0] funct3,
  output [   `RISCV_INST_MSG_SHAMT_SZ-1:0] shamt,
  output [     `RISCV_INST_MSG_IMM_SZ-1:0] imm_i,
  output [     `RISCV_INST_MSG_IMM_SZ-1:0] imm_s,
  output [     `RISCV_INST_MSG_IMM_SZ-1:0] imm_sb,
  output [     `RISCV_INST_MSG_IMM_SZ-1:0] imm_u,
  output [     `RISCV_INST_MSG_IMM_SZ-1:0] imm_uj

);

  assign opcode   = msg[  `RISCV_INST_MSG_OPCODE];
  assign rs1      = msg[     `RISCV_INST_MSG_RS1];
  assign rs2      = msg[     `RISCV_INST_MSG_RS2];
  assign rd       = msg[      `RISCV_INST_MSG_RD];
  assign shamt    = msg[   `RISCV_INST_MSG_SHAMT];
  assign funct3   = msg[  `RISCV_INST_MSG_FUNCT3];
  assign funct7   = msg[  `RISCV_INST_MSG_FUNCT7];
  assign imm_i    = {{21{msg[`RISCV_INST_MSG_IMM_SIGN]}}, 
    msg[`RISCV_INST_MSG_IMM_10_5],
    msg[`RISCV_INST_MSG_IMM_4_0_I]};
  assign imm_s    = {{21{msg[`RISCV_INST_MSG_IMM_SIGN]}}, 
    msg[`RISCV_INST_MSG_IMM_10_5],
    msg[`RISCV_INST_MSG_IMM_4_0_S]};
  assign imm_sb   = {{20{msg[`RISCV_INST_MSG_IMM_SIGN]}}, 
    msg[`RISCV_INST_MSG_IMM_11_SB],
    msg[`RISCV_INST_MSG_IMM_10_5],
    msg[`RISCV_INST_MSG_IMM_4_1_SB],
    1'b0};
  assign imm_u    = {msg[`RISCV_INST_MSG_IMM_31_12_U],
    12'b0};
  assign imm_uj   = {{12{msg[`RISCV_INST_MSG_IMM_SIGN]}},
    msg[`RISCV_INST_MSG_IMM_19_12_UJ],
    msg[`RISCV_INST_MSG_IMM_11_UJ],
    msg[`RISCV_INST_MSG_IMM_10_5],
    msg[`RISCV_INST_MSG_IMM_4_1_UJ],
    1'b0};

endmodule

//------------------------------------------------------------------------
// Instruction disassembly
//------------------------------------------------------------------------

`ifndef SYNTHESIS
module riscv_InstMsgDisasm
(
  input [`RISCV_INST_MSG_SZ-1:0] msg
);

  // Extract fields

  wire [`RISCV_INST_MSG_OPCODE_SZ-1:0] opcode;
  wire [   `RISCV_INST_MSG_RS1_SZ-1:0] rs1;
  wire [   `RISCV_INST_MSG_RS2_SZ-1:0] rs2;
  wire [    `RISCV_INST_MSG_RD_SZ-1:0] rd;
  wire [ `RISCV_INST_MSG_SHAMT_SZ-1:0] shamt;
  wire [`RISCV_INST_MSG_FUNCT3_SZ-1:0] funct3;
  wire [`RISCV_INST_MSG_FUNCT7_SZ-1:0] funct7;
  wire [   `RISCV_INST_MSG_IMM_SZ-1:0] imm_i;
  wire [   `RISCV_INST_MSG_IMM_SZ-1:0] imm_s;
  wire [   `RISCV_INST_MSG_IMM_SZ-1:0] imm_sb;
  wire [   `RISCV_INST_MSG_IMM_SZ-1:0] imm_u;
  wire [   `RISCV_INST_MSG_IMM_SZ-1:0] imm_uj;

  riscv_InstMsgFromBits inst_msg_from_bits
  (
    .msg    (msg),
    .opcode (opcode),
    .rs1    (rs1),
    .rs2    (rs2),
    .rd     (rd),
    .shamt  (shamt),
    .funct3 (funct3),
    .funct7 (funct7),
    .imm_i  (imm_i),
    .imm_s  (imm_s),
    .imm_sb (imm_sb),
    .imm_u  (imm_u),
    .imm_uj (imm_uj)
  );

  reg [207:0] dasm;

  always @ ( * ) begin

    if ( msg === 32'bx ) begin
      $sformat( dasm,                             "x                        " );
    end
    else begin

      casez ( msg )
        // RISCV32I
        `RISCV_INST_MSG_NOP     : $sformat( dasm, "nop                      "                         );
        `RISCV_INST_MSG_LUI     : $sformat( dasm, "lui    r%02d, %08x     ",         rd,       imm_u  );
        `RISCV_INST_MSG_AUIPC   : $sformat( dasm, "auipc  r%02d, %08x     ",         rd,       imm_u  );
        `RISCV_INST_MSG_JAL     : $sformat( dasm, "jal    r%02d, %08x     ",         rd,       imm_uj );
        `RISCV_INST_MSG_JALR    : $sformat( dasm, "jalr   r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_BEQ     : $sformat( dasm, "beq    r%02d, r%02d, %08x",       rs1, rs2, imm_sb );
        `RISCV_INST_MSG_BNE     : $sformat( dasm, "bne    r%02d, r%02d, %08x",       rs1, rs2, imm_sb );
        `RISCV_INST_MSG_BLT     : $sformat( dasm, "blt    r%02d, r%02d, %08x",       rs1, rs2, imm_sb );
        `RISCV_INST_MSG_BGE     : $sformat( dasm, "bge    r%02d, r%02d, %08x",       rs1, rs2, imm_sb );
        `RISCV_INST_MSG_BLTU    : $sformat( dasm, "bltu   r%02d, r%02d, %08x",       rs1, rs2, imm_sb );
        `RISCV_INST_MSG_BGEU    : $sformat( dasm, "bgeu   r%02d, r%02d, %08x",       rs1, rs2, imm_sb );
        `RISCV_INST_MSG_LB      : $sformat( dasm, "lb     r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_LH      : $sformat( dasm, "lh     r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_LW      : $sformat( dasm, "lw     r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_LBU     : $sformat( dasm, "lbu    r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_LHU     : $sformat( dasm, "lhu    r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_SB      : $sformat( dasm, "sb     r%02d, r%02d, %08x",       rs2, rs1, imm_s  );
        `RISCV_INST_MSG_SH      : $sformat( dasm, "sh     r%02d, r%02d, %08x",       rs2, rs1, imm_s  );
        `RISCV_INST_MSG_SW      : $sformat( dasm, "sw     r%02d, r%02d, %08x",       rs2, rs1, imm_s  );
        `RISCV_INST_MSG_ADDI    : $sformat( dasm, "addi   r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_SLTI    : $sformat( dasm, "slti   r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_SLTIU   : $sformat( dasm, "sltiu  r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_ANDI    : $sformat( dasm, "andi   r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_ORI     : $sformat( dasm, "ori    r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_XORI    : $sformat( dasm, "xori   r%02d, r%02d, %08x",       rd,  rs1, imm_i  );
        `RISCV_INST_MSG_SLLI    : $sformat( dasm, "slli   r%02d, r%02d, %08x",       rd,  rs1, shamt  );
        `RISCV_INST_MSG_SRLI    : $sformat( dasm, "srli   r%02d, r%02d, %08x",       rd,  rs1, shamt  );
        `RISCV_INST_MSG_SRAI    : $sformat( dasm, "srai   r%02d, r%02d, %08x",       rd,  rs1, shamt  );
        `RISCV_INST_MSG_ADD     : $sformat( dasm, "add    r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_SUB     : $sformat( dasm, "sub    r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_SLL     : $sformat( dasm, "sll    r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_SLT     : $sformat( dasm, "slt    r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_SLTU    : $sformat( dasm, "sltu   r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_XOR     : $sformat( dasm, "xor    r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_SRL     : $sformat( dasm, "srl    r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_SRA     : $sformat( dasm, "sra    r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_OR      : $sformat( dasm, "or     r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_AND     : $sformat( dasm, "and    r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_CSRW    : $sformat( dasm, "csrw   r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        // RISCV32M
        `RISCV_INST_MSG_MUL     : $sformat( dasm, "mul    r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        // `RISCV_INST_MSG_MULH    : $sformat( dasm, "mulh   r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        // `RISCV_INST_MSG_MULHSU  : $sformat( dasm, "mulhsu r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        // `RISCV_INST_MSG_MULHU   : $sformat( dasm, "mulhu  r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_DIV     : $sformat( dasm, "div    r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_DIVU    : $sformat( dasm, "divu   r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_REM     : $sformat( dasm, "rem    r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        `RISCV_INST_MSG_REMU    : $sformat( dasm, "remu   r%02d, r%02d, r%02d     ", rd,  rs1, rs2    );
        default                : $sformat( dasm, "undefined inst       " );
      endcase

    end

  end

  reg [47:0] minidasm;

  always @ ( * )
  begin

    if ( msg === 32'bx )
      $sformat( minidasm, "x    " );
    else
    begin

      casez ( msg )
        // RISCV32I
        `RISCV_INST_MSG_NOP     : $sformat( minidasm, "nop   ");
        `RISCV_INST_MSG_LUI     : $sformat( minidasm, "lui   ");
        `RISCV_INST_MSG_AUIPC   : $sformat( minidasm, "auipc ");
        `RISCV_INST_MSG_JAL     : $sformat( minidasm, "jal   ");
        `RISCV_INST_MSG_JALR    : $sformat( minidasm, "jalr  ");
        `RISCV_INST_MSG_BEQ     : $sformat( minidasm, "beq   ");
        `RISCV_INST_MSG_BNE     : $sformat( minidasm, "bne   ");
        `RISCV_INST_MSG_BLT     : $sformat( minidasm, "blt   ");
        `RISCV_INST_MSG_BGE     : $sformat( minidasm, "bge   ");
        `RISCV_INST_MSG_BLTU    : $sformat( minidasm, "bltu  ");
        `RISCV_INST_MSG_BGEU    : $sformat( minidasm, "bgeu  ");
        `RISCV_INST_MSG_LB      : $sformat( minidasm, "lb    ");
        `RISCV_INST_MSG_LH      : $sformat( minidasm, "lh    ");
        `RISCV_INST_MSG_LW      : $sformat( minidasm, "lw    ");
        `RISCV_INST_MSG_LBU     : $sformat( minidasm, "lbu   ");
        `RISCV_INST_MSG_LHU     : $sformat( minidasm, "lhu   ");
        `RISCV_INST_MSG_SB      : $sformat( minidasm, "sb    ");
        `RISCV_INST_MSG_SH      : $sformat( minidasm, "sh    ");
        `RISCV_INST_MSG_SW      : $sformat( minidasm, "sw    ");
        `RISCV_INST_MSG_ADDI    : $sformat( minidasm, "addi  ");
        `RISCV_INST_MSG_SLTI    : $sformat( minidasm, "slti  ");
        `RISCV_INST_MSG_SLTIU   : $sformat( minidasm, "sltiu ");
        `RISCV_INST_MSG_ANDI    : $sformat( minidasm, "andi  ");
        `RISCV_INST_MSG_ORI     : $sformat( minidasm, "ori   ");
        `RISCV_INST_MSG_XORI    : $sformat( minidasm, "xori  ");
        `RISCV_INST_MSG_SLLI    : $sformat( minidasm, "slli  ");
        `RISCV_INST_MSG_SRLI    : $sformat( minidasm, "srli  ");
        `RISCV_INST_MSG_SRAI    : $sformat( minidasm, "srai  ");
        `RISCV_INST_MSG_ADD     : $sformat( minidasm, "add   ");
        `RISCV_INST_MSG_SUB     : $sformat( minidasm, "sub   ");
        `RISCV_INST_MSG_SLL     : $sformat( minidasm, "sll   ");
        `RISCV_INST_MSG_SLT     : $sformat( minidasm, "slt   ");
        `RISCV_INST_MSG_SLTU    : $sformat( minidasm, "sltu  ");
        `RISCV_INST_MSG_XOR     : $sformat( minidasm, "xor   ");
        `RISCV_INST_MSG_SRL     : $sformat( minidasm, "srl   ");
        `RISCV_INST_MSG_SRA     : $sformat( minidasm, "sra   ");
        `RISCV_INST_MSG_OR      : $sformat( minidasm, "or    ");
        `RISCV_INST_MSG_AND     : $sformat( minidasm, "and   ");
        `RISCV_INST_MSG_CSRW    : $sformat( minidasm, "csrw  ");
        // RISCV32M
        `RISCV_INST_MSG_MUL     : $sformat( minidasm, "mul   ");
        `RISCV_INST_MSG_MULH    : $sformat( minidasm, "mulh  ");
        `RISCV_INST_MSG_MULHSU  : $sformat( minidasm, "mulhsu");
        `RISCV_INST_MSG_MULHU   : $sformat( minidasm, "mulhu ");
        `RISCV_INST_MSG_DIV     : $sformat( minidasm, "div   ");
        `RISCV_INST_MSG_DIVU    : $sformat( minidasm, "divu  ");
        `RISCV_INST_MSG_REM     : $sformat( minidasm, "rem   ");
        `RISCV_INST_MSG_REMU    : $sformat( minidasm, "remu  ");
        default                : $sformat( minidasm,  "undef ");
      endcase

    end

  end

endmodule
`endif

`endif

// vim: set textwidth=0 tabstop=2 shiftwidth=2 softtabstop=2 expandtab :
