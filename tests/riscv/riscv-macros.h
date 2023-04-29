//========================================================================
// riscv-macros.h
//========================================================================

#ifndef RISCV_MACROS_H
#define RISCV_MACROS_H

//------------------------------------------------------------------------
// TEST_RISCV_BEGIN
//------------------------------------------------------------------------
// Create a memory location for the tohost value and an entry point
// where the test should start.

#define TEST_RISCV_BEGIN                                                \
    .section .text;                                                     \
    .align  4;                                                          \
    .globl _test;                                                       \
_test:                                                                  \

//------------------------------------------------------------------------
// TEST_RISCV_END
//------------------------------------------------------------------------
// Assumes that the result is in register number 29. Also assume that
// the linker script places the _tohost array in the first 2^16 bytes of
// memory so that we can access it with just the lo() assembler
// builtin. This avoids needing lui to also be implemented. We add a
// bunch of nops after the pass fail sections with the hope that someone
// can implement just addiu and sw and then get that working first. The
// bne won't do anything, and the test harness will hopefully detect the
// update to _tohost soon after changing it.

#define TEST_RISCV_END                                                  \
_pass:                                                                  \
    addi   x29, x0, 1;                                                  \
                                                                        \
_fail:                                                                  \
    li     x2,  1;                                                      \
    csrw   21, x29;                                                     \
1:  bne    x0, x2, 1b;                                                  \
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop;                   \
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop;                   \
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop;                   \
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop;                   \

//------------------------------------------------------------------------
// TEST_XCPTR_BEGIN
//------------------------------------------------------------------------
// Create special memory location for exception handler code.

#define TEST_XCPT_BEGIN                                                 \
    .section .xcpthandler, "ax";                                        \
    .align 4;                                                           \
    .globl _xcpthandler;                                                \
_xcpthandler:                                                           \

//------------------------------------------------------------------------
// TEST_XCPT_END
//------------------------------------------------------------------------

#define TEST_XCPT_END                                                   \

//------------------------------------------------------------------------
// TEST_CHECK_EQ
//------------------------------------------------------------------------
// Check if the given register has the given value, and fail if not.
// Saves the line number in register x29 for use by the TEST_END macro.

#define TEST_CHECK_EQ( reg_, value_ )                                   \
    li    x29, __LINE__;                                                \
    li    x1, value_;                                                   \
    bne   reg_, x1, _fail;                                              \

//------------------------------------------------------------------------
// TEST_CHECK_FAIL
//------------------------------------------------------------------------
// Force this test to fail. Saves the line number in register x29 for
// use by the TEST_END macro.

#define TEST_CHECK_FAIL                                                 \
    li    x29, __LINE__;                                                \
    bne   x29, x0, _fail;                                               \

//------------------------------------------------------------------------
// TEST_INESRT_NOPS
//------------------------------------------------------------------------
// Macro which expands to a variable number of nops.

#define TEST_INSERT_NOPS_0
#define TEST_INSERT_NOPS_1  nop; TEST_INSERT_NOPS_0
#define TEST_INSERT_NOPS_2  nop; TEST_INSERT_NOPS_1
#define TEST_INSERT_NOPS_3  nop; TEST_INSERT_NOPS_2
#define TEST_INSERT_NOPS_4  nop; TEST_INSERT_NOPS_3
#define TEST_INSERT_NOPS_5  nop; TEST_INSERT_NOPS_4
#define TEST_INSERT_NOPS_6  nop; TEST_INSERT_NOPS_5
#define TEST_INSERT_NOPS_7  nop; TEST_INSERT_NOPS_6
#define TEST_INSERT_NOPS_8  nop; TEST_INSERT_NOPS_7
#define TEST_INSERT_NOPS_9  nop; TEST_INSERT_NOPS_8
#define TEST_INSERT_NOPS_10 nop; TEST_INSERT_NOPS_9

#define TEST_INSERT_NOPS_H0( nops_ ) \
  TEST_INSERT_NOPS_ ## nops_

