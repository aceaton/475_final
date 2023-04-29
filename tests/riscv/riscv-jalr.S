//=========================================================================
// riscv-jalr.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Basic test
        //-----------------------------------------------------------------

test_0:
        li x29, __LINE__
        li x31, 0
        la x3, target_0

linkaddr_0:
        jalr x16, x3
        nop
        nop
        TEST_CHECK_FAIL

target_0:
        la x2, linkaddr_0
        addi  x2, x2, 4
        bne x2, x16, _fail

        //-----------------------------------------------------------------
        // Check r0 target and that r31 is not modified
        //-----------------------------------------------------------------

test_1:
        li x29, __LINE__
        li x31, 0
        la x3, target_1

linkaddr_1:
        jalr x0, x3
        nop
        nop
        TEST_CHECK_FAIL

target_1:
        bne x0, x31, _fail

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_JALR_SRC0_BYP( 0, jalr )
        TEST_JALR_SRC0_BYP( 1, jalr )
        TEST_JALR_SRC0_BYP( 2, jalr )

        //-----------------------------------------------------------------
        // Test that there is no branch delay slot
        //-----------------------------------------------------------------

        li    x2, 1
        la    x3, 1f
        jalr  x16, x3
        addi  x2, x2, 1
        addi  x2, x2, 1
        addi  x2, x2, 1
        addi  x2, x2, 1
    1:  addi  x2, x2, 1
        addi  x2, x2, 1
        TEST_CHECK_EQ( x2, 3 )

        TEST_RISCV_END

