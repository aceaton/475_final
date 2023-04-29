//=========================================================================
// riscv-bne.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Branch tests
        //-----------------------------------------------------------------

        TEST_BR2_OP_TAKEN( bne,  0,  1 )
        TEST_BR2_OP_TAKEN( bne,  1,  0 )
        TEST_BR2_OP_TAKEN( bne, -1,  1 )
        TEST_BR2_OP_TAKEN( bne,  1, -1 )

        TEST_BR2_OP_NOTTAKEN( bne,  0,  0 )
        TEST_BR2_OP_NOTTAKEN( bne,  1,  1 )
        TEST_BR2_OP_NOTTAKEN( bne, -1, -1 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_BR2_SRC01_BYP( 0, 0, bne, 0, 0 )
        TEST_BR2_SRC01_BYP( 0, 1, bne, 0, 0 )
        TEST_BR2_SRC01_BYP( 0, 2, bne, 0, 0 )
        TEST_BR2_SRC01_BYP( 1, 0, bne, 0, 0 )
        TEST_BR2_SRC01_BYP( 1, 1, bne, 0, 0 )
        TEST_BR2_SRC01_BYP( 2, 0, bne, 0, 0 )

        TEST_BR2_SRC10_BYP( 0, 0, bne, 0, 0 )
        TEST_BR2_SRC10_BYP( 0, 1, bne, 0, 0 )
        TEST_BR2_SRC10_BYP( 0, 2, bne, 0, 0 )
        TEST_BR2_SRC10_BYP( 1, 0, bne, 0, 0 )
        TEST_BR2_SRC10_BYP( 1, 1, bne, 0, 0 )
        TEST_BR2_SRC10_BYP( 2, 0, bne, 0, 0 )

        // Test that there is no branch delay slot

        li x2, 1
        bne x2, x0, 1f
        addi x2, x2, 1
        addi x2, x2, 1
        addi x2, x2, 1
        addi x2, x2, 1
    1:  addi x2, x2, 1
        addi x2, x2, 1
        TEST_CHECK_EQ( x2, 3 )

        TEST_RISCV_END

