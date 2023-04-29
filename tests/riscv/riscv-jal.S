//=========================================================================
// riscv-jal.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Basic test
        //-----------------------------------------------------------------

test:
        li x29, __LINE__
        li x31, 0

linkaddr:
        jal target
        nop
        nop

        j _fail

target:
        la x2, linkaddr
        addi  x2, x2, 4
        bne x2, x1, _fail


        // Test that there is no branch delay slot

        li x2, 1
        jal 1f
        addi  x2, x2, 1
        addi  x2, x2, 1
        addi  x2, x2, 1
        addi  x2, x2, 1
    1:  addi  x2, x2, 1
        addi  x2, x2, 1
        TEST_CHECK_EQ( x2, 3 )

        TEST_RISCV_END

