//========================================================================
// riscv-sh.S
//========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //--------------------------------------------------------------------
        // Basic tests
        //--------------------------------------------------------------------

        TEST_ST_OP( sh, 0x0000abcd,  0, tdata_0, 0xdeadabcd )
        TEST_ST_OP( sh, 0x0000abcd,  2, tdata_0, 0xabcdabcd )
        TEST_ST_OP( sh, 0x0000ffff,  4, tdata_0, 0xdeadffff )
        TEST_ST_OP( sh, 0x00000000,  6, tdata_0, 0x0000ffff )

        TEST_ST_OP( sh, 0x00001234,  -8, tdata_4, 0xdead1234 )
        TEST_ST_OP( sh, 0x00005678,  -6, tdata_4, 0x56781234 )
        TEST_ST_OP( sh, 0x00009abc,  -4, tdata_4, 0xdead9abc )
        TEST_ST_OP( sh, 0x0000deff,  -2, tdata_4, 0xdeff9abc )
        TEST_ST_OP( sh, 0x00000000,   0, tdata_4, 0xdead0000 )
        TEST_ST_OP( sh, 0x0000ff00,   2, tdata_4, 0xff000000 )

        // Test with a negative base

        la    x2, tdata_5
        li    x3, 0x0000ffff
        addi  x5, x2, -32
        sh    x3, 34(x5)
        lw    x4, 0(x2)
        TEST_CHECK_EQ( x4, 0xffffbeef )

        // Test with unaligned base

        la    x2, tdata_6
        li    x3, 0x0000abcd
        addi  x2, x2, -3
        sh    x3, 9(x2)
        la    x5, tdata_7
        lw    x4, 0(x5)
        TEST_CHECK_EQ( x4, 0xabcdbeef )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_ST_SRC01_BYP( 0, 0, sh, 0x0000aabb,  0,  tdata_8, 0xdeadaabb )
        TEST_ST_SRC01_BYP( 0, 1, sh, 0x0000ccdd,  2,  tdata_8, 0xccddaabb )
        TEST_ST_SRC01_BYP( 0, 2, sh, 0x0000eeff,  0,  tdata_9, 0xdeadeeff )
        TEST_ST_SRC01_BYP( 0, 3, sh, 0x0000aabb,  2,  tdata_9, 0xaabbeeff )
        TEST_ST_SRC01_BYP( 0, 4, sh, 0x0000ccdd,  0, tdata_10, 0xdeadccdd )
        TEST_ST_SRC01_BYP( 0, 3, sh, 0x0000eeff,  2, tdata_10, 0xeeffccdd )

        TEST_ST_SRC01_BYP( 1, 0, sh, 0x0000ffff,  0, tdata_11, 0xdeadffff )
        TEST_ST_SRC01_BYP( 1, 1, sh, 0x0000ffff,  2, tdata_11, 0xffffffff )

        TEST_ST_SRC10_BYP( 0, 0, sh, 0x00001234,  0,  tdata_8, 0xccdd1234 )
        TEST_ST_SRC10_BYP( 0, 1, sh, 0x00005678,  2,  tdata_8, 0x56781234 )
        TEST_ST_SRC10_BYP( 0, 2, sh, 0x00009abc,  0,  tdata_9, 0xaabb9abc )
        TEST_ST_SRC10_BYP( 0, 3, sh, 0x00001234,  2,  tdata_9, 0x12349abc )
        TEST_ST_SRC10_BYP( 0, 4, sh, 0x00005678,  0, tdata_10, 0xeeff5678 )
        TEST_ST_SRC10_BYP( 0, 3, sh, 0x00009abc,  2, tdata_10, 0x9abc5678 )

        TEST_ST_SRC10_BYP( 1, 0, sh, 0x00000000,  0, tdata_11, 0xffff0000 )
        TEST_ST_SRC10_BYP( 1, 1, sh, 0x00000000,  2, tdata_11, 0x00000000 )

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
tdata_11: .word 0xdeadbeef

