//========================================================================
// riscv-lh.S
//========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //--------------------------------------------------------------------
        // Basic tests
        //--------------------------------------------------------------------

        TEST_LD_OP( lh, 0, tdata_0, 0xffffbeef )
        TEST_LD_OP( lh, 2, tdata_0, 0xffffdead )
        TEST_LD_OP( lh, 4, tdata_0, 0x000000ff )
        TEST_LD_OP( lh, 6, tdata_0, 0xffffff00 )

        TEST_LD_OP( lh, -8, tdata_2, 0xffffbeef )
        TEST_LD_OP( lh, -6, tdata_2, 0xffffdead )
        TEST_LD_OP( lh, -4, tdata_2, 0x000000ff )
        TEST_LD_OP( lh, -2, tdata_2, 0xffffff00 )
        TEST_LD_OP( lh,  0, tdata_2, 0xffffff00 )
        TEST_LD_OP( lh,  2, tdata_2, 0x000000ff )

        // Test with a negative base

        la    x2, tdata_0
        addi  x2, x2, -32
        lh    x4, 34(x2)
        TEST_CHECK_EQ( x4, 0xffffdead )

        // Test with unaligned base

        la    x2, tdata_0
        addi  x2, x2, -3
        lh    x4, 5(x2)
        TEST_CHECK_EQ( x4, 0xffffdead )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_LD_DEST_BYP( 0, lh, 0, tdata_0, 0xffffbeef )
        TEST_LD_DEST_BYP( 1, lh, 2, tdata_0, 0xffffdead )
        TEST_LD_DEST_BYP( 2, lh, 0, tdata_1, 0x000000ff )
        TEST_LD_DEST_BYP( 3, lh, 2, tdata_1, 0xffffff00 )
        TEST_LD_DEST_BYP( 4, lh, 0, tdata_2, 0xffffff00 )
     
        TEST_LD_SRC0_BYP( 0, lh, 0, tdata_0, 0xffffbeef )
        TEST_LD_SRC0_BYP( 1, lh, 2, tdata_0, 0xffffdead )
        TEST_LD_SRC0_BYP( 2, lh, 0, tdata_1, 0x000000ff )
        TEST_LD_SRC0_BYP( 3, lh, 2, tdata_1, 0xffffff00 )
        TEST_LD_SRC0_BYP( 4, lh, 0, tdata_2, 0xffffff00 )

        // WAW

        la x4, tdata_0
        lh x3, 2(x4)
        li x3, 2
        TEST_CHECK_EQ( x3, 2 )

        // RAW

        la    x5, tdata_0
        lh    x6, 2(x5)
        addi  x7, x6, 1
        TEST_CHECK_EQ( x7, 0xffffdeae )

        TEST_RISCV_END

        //--------------------------------------------------------------------
        // Test data
        //--------------------------------------------------------------------

        .data
        .align 4

tdata_0: .word 0xdeadbeef
tdata_1: .word 0xff0000ff
tdata_2: .word 0x00ffff00
