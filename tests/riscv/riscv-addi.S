//=========================================================================
// riscv-addi.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( addi, 0x00000000,  0x000, 0x00000000 )
        TEST_IMM_OP( addi, 0x00000001,  0x001, 0x00000002 )
        TEST_IMM_OP( addi, 0x00000003,  0x007, 0x0000000a )

        TEST_IMM_OP( addi, 0x00000000, -0x800, 0xfffff800 )
        TEST_IMM_OP( addi, 0x80000000,  0x000, 0x80000000 )
        TEST_IMM_OP( addi, 0x80000000, -0x800, 0x7ffff800 )

        TEST_IMM_OP( addi, 0x00000000,  0x7ff, 0x000007ff )
        TEST_IMM_OP( addi, 0x7fffffff,  0x000, 0x7fffffff )
        TEST_IMM_OP( addi, 0x7fffffff,  0x7ff, 0x800007fe )

        TEST_IMM_OP( addi, 0x80000000,  0x7ff, 0x800007ff )
        TEST_IMM_OP( addi, 0x7fffffff, -0x800, 0x7ffff7ff )

        TEST_IMM_OP( addi, 0x00000000, -0x001, 0xffffffff )
        TEST_IMM_OP( addi, 0xffffffff,  0x001, 0x00000000 )
        TEST_IMM_OP( addi, 0xffffffff, -0x001, 0xfffffffe )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( addi, 13, 11, 24 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, addi, 13, 11, 24 )
        TEST_IMM_DEST_BYP( 1, addi, 13, 10, 23 )
        TEST_IMM_DEST_BYP( 2, addi, 13,  9, 22 )

        TEST_IMM_SRC0_BYP( 0, addi, 13, 11, 24 )
        TEST_IMM_SRC0_BYP( 1, addi, 13, 10, 23 )
        TEST_IMM_SRC0_BYP( 2, addi, 13,  9, 22 )

        TEST_RISCV_END

