//=========================================================================
// 7-Stage RISCV-minimal Control Unit
//=========================================================================

`ifndef RISCV_CORE_CTRL_V
`define RISCV_CORE_CTRL_V

`include "riscvlong-InstMsg.v"

module riscv_CoreCtrl
(
  input clk,
  input reset,

  // Instruction Memory Port
  output        imemreq_val,
  input         imemreq_rdy,
  input  [31:0] imemresp_msg_data,
  input         imemresp_val,

  // Data Memory Port

  output        dmemreq_msg_rw,
  output  [1:0] dmemreq_msg_len,
  output        dmemreq_val,
  input         dmemreq_rdy,
  input         dmemresp_val,

  // Controls Signals (ctrl->dpath)

  output  [1:0] pc_mux_sel_Phl,
  output  [1:0] op0_mux_sel_Dhl,
  output  [2:0] op1_mux_sel_Dhl,
  output [31:0] inst_Dhl,
  output  [3:0] alu_fn_Xhl,
  output  [2:0] muldivreq_msg_fn_Dhl,
  output        muldivreq_val,
  input         muldivreq_rdy,
  input         muldivresp_val,
  output        muldivresp_rdy,
  output        muldiv_mux_sel_X3hl,
  output        execute_mux_sel_X3hl,
  output  [2:0] dmemresp_mux_sel_Mhl,
  output        dmemresp_queue_en_Mhl,
  output        dmemresp_queue_val_Mhl,
  output        wb_mux_sel_Mhl,
  output        rf_wen_out_Whl,
  output  [4:0] rf_waddr_Whl,
  output        stall_Fhl,
  output        stall_Dhl,
  output        stall_Xhl,
  output        stall_Mhl,
  output        stall_Whl,
  output  [2:0] rdata0_byp_mux_sel_Dhl,
	output  [2:0] rdata1_byp_mux_sel_Dhl,

	output				stall_X2hl,
	output				stall_X3hl,

  // Control Signals (dpath->ctrl)

  input         branch_cond_eq_Xhl,
  input         branch_cond_ne_Xhl,
  input         branch_cond_lt_Xhl,
  input         branch_cond_ltu_Xhl,
  input         branch_cond_ge_Xhl,
  input         branch_cond_geu_Xhl,
  input  [31:0] proc2csr_data_Whl,

  // CSR Status

  output [31:0] csr_status
);

  //----------------------------------------------------------------------
  // PC Stage: Instruction Memory Request
  //----------------------------------------------------------------------

  // PC Mux Select

  assign pc_mux_sel_Phl
    = brj_taken_Xhl    ? pm_b
    : brj_taken_Dhl    ? pc_mux_sel_Dhl
    :                    pm_p;

  // Only send a valid imem request if not stalled

  wire   imemreq_val_Phl = reset || !stall_Phl;
  assign imemreq_val     = imemreq_val_Phl;

  // Dummy Squash Signal

  wire squash_Phl = 1'b0;

  // Stall in PC if F is stalled

  wire stall_Phl = stall_Fhl;

  // Next bubble bit

  wire bubble_next_Phl = ( squash_Phl || stall_Phl );

  //----------------------------------------------------------------------
  // F <- P
  //----------------------------------------------------------------------

  reg imemreq_val_Fhl;

  reg bubble_Fhl;

  always @ ( posedge clk ) begin
    // Only pipeline the bubble bit if the next stage is not stalled
    if ( reset ) begin
      bubble_Fhl <= 1'b0;
    end
    else if( !stall_Fhl ) begin
      bubble_Fhl <= bubble_next_Phl;
    end
    imemreq_val_Fhl <= imemreq_val_Phl;
  end

  //----------------------------------------------------------------------
  // Fetch Stage: Instruction Memory Response
  //----------------------------------------------------------------------

  // Is the current stage valid?

  wire inst_val_Fhl = ( !bubble_Fhl && !squash_Fhl );

  // Squash instruction in F stage if branch taken for a valid
  // instruction or if there was an exception in X stage

  wire squash_Fhl
    = ( inst_val_Dhl && brj_taken_Dhl )
   || ( inst_val_Xhl && brj_taken_Xhl );

  // Stall in F if D is stalled

  assign stall_Fhl = stall_Dhl;

  // Next bubble bit

  wire bubble_sel_Fhl  = ( squash_Fhl || stall_Fhl );
  wire bubble_next_Fhl = ( !bubble_sel_Fhl ) ? bubble_Fhl
                       : ( bubble_sel_Fhl )  ? 1'b1
                       :                       1'bx;

  //----------------------------------------------------------------------
  // Queue for instruction memory response
  //----------------------------------------------------------------------

  wire imemresp_queue_en_Fhl = ( stall_Dhl && imemresp_val );
  wire imemresp_queue_val_next_Fhl
    = stall_Dhl && ( imemresp_val || imemresp_queue_val_Fhl );

  reg [31:0] imemresp_queue_reg_Fhl;
  reg        imemresp_queue_val_Fhl;

  always @ ( posedge clk ) begin
    if ( imemresp_queue_en_Fhl ) begin
      imemresp_queue_reg_Fhl <= imemresp_msg_data;
    end
    imemresp_queue_val_Fhl <= imemresp_queue_val_next_Fhl;
  end

  //----------------------------------------------------------------------
  // Instruction memory queue mux
  //----------------------------------------------------------------------

  wire [31:0] imemresp_queue_mux_out_Fhl
    = ( !imemresp_queue_val_Fhl ) ? imemresp_msg_data
    : ( imemresp_queue_val_Fhl )  ? imemresp_queue_reg_Fhl
    :                               32'bx;

  //----------------------------------------------------------------------
  // D <- F
  //----------------------------------------------------------------------

  reg [31:0] ir_Dhl;
  reg        bubble_Dhl;

  always @ ( posedge clk ) begin
    if ( reset ) begin
      bubble_Dhl <= 1'b1;
    end
    else if( !stall_Dhl ) begin
      ir_Dhl     <= imemresp_queue_mux_out_Fhl;
      bubble_Dhl <= bubble_next_Fhl;
    end
  end

  //----------------------------------------------------------------------
  // Decode Stage: Constants
  //----------------------------------------------------------------------

  // Generic Parameters

  localparam n = 1'd0;
  localparam y = 1'd1;

  // Register specifiers

  localparam rx = 5'bx;
  localparam r0 = 5'd0;

  // Branch Type

  localparam br_x    = 3'bx;
  localparam br_none = 3'd0;
  localparam br_beq  = 3'd1;
  localparam br_bne  = 3'd2;
  localparam br_blt  = 3'd3;
  localparam br_bltu = 3'd4;
  localparam br_bge  = 3'd5;
  localparam br_bgeu = 3'd6;

  // PC Mux Select

  localparam pm_x   = 2'bx;  // Don't care
  localparam pm_p   = 2'd0;  // Use pc+4
  localparam pm_b   = 2'd1;  // Use branch address
  localparam pm_j   = 2'd2;  // Use jump address
  localparam pm_r   = 2'd3;  // Use jump register

  // Operand 0 Mux Select

  localparam am_x     = 2'bx;
  localparam am_rdat  = 2'd0; // Use output of bypass mux for rs1
  localparam am_pc    = 2'd1; // Use current PC
  localparam am_pc4   = 2'd2; // Use PC + 4
  localparam am_0     = 2'd3; // Use constant 0

  // Operand 1 Mux Select

  localparam bm_x      = 3'bx; // Don't care
  localparam bm_rdat   = 3'd0; // Use output of bypass mux for rs2
  localparam bm_shamt  = 3'd1; // Use shift amount
  localparam bm_imm_u  = 3'd2; // Use U-type immediate
  localparam bm_imm_sb = 3'd3; // Use SB-type immediate // it will never be an operand
  localparam bm_imm_i  = 3'd4; // Use I-type immediate
  localparam bm_imm_s  = 3'd5; // Use S-type immediate
  localparam bm_0      = 3'd6; // Use constant 0

  // ALU Function

  localparam alu_x    = 4'bx;
  localparam alu_add  = 4'd0;
  localparam alu_sub  = 4'd1;
  localparam alu_sll  = 4'd2;
  localparam alu_or   = 4'd3;
  localparam alu_lt   = 4'd4;
  localparam alu_ltu  = 4'd5;
  localparam alu_and  = 4'd6;
  localparam alu_xor  = 4'd7;
  localparam alu_nor  = 4'd8;
  localparam alu_srl  = 4'd9;
  localparam alu_sra  = 4'd10;

  // Muldiv Function

  localparam md_x    = 3'bx;
  localparam md_mul  = 3'd0;
  localparam md_div  = 3'd1;
  localparam md_divu = 3'd2;
  localparam md_rem  = 3'd3;
  localparam md_remu = 3'd4;
	localparam md_mulu = 3'd5;
	localparam md_mulsu= 3'd6;

  // MulDiv Mux Select

  localparam mdm_x = 1'bx; // Don't Care
  localparam mdm_l = 1'd0; // Take lower half of 64-bit result, mul/div/divu
  localparam mdm_u = 1'd1; // Take upper half of 64-bit result, rem/remu

  // Execute Mux Select

  localparam em_x   = 1'bx; // Don't Care
  localparam em_alu = 1'd0; // Use ALU output
  localparam em_md  = 1'd1; // Use muldiv output

  // Memory Request Type

  localparam nr = 2'b0; // No request
  localparam ld = 2'd1; // Load
  localparam st = 2'd2; // Store

  // Subword Memop Length

  localparam ml_x  = 2'bx;
  localparam ml_w  = 2'd0;
  localparam ml_b  = 2'd1;
  localparam ml_h  = 2'd2;

  // Memory Response Mux Select

  localparam dmm_x  = 3'bx;
  localparam dmm_w  = 3'd0;
  localparam dmm_b  = 3'd1;
  localparam dmm_bu = 3'd2;
  localparam dmm_h  = 3'd3;
  localparam dmm_hu = 3'd4;

  // Writeback Mux 1

  localparam wm_x   = 1'bx; // Don't care
  localparam wm_alu = 1'd0; // Use ALU output
  localparam wm_mem = 1'd1; // Use data memory response

  //----------------------------------------------------------------------
  // Decode Stage: Logic
  //----------------------------------------------------------------------

  // Is the current stage valid?

  wire inst_val_Dhl = ( !bubble_Dhl && !squash_Dhl );

  // Ship instruction for field parsing to datapath

  assign inst_Dhl = ir_Dhl;

  // Parse instruction fields

  wire   [4:0] inst_rs1_Dhl;
  wire   [4:0] inst_rs2_Dhl;
  wire   [4:0] inst_rd_Dhl;

  riscv_InstMsgFromBits inst_msg_from_bits
  (
    .msg      (ir_Dhl),
    .opcode   (),
    .rs1      (inst_rs1_Dhl),
    .rs2      (inst_rs2_Dhl),
    .rd       (inst_rd_Dhl),
    .funct3   (),
    .funct7   (),
    .shamt    (),
    .imm_i    (),
    .imm_s    (),
    .imm_sb   (),
    .imm_u    (),
    .imm_uj   ()
  );

  // Shorten register specifier name for table

  wire [4:0] rs1 = inst_rs1_Dhl;
  wire [4:0] rs2 = inst_rs2_Dhl;
  wire [4:0] rd  = inst_rd_Dhl;

  // Instruction Decode

  localparam cs_sz = `RISCV_INST_MSG_CS_SZ;
  reg [cs_sz-1:0] cs;

  always @ (*) begin

    cs = {cs_sz{1'bx}}; // Default to invalid instruction

    casez ( ir_Dhl )

      //                                j     br       pc      op0      rs1 op1       rs2 alu       md       md md     ex      mem  mem   memresp wb      rf      csr
      //                            val taken type     muxsel  muxsel   en  muxsel    en  fn        fn       en muxsel muxsel  rq   len   muxsel  muxsel  wen wa  wen
      `RISCV_INST_MSG_LUI     :cs={ y,  n,    br_none, pm_p,   am_0,    n,  bm_imm_u, n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
      `RISCV_INST_MSG_AUIPC   :cs={ y,  n,    br_none, pm_p,   am_pc,   n,  bm_imm_u, n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };

      `RISCV_INST_MSG_ADDI    :cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
      `RISCV_INST_MSG_ORI     :cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_or,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };

      `RISCV_INST_MSG_ADD     :cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };

      `RISCV_INST_MSG_LW      :cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_alu,   ld,  ml_w, dmm_w,  wm_mem, y,  rd, n   };
      `RISCV_INST_MSG_SW      :cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_s, y,  alu_add,  md_x,    n, mdm_x, em_alu,   st,  ml_w, dmm_w,  wm_mem, n,  rx, n   };

      `RISCV_INST_MSG_JAL     :cs={ y,  y,    br_none, pm_j,   am_pc4,  n,  bm_0,     n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };

      `RISCV_INST_MSG_BNE     :cs={ y,  n,    br_bne,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_xor,  md_x,    n, mdm_x, em_alu,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
      `RISCV_INST_MSG_BLT     :cs={ y,  n,    br_blt,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_alu,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };

      `RISCV_INST_MSG_CSRW    :cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_0,     n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, n,  rx, y   };

			`RISCV_INST_MSG_JALR		:cs={ y,  y,    br_none, pm_r,   am_pc4,  y,  bm_0,     n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };   
			
			`RISCV_INST_MSG_BEQ			:cs={ y,  n,    br_beq,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_xor,  md_x,    n, mdm_x, em_alu,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };  
			`RISCV_INST_MSG_BGE			:cs={ y,  n,    br_bge,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_alu,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
			`RISCV_INST_MSG_BLTU		:cs={ y,  n,    br_bltu, pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_alu,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
			`RISCV_INST_MSG_BGEU		:cs={ y,  n,    br_bgeu, pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_alu,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
			
			`RISCV_INST_MSG_LB			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_alu,   ld,  ml_b, dmm_b,  wm_mem, y,  rd, n   };
			`RISCV_INST_MSG_LH			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_alu,   ld,  ml_h, dmm_h,  wm_mem, y,  rd, n   };
			`RISCV_INST_MSG_LBU			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_alu,   ld,  ml_b, dmm_bu, wm_mem, y,  rd, n   };
			`RISCV_INST_MSG_LHU			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_alu,   ld,  ml_h, dmm_hu, wm_mem, y,  rd, n   };

			
			`RISCV_INST_MSG_SB			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_s, y,  alu_add,  md_x,    n, mdm_x, em_alu,   st,  ml_b, dmm_b,  wm_mem, n,  rx, n   };
			`RISCV_INST_MSG_SH			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_s, y,  alu_add,  md_x,    n, mdm_x, em_alu,   st,  ml_h, dmm_h,  wm_mem, n,  rx, n   };
			
			`RISCV_INST_MSG_NOP			:cs={ y,  n,    br_none, pm_p,   am_rdat, n,  bm_rdat,  n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, n,  rx, n   };
			
			`RISCV_INST_MSG_SLTI		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_lt,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_SLTIU		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_ltu,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			
			`RISCV_INST_MSG_XORI		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_xor,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_ANDI		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_and,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			
			`RISCV_INST_MSG_SLLI		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_shamt, n,  alu_sll,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_SRLI		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_shamt, n,  alu_srl,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_SRAI		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_shamt, n,  alu_sra,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			
			`RISCV_INST_MSG_SUB			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_SLL			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_sll,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_SLT			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_lt,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_SLTU		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_ltu,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			
			`RISCV_INST_MSG_XOR			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_xor,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_SRL			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_srl,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_SRA			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_sra,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_OR			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_or,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_AND			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_and,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };

			`RISCV_INST_MSG_MUL			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_mul,  y, mdm_l, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_DIV			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_div,  y, mdm_l, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_DIVU		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_divu, y, mdm_l, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_REM			:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_rem,  y, mdm_u, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_REMU		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_remu, y, mdm_u, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };

			`RISCV_INST_MSG_MULH		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_mul,  y, mdm_u, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_MULHSU	:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_mulsu,y, mdm_u, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };
			`RISCV_INST_MSG_MULHU		:cs={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_mulu, y, mdm_u, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd, n   };



		endcase


  end

  // Jump and Branch Controls

  wire       brj_taken_Dhl = ( inst_val_Dhl && cs[`RISCV_INST_MSG_J_EN] );
  wire [2:0] br_sel_Dhl    = cs[`RISCV_INST_MSG_BR_SEL]; 

  // PC Mux Select

  wire [1:0] pc_mux_sel_Dhl = cs[`RISCV_INST_MSG_PC_SEL];

  // Operand RF Read Addresses and Enables (using rs or rt?)

  wire [4:0] rs1_addr_Dhl   = inst_rs1_Dhl;
  wire [4:0] rs2_addr_Dhl   = inst_rs2_Dhl;

  wire       rs1_en_Dhl     = cs[`RISCV_INST_MSG_RS1_EN];
  wire       rs2_en_Dhl     = cs[`RISCV_INST_MSG_RS2_EN];

  // Operand Mux Select

  assign op0_mux_sel_Dhl = cs[`RISCV_INST_MSG_OP0_SEL];
  assign op1_mux_sel_Dhl = cs[`RISCV_INST_MSG_OP1_SEL];

  // ALU Function

  wire [3:0] alu_fn_Dhl = cs[`RISCV_INST_MSG_ALU_FN];

  // Muldiv Function

  wire [2:0] muldivreq_msg_fn_Dhl = cs[`RISCV_INST_MSG_MULDIV_FN];

  // Muldiv Controls

  wire muldivreq_val_Dhl = cs[`RISCV_INST_MSG_MULDIV_EN];

  // Muldiv Mux Select

  wire muldiv_mux_sel_Dhl = cs[`RISCV_INST_MSG_MULDIV_SEL];

  // Execute Mux Select

  wire execute_mux_sel_Dhl = cs[`RISCV_INST_MSG_EX_SEL];

  // Memory Controls

  wire       dmemreq_msg_rw_Dhl  = ( cs[`RISCV_INST_MSG_MEM_REQ] == st );
  wire [1:0] dmemreq_msg_len_Dhl = cs[`RISCV_INST_MSG_MEM_LEN];
  wire       dmemreq_val_Dhl     = ( cs[`RISCV_INST_MSG_MEM_REQ] != nr );
	wire			 is_ld_Dhl					 = ( cs[`RISCV_INST_MSG_MEM_REQ] == ld );

  // Memory response mux select

  wire [2:0] dmemresp_mux_sel_Dhl = cs[`RISCV_INST_MSG_MEM_SEL];

  // Writeback Mux Select

  wire wb_mux_sel_Dhl = cs[`RISCV_INST_MSG_WB_SEL];

  // Register Writeback Controls

  wire rf_wen_Dhl         = cs[`RISCV_INST_MSG_RF_WEN];
  wire [4:0] rf_waddr_Dhl = cs[`RISCV_INST_MSG_RF_WADDR];

  // CSR register write enable

  wire csr_wen_Dhl = cs[`RISCV_INST_MSG_CSR_WEN];

  // CSR register address

  wire [11:0] csr_addr_Dhl  = ir_Dhl[31:20];

  //----------------------------------------------------------------------
  // Squash and Stall Logic
  //----------------------------------------------------------------------

  // Squash instruction in D if a valid branch in X is taken

  wire squash_Dhl = ( inst_val_Xhl && brj_taken_Xhl );

  // Stall in D if muldiv unit is not ready and there is a valid request

  wire stall_muldiv_Dhl = ( muldivreq_val_Dhl && inst_val_Dhl && !muldivreq_rdy );

  // Stall for data hazards if load-use or mul-use

  wire stall_hazard_Dhl   = inst_val_Dhl && (
                            ( rs1_en_Dhl && inst_val_Xhl && is_ld_Xhl
                              && ( rs1_addr_Dhl == rf_waddr_Xhl )
                              && ( rf_waddr_Xhl != 5'd0 ) )
                         || ( rs2_en_Dhl && inst_val_Xhl && is_ld_Xhl
                              && ( rs2_addr_Dhl == rf_waddr_Xhl )
                              && ( rf_waddr_Xhl != 5'd0 ) ) 
												 || ( rs1_en_Dhl && inst_val_Xhl && execute_mux_sel_Xhl
                              && ( rs1_addr_Dhl == rf_waddr_Xhl )
                              && ( rf_waddr_Xhl != 5'd0 ) )
												 || ( rs1_en_Dhl && inst_val_Mhl && execute_mux_sel_Mhl
                              && ( rs1_addr_Dhl == rf_waddr_Mhl )
                              && ( rf_waddr_Mhl != 5'd0 ) )
												 || ( rs1_en_Dhl && inst_val_X2hl && execute_mux_sel_X2hl
                              && ( rs1_addr_Dhl == rf_waddr_X2hl )
                              && ( rf_waddr_X2hl != 5'd0 ) )
												 || ( rs2_en_Dhl && inst_val_Xhl && execute_mux_sel_Xhl
                              && ( rs2_addr_Dhl == rf_waddr_Xhl )
                              && ( rf_waddr_Xhl != 5'd0 ) )
												 || ( rs2_en_Dhl && inst_val_Mhl && execute_mux_sel_Mhl
                              && ( rs2_addr_Dhl == rf_waddr_Mhl )
                              && ( rf_waddr_Mhl != 5'd0 ) )
												 || ( rs2_en_Dhl && inst_val_X2hl && execute_mux_sel_X2hl
                              && ( rs2_addr_Dhl == rf_waddr_X2hl )
                              && ( rf_waddr_X2hl != 5'd0 ) )
												 );

	// Bypassing logic from X, M, X2, X3, W to D
	
	wire rdata0_byp_mux_sel_Dhl
		= ( rs1_en_Dhl && rf_wen_Xhl && (rs1_addr_Dhl == rf_waddr_Xhl) && (rf_waddr_Xhl != 5'd0) && inst_val_Xhl ) ? 3'd1
	  : ( rs1_en_Dhl && rf_wen_Mhl && (rs1_addr_Dhl == rf_waddr_Mhl) && (rf_waddr_Mhl != 5'd0) && inst_val_Mhl ) ? 3'd2
	  : ( rs1_en_Dhl && rf_wen_X2hl && (rs1_addr_Dhl == rf_waddr_X2hl) && (rf_waddr_X2hl != 5'd0) && inst_val_X2hl ) ? 3'd3
	  : ( rs1_en_Dhl && rf_wen_X3hl && (rs1_addr_Dhl == rf_waddr_X3hl) && (rf_waddr_X3hl != 5'd0) && inst_val_X3hl ) ? 3'd4
	  : ( rs1_en_Dhl && rf_wen_Whl && (rs1_addr_Dhl == rf_waddr_Whl) && (rf_waddr_Whl != 5'd0) && inst_val_Whl ) ? 3'd5
	  :  3'd0;	

  wire rdata1_byp_mux_sel_Dhl 	
		= ( rs2_en_Dhl && rf_wen_Xhl && (rs2_addr_Dhl == rf_waddr_Xhl) && (rf_waddr_Xhl != 5'd0) && inst_val_Xhl ) ? 3'd1
	  : ( rs2_en_Dhl && rf_wen_Mhl && (rs2_addr_Dhl == rf_waddr_Mhl) && (rf_waddr_Mhl != 5'd0) && inst_val_Mhl ) ? 3'd2
	  : ( rs2_en_Dhl && rf_wen_X2hl && (rs2_addr_Dhl == rf_waddr_X2hl) && (rf_waddr_X2hl != 5'd0) && inst_val_X2hl ) ? 3'd3
	  : ( rs2_en_Dhl && rf_wen_X3hl && (rs2_addr_Dhl == rf_waddr_X3hl) && (rf_waddr_X3hl != 5'd0) && inst_val_X3hl ) ? 3'd4
	  : ( rs2_en_Dhl && rf_wen_Whl && (rs2_addr_Dhl == rf_waddr_Whl) && (rf_waddr_Whl != 5'd0) && inst_val_Whl ) ? 3'd5
	  :  3'd0;	

  // Aggregate Stall Signal

  assign stall_Dhl = ( stall_Xhl
                  ||   stall_muldiv_Dhl
                  ||   stall_hazard_Dhl );

  // Next bubble bit

  wire bubble_sel_Dhl  = ( squash_Dhl || stall_Dhl );
  wire bubble_next_Dhl = ( !bubble_sel_Dhl ) ? bubble_Dhl
                       : ( bubble_sel_Dhl )  ? 1'b1
                       :                       1'bx;

	// Muldiv request

  assign muldivreq_val = muldivreq_val_Dhl && inst_val_Dhl && !stall_Xhl;
  assign muldivresp_rdy = !stall_X3hl;



  //----------------------------------------------------------------------
  // X <- D
  //----------------------------------------------------------------------

  reg [31:0] ir_Xhl;
  reg  [2:0] br_sel_Xhl;
  reg  [3:0] alu_fn_Xhl;
  reg        muldivreq_val_Xhl;
  reg  [2:0] muldivreq_msg_fn_Xhl;
  reg        muldiv_mux_sel_Xhl;
  reg        execute_mux_sel_Xhl;
  reg        dmemreq_msg_rw_Xhl;
  reg  [1:0] dmemreq_msg_len_Xhl;
  reg        dmemreq_val_Xhl;
  reg  [2:0] dmemresp_mux_sel_Xhl;
  reg        wb_mux_sel_Xhl;
  reg        rf_wen_Xhl;
  reg  [4:0] rf_waddr_Xhl;
  reg        csr_wen_Xhl;
  reg [11:0] csr_addr_Xhl;

	reg				 is_ld_Xhl;

  reg        bubble_Xhl;

  // Pipeline Controls

  always @ ( posedge clk ) begin
    if ( reset ) begin
      bubble_Xhl <= 1'b1;
    end
    else if( !stall_Xhl ) begin
      ir_Xhl               <= ir_Dhl;
      br_sel_Xhl           <= br_sel_Dhl;
      alu_fn_Xhl           <= alu_fn_Dhl;
      muldivreq_val_Xhl    <= muldivreq_val_Dhl;
      muldivreq_msg_fn_Xhl <= muldivreq_msg_fn_Dhl;
      muldiv_mux_sel_Xhl   <= muldiv_mux_sel_Dhl;
      execute_mux_sel_Xhl  <= execute_mux_sel_Dhl;
      dmemreq_msg_rw_Xhl   <= dmemreq_msg_rw_Dhl;
      dmemreq_msg_len_Xhl  <= dmemreq_msg_len_Dhl;
      dmemreq_val_Xhl      <= dmemreq_val_Dhl;
      dmemresp_mux_sel_Xhl <= dmemresp_mux_sel_Dhl;
      wb_mux_sel_Xhl       <= wb_mux_sel_Dhl;
      rf_wen_Xhl           <= rf_wen_Dhl;
      rf_waddr_Xhl         <= rf_waddr_Dhl;
      csr_wen_Xhl          <= csr_wen_Dhl;
      csr_addr_Xhl         <= csr_addr_Dhl;

			is_ld_Xhl						 <= is_ld_Dhl;

      bubble_Xhl           <= bubble_next_Dhl;
    end

  end

  //----------------------------------------------------------------------
  // Execute Stage
  //----------------------------------------------------------------------

  // Is the current stage valid?

  wire inst_val_Xhl = ( !bubble_Xhl && !squash_Xhl );

  // Muldiv request
	// Request sent to muldiv unit is moved to the D stage

  // Only send a valid dmem request if not stalled

  assign dmemreq_msg_rw  = dmemreq_msg_rw_Xhl;
  assign dmemreq_msg_len = dmemreq_msg_len_Xhl;
  assign dmemreq_val     = ( inst_val_Xhl && !stall_Xhl && dmemreq_val_Xhl );

  // Resolve Branch

  wire bne_taken_Xhl  = ( ( br_sel_Xhl == br_bne ) && branch_cond_ne_Xhl );
  wire blt_taken_Xhl  = ( ( br_sel_Xhl == br_blt ) && branch_cond_lt_Xhl );
  wire beq_taken_Xhl  = ( ( br_sel_Xhl == br_beq ) && branch_cond_eq_Xhl );
  wire bge_taken_Xhl  = ( ( br_sel_Xhl == br_bge ) && branch_cond_ge_Xhl );
  wire bltu_taken_Xhl  = ( ( br_sel_Xhl == br_bltu ) && branch_cond_ltu_Xhl );
  wire bgeu_taken_Xhl  = ( ( br_sel_Xhl == br_bgeu ) && branch_cond_geu_Xhl ); 
	
	wire any_br_taken_Xhl
    = ( bne_taken_Xhl || blt_taken_Xhl || beq_taken_Xhl || bge_taken_Xhl || bltu_taken_Xhl || bgeu_taken_Xhl
      );

  wire brj_taken_Xhl = ( inst_val_Xhl && any_br_taken_Xhl );

  // Dummy Squash Signal

  wire squash_Xhl = 1'b0;

  // Stall in X if muldiv reponse is not valid and there was a valid request

  wire stall_muldiv_Xhl = 1'b0; // ( muldivreq_val_Xhl && inst_val_Xhl && !muldivresp_val );

  // Stall in X if imem is not ready

  wire stall_imem_Xhl = !imemreq_rdy;

  // Stall in X if dmem is not ready and there was a valid request

  wire stall_dmem_Xhl = ( dmemreq_val_Xhl && inst_val_Xhl && !dmemreq_rdy );

  // Aggregate Stall Signal

  assign stall_Xhl = ( stall_Mhl || stall_muldiv_Xhl || stall_imem_Xhl || stall_dmem_Xhl );

  // Next bubble bit

  wire bubble_sel_Xhl  = ( squash_Xhl || stall_Xhl );
  wire bubble_next_Xhl = ( !bubble_sel_Xhl ) ? bubble_Xhl
                       : ( bubble_sel_Xhl )  ? 1'b1
                       :                       1'bx;

  //----------------------------------------------------------------------
  // M <- X
  //----------------------------------------------------------------------

  reg [31:0] ir_Mhl;
  reg        dmemreq_val_Mhl;
  reg  [2:0] dmemresp_mux_sel_Mhl;
  reg        wb_mux_sel_Mhl;
  reg        rf_wen_Mhl;
  reg  [4:0] rf_waddr_Mhl;
  reg        csr_wen_Mhl;
  reg [11:0] csr_addr_Mhl;

	reg        muldiv_mux_sel_Mhl;
  reg        execute_mux_sel_Mhl;

  reg        bubble_Mhl;

  // Pipeline Controls

  always @ ( posedge clk ) begin
    if ( reset ) begin
      bubble_Mhl <= 1'b1;
    end
    else if( !stall_Mhl ) begin
      ir_Mhl               <= ir_Xhl;
      dmemresp_mux_sel_Mhl <= dmemresp_mux_sel_Xhl;
      wb_mux_sel_Mhl       <= wb_mux_sel_Xhl;
      rf_wen_Mhl           <= rf_wen_Xhl;
      rf_waddr_Mhl         <= rf_waddr_Xhl;
      csr_wen_Mhl          <= csr_wen_Xhl;
      csr_addr_Mhl         <= csr_addr_Xhl;
			
			muldiv_mux_sel_Mhl   <= muldiv_mux_sel_Xhl;
      execute_mux_sel_Mhl  <= execute_mux_sel_Xhl;
      
      bubble_Mhl           <= bubble_next_Xhl;
    end
    dmemreq_val_Mhl <= dmemreq_val;
  end

  //----------------------------------------------------------------------
  // Memory Stage
  //----------------------------------------------------------------------

  // Is current stage valid?

  wire inst_val_Mhl = ( !bubble_Mhl && !squash_Mhl );

  // Data memory queue control signals

  assign dmemresp_queue_en_Mhl = ( stall_Mhl && dmemresp_val );
  wire   dmemresp_queue_val_next_Mhl
    = stall_Mhl && ( dmemresp_val || dmemresp_queue_val_Mhl );

  // Dummy Squash Signal

  wire squash_Mhl = 1'b0;

  // Stall in M if memory response is not returned for a valid request

  wire stall_dmem_Mhl = ( !reset && dmemreq_val_Mhl && inst_val_Mhl && !dmemresp_val );
  wire stall_imem_Mhl = ( !reset && imemreq_val_Fhl && inst_val_Fhl && !imemresp_val );

  // Aggregate Stall Signal

  wire stall_Mhl = ( stall_imem_Mhl || stall_dmem_Mhl );

  // Next bubble bit

  wire bubble_sel_Mhl  = ( squash_Mhl || stall_Mhl );
  wire bubble_next_Mhl = ( !bubble_sel_Mhl ) ? bubble_Mhl
                       : ( bubble_sel_Mhl )  ? 1'b1
                       :                       1'bx;

  //----------------------------------------------------------------------
  // X2 <- M
  //----------------------------------------------------------------------

  reg [31:0] ir_X2hl;
  reg        dmemresp_queue_val_Mhl;
  reg        rf_wen_X2hl;
  reg  [4:0] rf_waddr_X2hl;
  reg        csr_wen_X2hl;
  reg [11:0] csr_addr_X2hl;

  reg        muldiv_mux_sel_X2hl;
  reg        execute_mux_sel_X2hl;

  reg        bubble_X2hl;
  
	wire inst_val_X2hl = ( !bubble_X2hl && !squash_X2hl );
  wire squash_X2hl = 1'b0;
  wire stall_X2hl  = 1'b0;


  // Pipeline Controls

  always @ ( posedge clk ) begin
    if ( reset ) begin
      bubble_X2hl <= 1'b1;
    end
    else if( !stall_X2hl ) begin
      ir_X2hl           <= ir_Mhl;
      rf_wen_X2hl       <= rf_wen_Mhl;
      rf_waddr_X2hl     <= rf_waddr_Mhl;
      csr_wen_X2hl      <= csr_wen_Mhl;
      csr_addr_X2hl     <= csr_addr_Mhl;

			muldiv_mux_sel_X2hl   <= muldiv_mux_sel_Mhl;
      execute_mux_sel_X2hl  <= execute_mux_sel_Mhl;
      

      bubble_X2hl       <= bubble_next_Mhl;   
    end
    dmemresp_queue_val_Mhl <= dmemresp_queue_val_next_Mhl;
  end

  //----------------------------------------------------------------------
  // X3 <- X2
  //----------------------------------------------------------------------

  reg [31:0] ir_X3hl;
  reg        rf_wen_X3hl;
  reg  [4:0] rf_waddr_X3hl;
  reg        csr_wen_X3hl;
  reg [11:0] csr_addr_X3hl;

  reg        muldiv_mux_sel_X3hl;
  reg        execute_mux_sel_X3hl;

  reg        bubble_X3hl;
  
	wire inst_val_X3hl = ( !bubble_X3hl && !squash_X3hl );
  wire squash_X3hl = 1'b0;
  wire stall_X3hl  = 1'b0;


  // Pipeline Controls

  always @ ( posedge clk ) begin
    if ( reset ) begin
      bubble_X3hl <= 1'b1;
    end
    else if( !stall_X3hl ) begin
      ir_X3hl           <= ir_X2hl;
      rf_wen_X3hl       <= rf_wen_X2hl;
      rf_waddr_X3hl     <= rf_waddr_X2hl;
      csr_wen_X3hl      <= csr_wen_X2hl;
      csr_addr_X3hl     <= csr_addr_X2hl;

			muldiv_mux_sel_X3hl   <= muldiv_mux_sel_X2hl;
      execute_mux_sel_X3hl  <= execute_mux_sel_X2hl;
      

			// assume squash == 0 and stall == 0
      bubble_X3hl       <= bubble_X2hl;
    end
  end

  //----------------------------------------------------------------------
  // W <- X3
  //----------------------------------------------------------------------

  reg [31:0] ir_Whl;
  reg        rf_wen_Whl;
  reg  [4:0] rf_waddr_Whl;
  reg        csr_wen_Whl;
  reg [11:0] csr_addr_Whl;

  reg        bubble_Whl;

  // Pipeline Controls

  always @ ( posedge clk ) begin
    if ( reset ) begin
      bubble_Whl <= 1'b1;
    end
    else if( !stall_Whl ) begin
      ir_Whl           <= ir_X3hl;
      rf_wen_Whl       <= rf_wen_X3hl;
      rf_waddr_Whl     <= rf_waddr_X3hl;
      csr_wen_Whl      <= csr_wen_X3hl;
      csr_addr_Whl     <= csr_addr_X3hl;

			// assume squash == 0 and stall == 0
      bubble_Whl       <= bubble_X3hl;
    end
  end

  //----------------------------------------------------------------------
  // Writeback Stage
  //----------------------------------------------------------------------

  // Is current stage valid?

  wire inst_val_Whl = ( !bubble_Whl && !squash_Whl );

  // Only set register file wen if stage is valid

  assign rf_wen_out_Whl = ( inst_val_Whl && !stall_Whl && rf_wen_Whl );

  // Dummy squahs and stall signals

  wire squash_Whl = 1'b0;
  wire stall_Whl  = 1'b0;

  //----------------------------------------------------------------------
  // Debug registers for instruction disassembly
  //----------------------------------------------------------------------

  reg [31:0] ir_debug;
  reg        inst_val_debug;

  always @ ( posedge clk ) begin
    ir_debug       <= ir_Whl;
    inst_val_debug <= inst_val_Whl;
  end

  //----------------------------------------------------------------------
  // CSR register
  //----------------------------------------------------------------------

  reg  [31:0] csr_status;
  reg         csr_stats;

  always @ ( posedge clk ) begin
    if ( csr_wen_Whl && inst_val_Whl ) begin
      case ( csr_addr_Whl )
        12'd10 : csr_stats  <= proc2csr_data_Whl[0];
        12'd21 : csr_status <= proc2csr_data_Whl;
      endcase
    end
  end

//========================================================================
// Disassemble instructions
//========================================================================

  `ifndef SYNTHESIS

  riscv_InstMsgDisasm inst_msg_disasm_D
  (
    .msg ( ir_Dhl )
  );

  riscv_InstMsgDisasm inst_msg_disasm_X
  (
    .msg ( ir_Xhl )
  );

  riscv_InstMsgDisasm inst_msg_disasm_M
  (
    .msg ( ir_Mhl )
  );

  riscv_InstMsgDisasm inst_msg_disasm_W
  (
    .msg ( ir_Whl )
  );

  riscv_InstMsgDisasm inst_msg_disasm_debug
  (
    .msg ( ir_debug )
  );

  `endif

//========================================================================
// Assertions
//========================================================================
// Detect illegal instructions and terminate the simulation if multiple
// illegal instructions are detected in succession.

  `ifndef SYNTHESIS

  reg overload = 1'b0;

  always @ ( posedge clk ) begin
    if ( !cs[`RISCV_INST_MSG_INST_VAL] && !reset ) begin
      $display(" RTL-ERROR : %m : Illegal instruction!");

      if ( overload == 1'b1 ) begin
        $finish;
      end

      overload = 1'b1;
    end
    else begin
      overload = 1'b0;
    end
  end

  `endif

//========================================================================
// Stats
//========================================================================

  `ifndef SYNTHESIS

  reg [31:0] num_inst    = 32'b0;
  reg [31:0] num_cycles  = 32'b0;
  reg        stats_en    = 1'b0; // Used for enabling stats on asm tests

  always @( posedge clk ) begin
    if ( !reset ) begin

      // Count cycles if stats are enabled

      if ( stats_en || csr_stats ) begin
        num_cycles = num_cycles + 1;

        // Count instructions for every cycle not squashed or stalled

        if ( inst_val_Dhl && !stall_Dhl ) begin
          num_inst = num_inst + 1;
        end

      end

    end
  end

  `endif

endmodule

`endif

// vim: set textwidth=0 ts=2 sw=2 sts=2 :
