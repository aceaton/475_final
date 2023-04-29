//=========================================================================
// riscv-sltiu.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( sltiu, 0x00000000,  0x000, 0 )
        TEST_IMM_OP( sltiu, 0x00000001,  0x001, 0 )
        TEST_IMM_OP( sltiu, 0x00000003,  0x007, 1 )
        TEST_IMM_OP( sltiu, 0x00000007,  0x003, 0 )

        TEST_IMM_OP( sltiu, 0x00000000, -0x800, 1 )
        TEST_IMM_OP( sltiu, 0x80000000,  0x000, 0 )
        TEST_IMM_OP( sltiu, 0x80000000, -0x800, 1 )

        TEST_IMM_OP( sltiu, 0x00000000,  0x7ff, 1 )
        TEST_IMM_OP( sltiu, 0x7fffffff,  0x000, 0 )
        TEST_IMM_OP( sltiu, 0x7fffffff,  0x7ff, 0 )

        TEST_IMM_OP( sltiu, 0x80000000,  0x7ff, 0 )
        TEST_IMM_OP( sltiu, 0x7fffffff, -0x800, 1 )

        TEST_IMM_OP( sltiu, 0x00000000, -0x001, 1 )
        TEST_IMM_OP( sltiu, 0xffffffff,  0x001, 0 )
        TEST_IMM_OP( sltiu, 0xffffffff, -0x001, 0 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( sltiu, 11, 13, 1 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, sltiu, 15, 10, 0 )
        TEST_IMM_DEST_BYP( 1, sltiu, 10, 16, 1 )
        TEST_IMM_DEST_BYP( 2, sltiu, 16,  9, 0 )

        TEST_IMM_SRC0_BYP( 0, sltiu, 11, 15, 1 )
        TEST_IMM_SRC0_BYP( 1, sltiu, 17,  8, 0 )
        TEST_IMM_SRC0_BYP( 2, sltiu, 12, 14, 1 )

        TEST_RISCV_END

