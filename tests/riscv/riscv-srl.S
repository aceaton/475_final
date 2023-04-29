//=========================================================================
// riscv-srl.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Arithmetic tests
        //-----------------------------------------------------------------

        TEST_RR_OP( srl, 0x80000000,  0, 0x80000000 )
        TEST_RR_OP( srl, 0x80000000,  1, 0x40000000 )
        TEST_RR_OP( srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_OP( srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_OP( srl, 0x80000001, 31, 0x00000001 )

        TEST_RR_OP( srl, 0xffffffff,  0, 0xffffffff )
        TEST_RR_OP( srl, 0xffffffff,  1, 0x7fffffff )
        TEST_RR_OP( srl, 0xffffffff,  7, 0x01ffffff )
        TEST_RR_OP( srl, 0xffffffff, 14, 0x0003ffff )
        TEST_RR_OP( srl, 0xffffffff, 31, 0x00000001 )

        TEST_RR_OP( srl, 0x21212121,  0, 0x21212121 )
        TEST_RR_OP( srl, 0x21212121,  1, 0x10909090 )
        TEST_RR_OP( srl, 0x21212121,  7, 0x00424242 )
        TEST_RR_OP( srl, 0x21212121, 14, 0x00008484 )
        TEST_RR_OP( srl, 0x21212121, 31, 0x00000000 )

        // Verify that shifts only use bottom five bits

        TEST_RR_OP( srl, 0x21212121, 0xffffffe0, 0x21212121 )
        TEST_RR_OP( srl, 0x21212121, 0xffffffe1, 0x10909090 )
        TEST_RR_OP( srl, 0x21212121, 0xffffffe7, 0x00424242 )
        TEST_RR_OP( srl, 0x21212121, 0xffffffee, 0x00008484 )
        TEST_RR_OP( srl, 0x21212121, 0xffffffff, 0x00000000 )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_RR_SRC0_EQ_DEST( srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_SRC1_EQ_DEST( srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_SRCS_EQ_DEST( srl, 7, 0 )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_RR_DEST_BYP( 0, srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_DEST_BYP( 1, srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_DEST_BYP( 2, srl, 0x80000000, 31, 0x00000001 )

        TEST_RR_SRC01_BYP( 0, 0, srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_SRC01_BYP( 0, 1, srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_SRC01_BYP( 0, 2, srl, 0x80000000, 31, 0x00000001 )
        TEST_RR_SRC01_BYP( 1, 0, srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_SRC01_BYP( 1, 1, srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_SRC01_BYP( 2, 0, srl, 0x80000000, 31, 0x00000001 )

        TEST_RR_SRC10_BYP( 0, 0, srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_SRC10_BYP( 0, 1, srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_SRC10_BYP( 0, 2, srl, 0x80000000, 31, 0x00000001 )
        TEST_RR_SRC10_BYP( 1, 0, srl, 0x80000000,  7, 0x01000000 )
        TEST_RR_SRC10_BYP( 1, 1, srl, 0x80000000, 14, 0x00020000 )
        TEST_RR_SRC10_BYP( 2, 0, srl, 0x80000000, 31, 0x00000001 )

        TEST_RISCV_END

