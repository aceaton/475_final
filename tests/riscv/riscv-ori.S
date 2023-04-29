//=========================================================================
// riscv-ori.S
//=========================================================================


#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        //-------------------------------------------------------------
        // Logical tests
        //-------------------------------------------------------------

        TEST_IMM_OP( ori, 0xff00ff00, -0x0f1, 0xffffff0f )
        TEST_IMM_OP( ori, 0x0ff00ff0,  0x0f0, 0x0ff00ff0 )
        TEST_IMM_OP( ori, 0x00ff00ff, -0x0f1, 0xffffffff )
        TEST_IMM_OP( ori, 0xf00ff00f,  0x0f0, 0xf00ff0ff )

        //-------------------------------------------------------------
        // Source/Destination tests
        //-------------------------------------------------------------

        TEST_IMM_SRC0_EQ_DEST( ori, 0xff00ff00,  0x0f0, 0xff00fff0 )

        //-------------------------------------------------------------
        // Bypassing tests
        //-------------------------------------------------------------

        TEST_IMM_DEST_BYP( 0, ori, 0x0ff00ff0,  0x0f0, 0x0ff00ff0 );
        TEST_IMM_DEST_BYP( 1, ori, 0x00ff00ff, -0x0f1, 0xffffffff );
        TEST_IMM_DEST_BYP( 2, ori, 0xf00ff00f,  0x0f0, 0xf00ff0ff );

        TEST_IMM_SRC0_BYP( 0, ori, 0x0ff00ff0,  0x0f0, 0x0ff00ff0 );
        TEST_IMM_SRC0_BYP( 1, ori, 0x00ff00ff, -0x0f1, 0xffffffff );
        TEST_IMM_SRC0_BYP( 2, ori, 0xf00ff00f,  0x0f0, 0xf00ff0ff );

        TEST_RISCV_END

