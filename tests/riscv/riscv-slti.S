//=========================================================================
// riscv-slti.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( slti, 0x00000000,  0x000, 0 )
        TEST_IMM_OP( slti, 0x00000001,  0x001, 0 )
        TEST_IMM_OP( slti, 0x00000003,  0x007, 1 )
        TEST_IMM_OP( slti, 0x00000007,  0x003, 0 )

        TEST_IMM_OP( slti, 0x00000000, -0x800, 0 )
        TEST_IMM_OP( slti, 0x80000000,  0x000, 1 )
        TEST_IMM_OP( slti, 0x80000000, -0x800, 1 )

        TEST_IMM_OP( slti, 0x00000000,  0x7ff, 1 )
        TEST_IMM_OP( slti, 0x7fffffff,  0x000, 0 )
        TEST_IMM_OP( slti, 0x7fffffff,  0x7ff, 0 )

        TEST_IMM_OP( slti, 0x80000000,  0x7ff, 1 )
        TEST_IMM_OP( slti, 0x7fffffff, -0x800, 0 )

        TEST_IMM_OP( slti, 0x00000000, -0x001, 0 )
        TEST_IMM_OP( slti, 0xffffffff,  0x001, 1 )
        TEST_IMM_OP( slti, 0xffffffff, -0x001, 0 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( slti, 11, 13, 1 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, slti, 15, 10, 0 )
        TEST_IMM_DEST_BYP( 1, slti, 10, 16, 1 )
        TEST_IMM_DEST_BYP( 2, slti, 16,  9, 0 )

        TEST_IMM_SRC0_BYP( 0, slti, 11, 15, 1 )
        TEST_IMM_SRC0_BYP( 1, slti, 17,  8, 0 )
        TEST_IMM_SRC0_BYP( 2, slti, 12, 14, 1 )

        TEST_RISCV_END

