//=========================================================================
// riscv-beq.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Branch tests
        //-----------------------------------------------------------------

        TEST_BR2_OP_TAKEN( beq,  0,  0 )
        TEST_BR2_OP_TAKEN( beq,  1,  1 )
        TEST_BR2_OP_TAKEN( beq, -1, -1 )

        TEST_BR2_OP_NOTTAKEN( beq,  0,  1 )
        TEST_BR2_OP_NOTTAKEN( beq,  1,  0 )
        TEST_BR2_OP_NOTTAKEN( beq, -1,  1 )
        TEST_BR2_OP_NOTTAKEN( beq,  1, -1 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_BR2_SRC01_BYP( 0, 0, beq, 0, -1 )
        TEST_BR2_SRC01_BYP( 0, 1, beq, 0, -1 )
        TEST_BR2_SRC01_BYP( 0, 2, beq, 0, -1 )
        TEST_BR2_SRC01_BYP( 1, 0, beq, 0, -1 )
        TEST_BR2_SRC01_BYP( 1, 1, beq, 0, -1 )
        TEST_BR2_SRC01_BYP( 2, 0, beq, 0, -1 )

        TEST_BR2_SRC10_BYP( 0, 0, beq, 0, -1 )
        TEST_BR2_SRC10_BYP( 0, 1, beq, 0, -1 )
        TEST_BR2_SRC10_BYP( 0, 2, beq, 0, -1 )
        TEST_BR2_SRC10_BYP( 1, 0, beq, 0, -1 )
        TEST_BR2_SRC10_BYP( 1, 1, beq, 0, -1 )
        TEST_BR2_SRC10_BYP( 2, 0, beq, 0, -1 )

        // Test that there is no branch delay slot

        li    x2, 1
        beq   x0, x0, 1f
        addi  x2, x2, 1
        addi  x2, x2, 1
        addi  x2, x2, 1
        addi  x2, x2, 1
    1:  addi  x2, x2, 1
        addi  x2, x2, 1
        TEST_CHECK_EQ( x2, 3 )

        TEST_RISCV_END

