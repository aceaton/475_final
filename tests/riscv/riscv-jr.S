//=========================================================================
// riscv-jr.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Basic test
        //-----------------------------------------------------------------

test:
        li x29, __LINE__
        li x31, 0
        la x3, target

linkaddr:
        jr x3
        nop
        nop

        j _fail

target:

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_JR_SRC0_BYP( 0, jr )
        TEST_JR_SRC0_BYP( 1, jr )
        TEST_JR_SRC0_BYP( 2, jr )

        // Test that there is no branch delay slot

        li x2, 1
        la x3, 1f
        jr x3
        addi x2, x2, 1
        addi x2, x2, 1
        addi x2, x2, 1
        addi x2, x2, 1
    1:  addi x2, x2, 1
        addi x2, x2, 1
        TEST_CHECK_EQ( x2, 3 )

        TEST_RISCV_END

