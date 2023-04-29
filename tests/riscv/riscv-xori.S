//=========================================================================
// riscv-xori.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-----------------------------------------------------------------
        // Logical tests
        //-----------------------------------------------------------------

        TEST_IMM_OP( xori, 0xff00ff00, -0x0f1, 0x00ff000f )
        TEST_IMM_OP( xori, 0x0ff00ff0,  0x0f0, 0x0ff00f00 )
        TEST_IMM_OP( xori, 0x00ff00ff, -0x0f1, 0xff00fff0 )
        TEST_IMM_OP( xori, 0xf00ff00f,  0x0f0, 0xf00ff0ff )

        //-----------------------------------------------------------------
        // Source/Destination tests
        //-----------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( xori, 0xff00ff00, -0x0f1, 0x00ff000f )

        //-----------------------------------------------------------------
        // Bypassing tests
        //-----------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, xori, 0x0ff00ff0,  0x0f0, 0x0ff00f00 )
        TEST_IMM_DEST_BYP( 1, xori, 0x00ff00ff, -0x0f1, 0xff00fff0 )
        TEST_IMM_DEST_BYP( 2, xori, 0xf00ff00f,  0x0f0, 0xf00ff0ff )

        TEST_IMM_SRC0_BYP( 0, xori, 0x0ff00ff0,  0x0f0, 0x0ff00f00 )
        TEST_IMM_SRC0_BYP( 1, xori, 0x00ff00ff, -0x0f1, 0xff00fff0 )
        TEST_IMM_SRC0_BYP( 2, xori, 0xf00ff00f,  0x0f0, 0xf00ff0ff )

        TEST_RISCV_END

