//=========================================================================
// riscv-slli.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( slli, 0x00000001,  0, 0x00000001 )
        TEST_IMM_OP( slli, 0x00000001,  1, 0x00000002 )
        TEST_IMM_OP( slli, 0x00000001,  7, 0x00000080 )
        TEST_IMM_OP( slli, 0x00000001, 14, 0x00004000 )
        TEST_IMM_OP( slli, 0x00000001, 31, 0x80000000 )

        TEST_IMM_OP( slli, 0xffffffff,  0, 0xffffffff )
        TEST_IMM_OP( slli, 0xffffffff,  1, 0xfffffffe )
        TEST_IMM_OP( slli, 0xffffffff,  7, 0xffffff80 )
        TEST_IMM_OP( slli, 0xffffffff, 14, 0xffffc000 )
        TEST_IMM_OP( slli, 0xffffffff, 31, 0x80000000 )

        TEST_IMM_OP( slli, 0x21212121,  0, 0x21212121 )
        TEST_IMM_OP( slli, 0x21212121,  1, 0x42424242 )
        TEST_IMM_OP( slli, 0x21212121,  7, 0x90909080 )
        TEST_IMM_OP( slli, 0x21212121, 14, 0x48484000 )
        TEST_IMM_OP( slli, 0x21212121, 31, 0x80000000 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( slli, 0x00000001, 7, 0x00000080 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, slli, 0x00000001,  7, 0x00000080 )
        TEST_IMM_DEST_BYP( 1, slli, 0x00000001, 14, 0x00004000 )
        TEST_IMM_DEST_BYP( 2, slli, 0x00000001, 31, 0x80000000 )

        TEST_IMM_SRC0_BYP( 0, slli, 0x00000001,  7, 0x00000080 )
        TEST_IMM_SRC0_BYP( 1, slli, 0x00000001, 14, 0x00004000 )
        TEST_IMM_SRC0_BYP( 2, slli, 0x00000001, 31, 0x80000000 )

        TEST_RISCV_END

