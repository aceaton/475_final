//=========================================================================
// riscv-bge.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Branch tests
        //-----------------------------------------------------------------

        TEST_BR2_OP_TAKEN( bge,  0,  0 )
        TEST_BR2_OP_TAKEN( bge,  0, -1 )
        TEST_BR2_OP_TAKEN( bge,  1,  0 )
        TEST_BR2_OP_TAKEN( bge,  1, -1 )

        TEST_BR2_OP_NOTTAKEN( bge,  0,  1 )
        TEST_BR2_OP_NOTTAKEN( bge, -1,  0 )
        TEST_BR2_OP_NOTTAKEN( bge, -1,  1 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_BR2_SRC01_BYP( 0, 0, bge, 0, 1 )
        TEST_BR2_SRC01_BYP( 0, 1, bge, 0, 1 )
        TEST_BR2_SRC01_BYP( 0, 2, bge, 0, 1 )
        TEST_BR2_SRC01_BYP( 1, 0, bge, 0, 1 )
        TEST_BR2_SRC01_BYP( 1, 1, bge, 0, 1 )
        TEST_BR2_SRC01_BYP( 2, 0, bge, 0, 1 )

        TEST_BR2_SRC10_BYP( 0, 0, bge, 0, 1 )
        TEST_BR2_SRC10_BYP( 0, 1, bge, 0, 1 )
        TEST_BR2_SRC10_BYP( 0, 2, bge, 0, 1 )
        TEST_BR2_SRC10_BYP( 1, 0, bge, 0, 1 )
        TEST_BR2_SRC10_BYP( 1, 1, bge, 0, 1 )
        TEST_BR2_SRC10_BYP( 2, 0, bge, 0, 1 )

        //-----------------------------------------------------------------
        // Test that there is no branch delay slot
        //-----------------------------------------------------------------

        li    x2, 1
        li    x3, -1
        bge   x2, x3, 1f
        addi  x2, x2, 1
        addi  x2, x2, 1
        addi  x2, x2, 1
        addi  x2, x2, 1
    1:  addi  x2, x2, 1
        addi  x2, x2, 1
        TEST_CHECK_EQ( x2, 3 )

        TEST_RISCV_END

