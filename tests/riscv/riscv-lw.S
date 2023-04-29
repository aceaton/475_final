//=========================================================================
// riscv-lw.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //----------------------------------------------------------------
        // Basic tests
        //----------------------------------------------------------------

        TEST_LD_OP( lw,   0, tdata_0, 0x000000ff )
        TEST_LD_OP( lw,   4, tdata_0, 0x00007f00 )
        TEST_LD_OP( lw,   8, tdata_0, 0x00000ff0 )
        TEST_LD_OP( lw,  12, tdata_0, 0x0000700f )
        TEST_LD_OP( lw, -12, tdata_3, 0x000000ff )
        TEST_LD_OP( lw,  -8, tdata_3, 0x00007f00 )
        TEST_LD_OP( lw,  -4, tdata_3, 0x00000ff0 )
        TEST_LD_OP( lw,   0, tdata_3, 0x0000700f )

        // Test with a negative base

        la    x2, tdata_0
        addi  x2, x2, -32
        lw    x4, 32(x2)
        TEST_CHECK_EQ( x4, 0x000000ff )

        // Test with unaligned base

        la    x2, tdata_0
        addi  x2, x2, -3
        lw    x4, 7(x2)
        TEST_CHECK_EQ( x4, 0x00007f00 )

        //----------------------------------------------------------------
        // Bypassing tests
        //----------------------------------------------------------------

        TEST_LD_DEST_BYP( 0, lw, 0, tdata_0, 0x000000ff )
        TEST_LD_DEST_BYP( 1, lw, 4, tdata_0, 0x00007f00 )
        TEST_LD_DEST_BYP( 2, lw, 0, tdata_1, 0x00007f00 )
        TEST_LD_DEST_BYP( 3, lw, 4, tdata_1, 0x00000ff0 )
        TEST_LD_DEST_BYP( 4, lw, 0, tdata_3, 0x0000700f )

        TEST_LD_SRC0_BYP( 0, lw, 0, tdata_0, 0x000000ff )
        TEST_LD_SRC0_BYP( 1, lw, 4, tdata_0, 0x00007f00 )
        TEST_LD_SRC0_BYP( 2, lw, 0, tdata_1, 0x00007f00 )
        TEST_LD_SRC0_BYP( 3, lw, 4, tdata_1, 0x00000ff0 )
        TEST_LD_SRC0_BYP( 4, lw, 0, tdata_3, 0x0000700f )

        // WAW

        la x4, tdata_0
        lw x3, 4(x4)
        li x3, 2
        TEST_CHECK_EQ( x3, 2 )

        // RAW

        la x5, tdata_0
        lw x6, 4(x5)
        addi x7, x6, 1
        TEST_CHECK_EQ( x7, 0x00007f01 )

        TEST_RISCV_END

        //-----------------------------------------------------------------
        // Test data
        //-----------------------------------------------------------------

        .section .data
        .align 4

tdata_0:  .word 0x000000ff
tdata_1:  .word 0x00007f00
tdata_2:  .word 0x00000ff0
tdata_3:  .word 0x0000700f