#define TEST_INSERT_NOPS( nops_ ) \
  TEST_INSERT_NOPS_H0( nops_ )

//------------------------------------------------------------------------
// TEST_IMM : Helper macros for register-immediate instructions
//------------------------------------------------------------------------

#define TEST_IMM_OP( inst_, src0_, imm_, result_ )                      \
    li    x2, src0_;                                                    \
    inst_ x4, x2, imm_;                                                 \
    TEST_CHECK_EQ( x4, result_ );                                       \

#define TEST_IMM_SRC0_EQ_DEST( inst_, src0_, imm_, result_ )            \
    li    x2, src0_;                                                    \
    inst_ x2, x2, imm_;                                                 \
    TEST_CHECK_EQ( x2, result_ );                                       \

#define TEST_IMM_DEST_BYP( nops_, inst_, src0_, imm_, result_ )         \
    li    x2, src0_;                                                    \
    inst_ x4, x2, imm_;                                                 \
    TEST_INSERT_NOPS( nops_ );                                          \
    addi  x7, x4, 0;                                                    \
    TEST_CHECK_EQ( x7, result_ );                                       \

#define TEST_IMM_SRC0_BYP( nops_, inst_, src0_, imm_, result_ )         \
    li    x2, src0_;                                                    \
    TEST_INSERT_NOPS( nops_ );                                          \
    inst_ x4, x2, imm_;                                                 \
    TEST_CHECK_EQ( x4, result_ );                                       \

//------------------------------------------------------------------------
// TEST_LUI : Helper macros for load upper immediate instruction
//------------------------------------------------------------------------

#define TEST_LUI_OP( inst_, imm_, result_ )                             \
    li    x2, 0;                                                        \
    inst_ x2, imm_;                                                     \
    TEST_CHECK_EQ( x2, result_ );                                       \

#define TEST_LUI_DEST_BYP( nops_, inst_, imm_, result_ )                \
    li    x2, 0;                                                        \
    inst_ x2, imm_;                                                     \
    TEST_INSERT_NOPS( nops_ );                                          \
    addi  x3, x2, 0;                                                    \
    TEST_CHECK_EQ( x3, result_ );                                       \

//------------------------------------------------------------------------
// TEST_RR : Helper macros for register-register instructions
//------------------------------------------------------------------------

#define TEST_RR_OP( inst_, src0_, src1_, result_ )                      \
    li    x2, src0_;                                                    \
    li    x3, src1_;                                                    \
    inst_ x4, x2, x3;                                                   \
    TEST_CHECK_EQ( x4, result_ );                                       \

#define TEST_RR_OP1( inst_, src0_, result_ )                            \
    li    x2, src0_;                                                    \
    inst_ x4, x2;                                                       \
    TEST_CHECK_EQ( x4, result_ );                                       \

#define TEST_RR_SRC0_EQ_DEST( inst_, src0_, src1_, result_ )            \
    li    x2, src0_;                                                    \
    li    x3, src1_;                                                    \
    inst_ x2, x2, x3;                                                   \
    TEST_CHECK_EQ( x2, result_ );                                       \

#define TEST_RR_SRC1_EQ_DEST( inst_, src0_, src1_, result_ )            \
    li    x2, src0_;                                                    \
    li    x3, src1_;                                                    \
    inst_ x3, x2, x3;                                                   \
    TEST_CHECK_EQ( x3, result_ );                                       \

#define TEST_RR_SRC0_EQ_SRC1( inst_, src0_, result_ )                   \
    li    x2, src0_;                                                    \
    inst_ x3, x2, x2;                                                   \
    TEST_CHECK_EQ( x3, result_ );                                       \

#define TEST_RR_SRCS_EQ_DEST( inst_, src0_, result_ )                   \
    li    x2, src0_;                                                    \
    inst_ x2, x2, x2;                                                   \
    TEST_CHECK_EQ( x2, result_ );                                       \

