//=========================================================================
// riscv-bgeu.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Branch tests
        //-----------------------------------------------------------------

        TEST_BR2_OP_TAKEN( bgeu,   0, 0 )
        TEST_BR2_OP_TAKEN( bgeu,  -1, 0 )
        TEST_BR2_OP_TAKEN( bgeu,   1, 0 )
        TEST_BR2_OP_TAKEN( bgeu,  -1, 1 )

        TEST_BR2_OP_NOTTAKEN( bgeu,  0,  1 )
        TEST_BR2_OP_NOTTAKEN( bgeu,  0, -1 )
        TEST_BR2_OP_NOTTAKEN( bgeu,  1, -1 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_BR2_SRC01_BYP( 0, 0, bgeu, 0, 1 )
        TEST_BR2_SRC01_BYP( 0, 1, bgeu, 0, 1 )
        TEST_BR2_SRC01_BYP( 0, 2, bgeu, 0, 1 )
        TEST_BR2_SRC01_BYP( 1, 0, bgeu, 0, 1 )
        TEST_BR2_SRC01_BYP( 1, 1, bgeu, 0, 1 )
        TEST_BR2_SRC01_BYP( 2, 0, bgeu, 0, 1 )

        TEST_BR2_SRC10_BYP( 0, 0, bgeu, 0, 1 )
        TEST_BR2_SRC10_BYP( 0, 1, bgeu, 0, 1 )
        TEST_BR2_SRC10_BYP( 0, 2, bgeu, 0, 1 )
        TEST_BR2_SRC10_BYP( 1, 0, bgeu, 0, 1 )
        TEST_BR2_SRC10_BYP( 1, 1, bgeu, 0, 1 )
        TEST_BR2_SRC10_BYP( 2, 0, bgeu, 0, 1 )

        //-----------------------------------------------------------------
        // Test that there is no branch delay slot
        //-----------------------------------------------------------------

        li    x2, 1
        li    x3, 0
        bgeu  x2, x3, 1f
        addi  x2, x2, 1
        addi  x2, x2, 1
        addi  x2, x2, 1
        addi  x2, x2, 1
    1:  addi  x2, x2, 1
        addi  x2, x2, 1
        TEST_CHECK_EQ( x2, 3 )

        TEST_RISCV_END

