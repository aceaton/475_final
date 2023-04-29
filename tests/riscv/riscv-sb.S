//========================================================================
// riscv-sb.S
//========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //--------------------------------------------------------------------
        // Basic tests
        //--------------------------------------------------------------------

        TEST_ST_OP( sb, 0x000000ab,  0, tdata_0, 0xdeadbeab )
        TEST_ST_OP( sb, 0x000000cd,  1, tdata_0, 0xdeadcdab )
        TEST_ST_OP( sb, 0x000000ef,  2, tdata_0, 0xdeefcdab )
        TEST_ST_OP( sb, 0x00000011,  3, tdata_0, 0x11efcdab )
        TEST_ST_OP( sb, 0x000000ab,  4, tdata_0, 0xdeadbeab )
        TEST_ST_OP( sb, 0x000000cd,  5, tdata_0, 0xdeadcdab )
        TEST_ST_OP( sb, 0x000000ef,  6, tdata_0, 0xdeefcdab )
        TEST_ST_OP( sb, 0x00000011,  7, tdata_0, 0x11efcdab )
        TEST_ST_OP( sb, 0x000000ab,  8, tdata_0, 0xdeadbeab )
        TEST_ST_OP( sb, 0x000000cd,  9, tdata_0, 0xdeadcdab )
        TEST_ST_OP( sb, 0x000000ef,  10, tdata_0, 0xdeefcdab )
        TEST_ST_OP( sb, 0x00000011,  11, tdata_0, 0x11efcdab )

        TEST_ST_OP( sb, 0x00000012,  -8, tdata_5, 0xdeadbe12 )
        TEST_ST_OP( sb, 0x00000034,  -7, tdata_5, 0xdead3412 )
        TEST_ST_OP( sb, 0x00000056,  -6, tdata_5, 0xde563412 )
        TEST_ST_OP( sb, 0x00000078,  -5, tdata_5, 0x78563412 )
        TEST_ST_OP( sb, 0x0000009a,  -4, tdata_5, 0xdeadbe9a )
        TEST_ST_OP( sb, 0x000000bc,  -3, tdata_5, 0xdeadbc9a )
        TEST_ST_OP( sb, 0x000000de,  -2, tdata_5, 0xdedebc9a )
        TEST_ST_OP( sb, 0x000000f0,  -1, tdata_5, 0xf0debc9a )
        TEST_ST_OP( sb, 0x00000012,   0, tdata_5, 0xdeadbe12 )
        TEST_ST_OP( sb, 0x00000034,   1, tdata_5, 0xdead3412 )
        TEST_ST_OP( sb, 0x00000056,   2, tdata_5, 0xde563412 )
        TEST_ST_OP( sb, 0x00000078,   3, tdata_5, 0x78563412 )

        // Test with a negative base

        la    x2, tdata_6
        li    x3, 0x000000ff
        addi  x5, x2, -32
        sb    x3, 33(x5)
        lw    x4, 0(x2)
        TEST_CHECK_EQ( x4, 0xdeadffef )

        // Test with unaligned base

        la    x2, tdata_7
        li    x3, 0x000000ff
        addi  x2, x2, -3
        sb    x3, 10(x2)
        la    x5, tdata_8
        lw    x4, 0(x5)
        TEST_CHECK_EQ( x4, 0xffadbeef )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_ST_SRC01_BYP( 0, 0, sb, 0x000000aa,  0,  tdata_9, 0xdeadbeaa )
        TEST_ST_SRC01_BYP( 0, 1, sb, 0x000000bb,  0,  tdata_9, 0xdeadbebb )
        TEST_ST_SRC01_BYP( 0, 2, sb, 0x000000cc,  1,  tdata_9, 0xdeadccbb )
        TEST_ST_SRC01_BYP( 0, 3, sb, 0x000000dd,  2,  tdata_9, 0xdeddccbb )
        TEST_ST_SRC01_BYP( 0, 4, sb, 0x000000ee,  3,  tdata_9, 0xeeddccbb )

        TEST_ST_SRC01_BYP( 1, 0, sb, 0x000000ff,  0, tdata_10, 0xdeadbeff )
        TEST_ST_SRC01_BYP( 1, 1, sb, 0x00000000,  1, tdata_10, 0xdead00ff )

        TEST_ST_SRC10_BYP( 0, 0, sb, 0x00000012,  0,  tdata_9, 0xeeddcc12 )
        TEST_ST_SRC10_BYP( 0, 1, sb, 0x00000034,  0,  tdata_9, 0xeeddcc34 )
        TEST_ST_SRC10_BYP( 0, 2, sb, 0x00000056,  1,  tdata_9, 0xeedd5634 )
        TEST_ST_SRC10_BYP( 0, 3, sb, 0x00000078,  2,  tdata_9, 0xee785634 )
        TEST_ST_SRC10_BYP( 0, 4, sb, 0x0000009a,  3,  tdata_9, 0x9a785634 )

        TEST_ST_SRC10_BYP( 1, 0, sb, 0x000000ff,  2, tdata_10, 0xdeff00ff )
        TEST_ST_SRC10_BYP( 1, 1, sb, 0x00000000,  3, tdata_10, 0x00ff00ff )

        TEST_RISCV_END

        //--------------------------------------------------------------------
        // Test data
        //--------------------------------------------------------------------

        .data
        .align 4

tdata_0:  .word 0xdeadbeef
tdata_1:  .word 0xdeadbeef
tdata_2:  .word 0xdeadbeef
tdata_3:  .word 0xdeadbeef
tdata_4:  .word 0xdeadbeef
tdata_5:  .word 0xdeadbeef
tdata_6:  .word 0xdeadbeef
tdata_7:  .word 0xdeadbeef
tdata_8:  .word 0xdeadbeef
tdata_9:  .word 0xdeadbeef
tdata_10: .word 0xdeadbeef