#define TEST_RR_DEST_BYP( nops_, inst_, src0_, src1_, result_ )         \
    li    x2, src0_;                                                    \
    li    x3, src1_;                                                    \
    inst_ x4, x2, x3;                                                   \
    TEST_INSERT_NOPS( nops_ );                                          \
    addi  x7, x4, 0;                                                    \
    TEST_CHECK_EQ( x7, result_ );                                       \

#define TEST_RR_SRC01_BYP( src0_nops_, src1_nops_, inst_,               \
                           src0_, src1_, result_ )                      \
    li    x2, src0_;                                                    \
    TEST_INSERT_NOPS( src0_nops_ );                                     \
    li    x3, src1_;                                                    \
    TEST_INSERT_NOPS( src1_nops_ );                                     \
    inst_ x4, x2, x3;                                                   \
    TEST_CHECK_EQ( x4, result_ );                                       \

#define TEST_RR_SRC10_BYP( src1_nops_, src0_nops_, inst_,               \
                           src0_, src1_, result_ )                      \
    li    x3, src1_;                                                    \
    TEST_INSERT_NOPS( src1_nops_ );                                     \
    li    x2, src0_;                                                    \
    TEST_INSERT_NOPS( src0_nops_ );                                     \
    inst_ x4, x2, x3;                                                   \
    TEST_CHECK_EQ( x4, result_ );                                       \

//------------------------------------------------------------------------
// TEST_BR2 : Helper macros for branch two-source instructions
//------------------------------------------------------------------------

#define TEST_BR2_OP_TAKEN( inst_, src0_, src1_ )                        \
    li    x2, src0_;                                                    \
    li    x3, src1_;                                                    \
    inst_ x2, x3, 2f;                                                   \
    TEST_CHECK_FAIL;                                                    \
1:  li    x4, 1;                                                        \
    bne   x0, x4, 3f;                                                   \
2:  inst_ x2, x3, 1b;                                                   \
    TEST_CHECK_FAIL;                                                    \
3:                                                                      \

#define TEST_BR2_OP_NOTTAKEN( inst_, src0_, src1_ )                     \
    li    x2, src0_;                                                    \
    li    x3, src1_;                                                    \
    inst_ x2, x3, 1f;                                                   \
    li    x4, 1;                                                        \
    bne   x0, x4, 2f;                                                   \
1:  TEST_CHECK_FAIL;                                                    \
2:  inst_ x2, x3, 1b;                                                   \

#define TEST_BR2_SRC01_BYP( src0_nops_, src1_nops_,                     \
                            inst_, src0_, src1_ )                       \
    li    x2, src0_;                                                    \
    TEST_INSERT_NOPS( src0_nops_ );                                     \
    li    x3, src1_;                                                    \
    TEST_INSERT_NOPS( src1_nops_ );                                     \
    inst_ x2, x3, 1f;                                                   \
    li    x4, 1;                                                        \
    bne   x0, x4, 2f;                                                   \
1:  TEST_CHECK_FAIL;                                                    \
2:                                                                      \

#define TEST_BR2_SRC10_BYP( src1_nops_, src0_nops_,                     \
                            inst_, src0_, src1_ )                       \
    li    x3, src1_;                                                    \
    TEST_INSERT_NOPS( src1_nops_ );                                     \
    li    x2, src0_;                                                    \
    TEST_INSERT_NOPS( src0_nops_ );                                     \
    inst_ x2, x3, 1f;                                                   \
    li    x4, 1;                                                        \
    bne   x0, x4, 2f;                                                   \
1:  TEST_CHECK_FAIL;                                                    \
2:                                                                      \

#define TEST_JR_SRC0_BYP( nops_, inst_ )                                \
    la    x2, 1f;                                                       \
    TEST_INSERT_NOPS( nops_ );                                          \
    inst_ x2;                                                           \
    TEST_CHECK_FAIL;                                                    \
1:                                                                      \

//------------------------------------------------------------------------
// TEST_JALR : Helper macros for jump and link register instruction
//------------------------------------------------------------------------

