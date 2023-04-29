//=========================================================================
// riscv-srai.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( srai, 0x80000000,  0, 0x80000000 )
        TEST_IMM_OP( srai, 0x80000000,  1, 0xc0000000 )
        TEST_IMM_OP( srai, 0x80000000,  7, 0xff000000 )
        TEST_IMM_OP( srai, 0x80000000, 14, 0xfffe0000 )
        TEST_IMM_OP( srai, 0x80000001, 31, 0xffffffff )

        TEST_IMM_OP( srai, 0x7fffffff,  0, 0x7fffffff )
        TEST_IMM_OP( srai, 0x7fffffff,  1, 0x3fffffff )
        TEST_IMM_OP( srai, 0x7fffffff,  7, 0x00ffffff )
        TEST_IMM_OP( srai, 0x7fffffff, 14, 0x0001ffff )
        TEST_IMM_OP( srai, 0x7fffffff, 31, 0x00000000 )

        TEST_IMM_OP( srai, 0x81818181,  0, 0x81818181 )
        TEST_IMM_OP( srai, 0x81818181,  1, 0xc0c0c0c0 )
        TEST_IMM_OP( srai, 0x81818181,  7, 0xff030303 )
        TEST_IMM_OP( srai, 0x81818181, 14, 0xfffe0606 )
        TEST_IMM_OP( srai, 0x81818181, 31, 0xffffffff )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( srai, 0x80000000, 7, 0xff000000 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, srai, 0x80000000,  7, 0xff000000 )
        TEST_IMM_DEST_BYP( 1, srai, 0x80000000, 14, 0xfffe0000 )
        TEST_IMM_DEST_BYP( 2, srai, 0x80000001, 31, 0xffffffff )

        TEST_IMM_SRC0_BYP( 0, srai, 0x80000000,  7, 0xff000000 )
        TEST_IMM_SRC0_BYP( 1, srai, 0x80000000, 14, 0xfffe0000 )
        TEST_IMM_SRC0_BYP( 2, srai, 0x80000001, 31, 0xffffffff )

        TEST_RISCV_END

