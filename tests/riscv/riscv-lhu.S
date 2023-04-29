//========================================================================
// riscv-lhu.S
//========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //--------------------------------------------------------------------
        // Basic tests
        //--------------------------------------------------------------------

        TEST_LD_OP( lhu, 0, tdata_0, 0x0000beef )
        TEST_LD_OP( lhu, 2, tdata_0, 0x0000dead )
        TEST_LD_OP( lhu, 4, tdata_0, 0x000000ff )
        TEST_LD_OP( lhu, 6, tdata_0, 0x0000ff00 )

        TEST_LD_OP( lhu, -8, tdata_2, 0x0000beef )
        TEST_LD_OP( lhu, -6, tdata_2, 0x0000dead )
        TEST_LD_OP( lhu, -4, tdata_2, 0x000000ff )
        TEST_LD_OP( lhu, -2, tdata_2, 0x0000ff00 )
        TEST_LD_OP( lhu,  0, tdata_2, 0x0000ff00 )
        TEST_LD_OP( lhu,  2, tdata_2, 0x000000ff )

        // Test with a negative base

        la    x2, tdata_0
        addi  x2, x2, -32
        lhu   x4, 34(x2)
        TEST_CHECK_EQ( x4, 0x0000dead )

        // Test with unaligned base

        la    x2, tdata_0
        addi  x2, x2, -3
        lhu   x4, 5(x2)
        TEST_CHECK_EQ( x4, 0x0000dead )

        //--------------------------------------------------------------------
        // Bypassing tests
        //--------------------------------------------------------------------

        TEST_LD_DEST_BYP( 0, lhu, 0, tdata_0, 0x0000beef )
        TEST_LD_DEST_BYP( 1, lhu, 2, tdata_0, 0x0000dead )
        TEST_LD_DEST_BYP( 2, lhu, 0, tdata_1, 0x000000ff )
        TEST_LD_DEST_BYP( 3, lhu, 2, tdata_1, 0x0000ff00 )
        TEST_LD_DEST_BYP( 4, lhu, 0, tdata_2, 0x0000ff00 )

        TEST_LD_SRC0_BYP( 0, lhu, 0, tdata_0, 0x0000beef )
        TEST_LD_SRC0_BYP( 1, lhu, 2, tdata_0, 0x0000dead )
        TEST_LD_SRC0_BYP( 2, lhu, 0, tdata_1, 0x000000ff )
        TEST_LD_SRC0_BYP( 3, lhu, 2, tdata_1, 0x0000ff00 )
        TEST_LD_SRC0_BYP( 4, lhu, 0, tdata_2, 0x0000ff00 )

        // WAW

        la  x4, tdata_0
        lhu x3, 2(x4)
        li  x3, 2
        TEST_CHECK_EQ( x3, 2 )

        // RAW

        la    x5, tdata_0
        lhu   x6, 2(x5)
        addi  x7, x6, 1
        TEST_CHECK_EQ( x7, 0x0000deae )

        TEST_RISCV_END

        //--------------------------------------------------------------------
        // Test data
        //--------------------------------------------------------------------

        .data
        .align 4

tdata_0: .word 0xdeadbeef
tdata_1: .word 0xff0000ff
tdata_2: .word 0x00ffff00