#define TEST_JALR_SRC0_BYP( nops_, inst_ )                              \
    la x2, 1f;                                                          \
    TEST_INSERT_NOPS( nops_ );                                          \
    inst_ x3, x2;                                                       \
    TEST_CHECK_FAIL;                                                    \
1:                                                                      \

//------------------------------------------------------------------------
// TEST_LD : Helper macros for load instructions
//------------------------------------------------------------------------

#define TEST_LD_OP( inst_, offset_, base_, result_ )                    \
    la    x2, base_;                                                    \
    inst_ x4, offset_(x2);                                              \
    TEST_CHECK_EQ( x4, result_ );                                       \

#define TEST_LD_DEST_BYP( nops_, inst_, offset_, base_, result_ )       \
    la    x2, base_;                                                    \
    inst_ x4, offset_(x2);                                              \
    TEST_INSERT_NOPS( nops_ );                                          \
    addi  x7, x4, 0;                                                    \
    TEST_CHECK_EQ( x7, result_ );                                       \

#define TEST_LD_SRC0_BYP( nops_, inst_, offset_, base_, result_ )       \
    la    x2, base_;                                                    \
    TEST_INSERT_NOPS( nops_ );                                          \
    inst_ x4, offset_(x2);                                              \
    TEST_CHECK_EQ( x4, result_ );                                       \

//------------------------------------------------------------------------
// TEST_SW : Helper macros for store word instructions
//------------------------------------------------------------------------
// Macros used specifically for the sw instruction in RISCV-minimal, which
// avoids using any instructions from RISCV.

#define TEST_SW_OP( st_, wdata_, offset_, base_, result_ )              \
    la    x2, base_;                                                    \
    li    x3, wdata_;                                                   \
    st_   x3, offset_(x2);                                              \
    lw    x4, offset_(x2);                                              \
    TEST_CHECK_EQ( x4, result_ );                                       \

#define TEST_SW_SRC01_BYP( src0_nops_, src1_nops_,                      \
                           st_, wdata_, offset_, base_, result_ )       \
    li    x3, wdata_;                                                   \
    TEST_INSERT_NOPS( src0_nops_ );                                     \
    la    x2, base_;                                                    \
    TEST_INSERT_NOPS( src1_nops_ );                                     \
    st_   x3, offset_(x2);                                              \
    lw    x4, offset_(x2);                                              \
    TEST_CHECK_EQ( x4, result_ );                                       \

#define TEST_SW_SRC10_BYP( src1_nops_, src0_nops_,                      \
                           st_, wdata_, offset_, base_, result_ )       \
    la    x2, base_;                                                    \
    TEST_INSERT_NOPS( src1_nops_ );                                     \
    li    x3, wdata_;                                                   \
    TEST_INSERT_NOPS( src0_nops_ );                                     \
    st_   x3, offset_(x2);                                              \
    lw    x4, offset_(x2);                                              \
    TEST_CHECK_EQ( x4, result_ );                                       \

//------------------------------------------------------------------------
// TEST_ST : Helper macros for subword store instructions
//------------------------------------------------------------------------
// These macros always use a lw to bring back in the stored data to
// verify the store. The lw address is formed by simply masking off the
// lower two bits of the store address. The result_ needs to be
// specified accordingly. This helps make sure that the store doesn't
// store more data then it is supposed to.

#define TEST_ST_OP( st_, wdata_, offset_, base_, result_ )              \
    la    x2, base_;                                                    \
    li    x3, wdata_;                                                   \
    st_   x3, offset_(x2);                                              \
    li    x5, 0xfffffffc;                                               \
    addi  x2, x2, offset_;                                              \
    and   x2, x2, x5;                                                   \
    lw    x4, (x2);                                                     \
    TEST_CHECK_EQ( x4, result_ );                                       \

#define TEST_ST_SRC01_BYP( src0_nops_, src1_nops_,                      \
                           st_, wdata_, offset_, base_, result_ )       \
    li    x3, wdata_;                                                   \
    TEST_INSERT_NOPS( src0_nops_ );                                     \
    la    x2, base_;                                                    \
    TEST_INSERT_NOPS( src1_nops_ );                                     \
    st_   x3, offset_(x2);                                              \
    li    x5, 0xfffffffc;                                               \
    addi  x2, x2, offset_;                                              \
    and   x2, x2, x5;                                                   \
    lw    x4, (x2);                                                     \
    TEST_CHECK_EQ( x4, result_ );                                       \

#define TEST_ST_SRC10_BYP( src1_nops_, src0_nops_,                      \
                           st_, wdata_, offset_, base_, result_ )       \
    la    x2, base_;                                                    \
    TEST_INSERT_NOPS( src1_nops_ );                                     \
    li    x3, wdata_;                                                   \
    TEST_INSERT_NOPS( src0_nops_ );                                     \
    st_   x3, offset_(x2);                                              \
    li    x5, 0xfffffffc;                                               \
    addi  x2, x2, offset_;                                              \
    and   x2, x2, x5;                                                   \
    lw    x4, (x2);                                                     \
    TEST_CHECK_EQ( x4, result_ );                                       \

//------------------------------------------------------------------------
// TEST_CMOV : Helper macros for conditional move instructions
//------------------------------------------------------------------------

#define TEST_CMOV_OP( inst_, dest_, src_, sel_, result_ )               \
    li    x2, dest_;                                                    \
    li    x3, src_;                                                     \
    li    x4, sel_;                                                     \
    inst_ x2, x3, x4;                                                   \
    TEST_CHECK_EQ( x2, result_ );                                       \

#define TEST_CMOV_SRC0_EQ_DEST( inst_, dest_src_, sel_, result_ )       \
    li    x2, dest_src_;                                                \
    li    x3, sel_;                                                     \
    inst_ x2, x2, x3;                                                   \
    TEST_CHECK_EQ( x2, result_ );                                       \

#define TEST_CMOV_SRC1_EQ_DEST( inst_, src_, dest_sel_, result_ )       \
    li    x2, src_;                                                     \
    li    x3, dest_sel_;                                                \
    inst_ x3, x2, x3;                                                   \
    TEST_CHECK_EQ( x3, result_ );                                       \

#define TEST_CMOV_SRCS_EQ_DEST( inst_, dest_src_sel_, result_ )         \
    li    x2, dest_src_sel_;                                            \
    inst_ x2, x2, x2;                                                   \
    TEST_CHECK_EQ( x2, result_ );                                       \

#define TEST_CMOV_DEST_BYP( nops_, inst_, dest_, src_, sel_, result_ )  \
    li    x2, dest_;                                                    \
    li    x3, src_;                                                     \
    li    x4, sel_;                                                     \
    inst_ x2, x3, x4;                                                   \
    TEST_INSERT_NOPS( nops_ );                                          \
    addi  x7, x2, 0;                                                    \
    TEST_CHECK_EQ( x7, result_ );                                       \

#define TEST_CMOV_SRC01_BYP( src0_nops_, src1_nops_, inst_,             \
                             dest_, src_, sel_, result_ )               \
    li    x2, dest_;                                                    \
    li    x3, src_;                                                     \
    TEST_INSERT_NOPS( src0_nops_ );                                     \
    li    x4, sel_;                                                     \
    TEST_INSERT_NOPS( src1_nops_ );                                     \
    inst_ x2, x3, x4;                                                   \
    TEST_CHECK_EQ( x2, result_ );                                       \

#define TEST_CMOV_SRC10_BYP( src1_nops_, src0_nops_, inst_,             \
                             dest_, src_, sel_, result_ )               \
    li    x2, dest_;                                                    \
    li    x4, sel_;                                                     \
    TEST_INSERT_NOPS( src1_nops_ );                                     \
    li    x3, src_;                                                     \
    TEST_INSERT_NOPS( src0_nops_ );                                     \
    inst_ x2, x3, x4;                                                   \
    TEST_CHECK_EQ( x2, result_ );                                       \

#endif /* RISCV_MACROS_H */

