//=========================================================================
// 7-Stage RISCV Datapath
//=========================================================================

`ifndef RISCV_CORE_DPATH_V
`define RISCV_CORE_DPATH_V

`include "riscvlong-CoreDpathPipeMulDiv.v"
`include "riscvlong-InstMsg.v"
`include "riscvlong-CoreDpathAlu.v"
`include "riscvlong-CoreDpathRegfile.v"
`include "riscvlong-CoreDpathVectorRegfile.v"

module riscv_CoreDpath
(
  input clk,
  input reset,

  // Instruction Memory Port

  output [31:0] imemreq_msg_addr,

  // Data Memory Port

  output [31:0] dmemreq_msg_addr,
  output [31:0] dmemreq_msg_data,
  input  [31:0] dmemresp_msg_data,

  // vector mem ports
  output [31:0] v_dmemreq_msg_addr_0,
  output [31:0] v_dmemreq_msg_data_0,
  input  [31:0] v_dmemresp_msg_data_0,

  output [31:0] v_dmemreq_msg_addr_1,
  output [31:0] v_dmemreq_msg_data_1,
  input  [31:0] v_dmemresp_msg_data_1,

  output [31:0] v_dmemreq_msg_addr_2,
  output [31:0] v_dmemreq_msg_data_2,
  input  [31:0] v_dmemresp_msg_data_2,

  output [31:0] v_dmemreq_msg_addr_3,
  output [31:0] v_dmemreq_msg_data_3,
  input  [31:0] v_dmemresp_msg_data_3,

  // Controls Signals (ctrl->dpath)

  input   [1:0] pc_mux_sel_Phl,
  input   [1:0] op0_mux_sel_Dhl,
  input   [2:0] op1_mux_sel_Dhl,
  input  [31:0] inst_Dhl,
  input   [3:0] alu_fn_Xhl,
  input   [2:0] muldivreq_msg_fn_Dhl,
  input         muldivreq_val,
  output        muldivreq_rdy,
  output        muldivresp_val,
  input         muldivresp_rdy,
  input         muldiv_mux_sel_X3hl,
  input         execute_mux_sel_X3hl,
  input   [2:0] dmemresp_mux_sel_Mhl, // vec? nah this is decoded same from instr for vec and regular?
  input         dmemresp_queue_en_Mhl, // needs own
  input         dmemresp_queue_val_Mhl, // needs own
  input         wb_mux_sel_Mhl,
  input         rf_wen_Whl, // use this
  input  [ 4:0] rf_waddr_Whl,
  input         stall_Fhl,
  input         stall_Dhl,
  input         stall_Xhl,
  input         stall_Mhl,
  input         stall_Whl,
	input   [2:0] rdata0_byp_mux_sel_Dhl,
	input   [2:0] rdata1_byp_mux_sel_Dhl,

	input					stall_X2hl,
	input					stall_X3hl,

  // VECTOR ADDED
  // input   [8:0] v_rf_waddr_Whl, // 5 bits for addr, 4 bits for the vector idx (bc its a 6 bit space but we go on mults of 4)
  input   [4:0] rf_waddr_Dhl,
  input   [1:0] v_lanes_Whl, // idx of last used lane of the 4 lanes - also even needed? for writeout ig
  // input         v_wfrom_intermediate_Whl, // whether or not to write from the intermediate vector register in the case of acc
  // do we do a read from intermediate? or do we just put that in the bypass signal but as an extra lane (probs latter)
  input   [3:0] v_rdata0_byp_mux_sel_Dhl, // NOTE: it's one more bit for the above reason
	input   [3:0] v_rdata1_byp_mux_sel_Dhl, // NOTE: it's one more bit 
  input   [1:0] v_op0_mux_sel_Dhl, //how many bits????????
  input   [1:0] v_op1_mux_sel_Dhl,
  input         v_isstore_Dhl,
  input         v_isvec_Whl, // whether or not it's a vdctor instrcution, needed in wb step only - UPDATE is it even needed? for writeout yea
  // waddr stuff is pipelined all the way throuhg in control for byp logic purposes, rest comes over to dpath asap and then is pipelineed over here
  // meoryyy stuff
  input         v_isvec_Dhl,
  input         v_isvec_X3hl,
  input   [3:0] v_idx_Dhl,
  input   [3:0] v_idx_Whl,
  input v_rinter0_Dhl,
  input v_rinter1_Dhl,
  input v_winter_Whl,

  input         v_dmemresp_queue_en_0_Mhl,
  input         v_dmemresp_queue_val_0_Mhl,
  input         v_dmemresp_queue_en_1_Mhl,
  input         v_dmemresp_queue_val_1_Mhl,
  input         v_dmemresp_queue_en_2_Mhl,
  input         v_dmemresp_queue_val_2_Mhl,
  input         v_dmemresp_queue_en_3_Mhl,
  input         v_dmemresp_queue_val_3_Mhl,

  // Control Signals (dpath->ctrl)

  output        branch_cond_eq_Xhl,
  output        branch_cond_ne_Xhl,
  output        branch_cond_lt_Xhl,
  output        branch_cond_ltu_Xhl,
  output        branch_cond_ge_Xhl,
  output        branch_cond_geu_Xhl,
  output [31:0] proc2csr_data_Whl
  // we could process the csrs (vl) in dp and send across, or just not
);

  //--------------------------------------------------------------------
  // PC Logic Stage
  //--------------------------------------------------------------------

  // PC mux

  wire [31:0] pc_plus4_Phl;
  wire [31:0] branch_targ_Phl;
  wire [31:0] jump_targ_Phl;
  wire [31:0] jumpreg_targ_Phl;
  wire [31:0] pc_mux_out_Phl;

  wire [31:0] reset_vector = 32'h00080000;

  // Pull mux inputs from later stages

  assign pc_plus4_Phl       = pc_plus4_Fhl;
  assign branch_targ_Phl    = branch_targ_Xhl;
  assign jump_targ_Phl      = jump_targ_Dhl;
  assign jumpreg_targ_Phl   = jumpreg_targ_Dhl;

  assign pc_mux_out_Phl
    = ( pc_mux_sel_Phl == 2'd0 ) ? pc_plus4_Phl
    : ( pc_mux_sel_Phl == 2'd1 ) ? branch_targ_Phl
    : ( pc_mux_sel_Phl == 2'd2 ) ? jump_targ_Phl
    : ( pc_mux_sel_Phl == 2'd3 ) ? jumpreg_targ_Phl
    :                              32'bx;

  // Send out imem request early

  assign imemreq_msg_addr
    = ( reset ) ? reset_vector
    :             pc_mux_out_Phl;

  //----------------------------------------------------------------------
  // F <- P
  //----------------------------------------------------------------------

  reg  [31:0] pc_Fhl;

  always @ (posedge clk) begin
    if( reset ) begin
      pc_Fhl <= reset_vector;
    end
    else if( !stall_Fhl ) begin
      pc_Fhl <= pc_mux_out_Phl;
    end
  end

  //--------------------------------------------------------------------
  // Fetch Stage
  //--------------------------------------------------------------------

  // PC incrementer

  wire [31:0] pc_plus4_Fhl;

  assign pc_plus4_Fhl = pc_Fhl + 32'd4;

  //----------------------------------------------------------------------
  // D <- F
  //----------------------------------------------------------------------

  reg [31:0] pc_Dhl;
  reg [31:0] pc_plus4_Dhl;

  always @ (posedge clk) begin
    if( !stall_Dhl ) begin
      pc_Dhl       <= pc_Fhl;
      pc_plus4_Dhl <= pc_plus4_Fhl;
    end
  end

  //--------------------------------------------------------------------
  // Decode Stage (Register Read)
  //--------------------------------------------------------------------

  // Parse instruction fields

  wire   [4:0] inst_rs1_Dhl;
  wire   [4:0] inst_rs2_Dhl;
  wire   [4:0] inst_rd_Dhl;
  wire   [4:0] inst_shamt_Dhl;
  wire  [31:0] imm_i_Dhl;
  wire  [31:0] imm_u_Dhl;
  wire  [31:0] imm_uj_Dhl;
  wire  [31:0] imm_s_Dhl;
  wire  [31:0] imm_sb_Dhl;

  // Branch and jump address generation

  wire [31:0] branch_targ_Dhl;
  wire [31:0] jump_targ_Dhl;

  assign branch_targ_Dhl = pc_Dhl + imm_sb_Dhl;
  assign jump_targ_Dhl   = pc_Dhl + imm_uj_Dhl;

  // Register file

  wire [ 4:0] rf_raddr0_Dhl = inst_rs1_Dhl;
  wire [31:0] rf_rdata0_Dhl;
  wire [ 4:0] rf_raddr1_Dhl 
      = (v_isstore_Dhl && v_isvec_Dhl) rf_waddr_Dhl 
      :                                inst_rs2_Dhl;
      // add control for hanging rs2 to vd in acc insts
  wire [31:0] rf_rdata1_Dhl;

  assign imemreq_msg_addr
    = ( reset ) ? reset_vector
    :             pc_mux_out_Phl;

  // VECTOR register file
  wire [127:0] v_rf_rdata0_Dhl; // todo - where do we get this data from instr to bits??
  wire [127:0] v_rf_rdata1_Dhl; // todo

  // Jump reg address

  wire [31:0] jumpreg_targ_Dhl;

  wire [31:0] jumpreg_targ_pretruncate_Dhl = rdata0_byp_mux_out_Dhl + imm_i_Dhl;
  assign jumpreg_targ_Dhl  = {jumpreg_targ_pretruncate_Dhl[31:1], 1'b0};

  // Shift amount immediate

  wire [31:0] shamt_Dhl = { 27'b0, inst_shamt_Dhl };

  // Constant operand mux inputs

  wire [31:0] const0    = 32'd0;

	// rdata0 bypass
	wire [31:0] rdata0_byp_mux_out_Dhl
		= ( rdata0_byp_mux_sel_Dhl == 3'd0 ) ? rf_rdata0_Dhl
		: ( rdata0_byp_mux_sel_Dhl == 3'd1 ) ? execute_mux_out_Xhl
	  : ( rdata0_byp_mux_sel_Dhl == 3'd2 ) ? wb_mux_out_Mhl
	  : ( rdata0_byp_mux_sel_Dhl == 3'd3 ) ? wb_mux_out_X2hl
		: ( rdata0_byp_mux_sel_Dhl == 3'd4 ) ? execute_mux_out_X3hl
		: ( rdata0_byp_mux_sel_Dhl == 3'd5 ) ? wb_mux_out_Whl
		:																			 32'bx;	

	// rdata1 bypass
	wire [31:0] rdata1_byp_mux_out_Dhl
		= ( rdata1_byp_mux_sel_Dhl == 3'd0 ) ? rf_rdata1_Dhl
		: ( rdata1_byp_mux_sel_Dhl == 3'd1 ) ? execute_mux_out_Xhl
	  : ( rdata1_byp_mux_sel_Dhl == 3'd2 ) ? wb_mux_out_Mhl
	  : ( rdata1_byp_mux_sel_Dhl == 3'd3 ) ? wb_mux_out_X2hl
		: ( rdata1_byp_mux_sel_Dhl == 3'd4 ) ? execute_mux_out_X3hl
		: ( rdata1_byp_mux_sel_Dhl == 3'd5 ) ? wb_mux_out_Whl
		:																			 32'bx;	

	// vector rdata0 bypass
	wire [127:0] v_rdata0_byp_mux_out_Dhl
		= ( rdata0_byp_mux_sel_Dhl == 4'd0 ) ? v_rf_rdata0_Dhl
		: ( rdata0_byp_mux_sel_Dhl == 4'd1 ) ? v_execute_mux_out_Xhl
	  : ( rdata0_byp_mux_sel_Dhl == 4'd2 ) ? v_wb_mux_out_Mhl
	  : ( rdata0_byp_mux_sel_Dhl == 4'd3 ) ? v_wb_mux_out_X2hl
		: ( rdata0_byp_mux_sel_Dhl == 4'd4 ) ? v_execute_mux_out_X3hl
		: ( rdata0_byp_mux_sel_Dhl == 4'd5 ) ? v_wb_mux_out_Whl
    : ( rdata0_byp_mux_sel_Dhl == 4'd6 ) ? v_intermediate_reg
		:																			 128'bx;	

  // vector rdata0 bypass
	wire [127:0] v_rdata1_byp_mux_out_Dhl
		= ( rdata0_byp_mux_sel_Dhl == 4'd0 ) ? v_rf_rdata1_Dhl
		: ( rdata0_byp_mux_sel_Dhl == 4'd1 ) ? v_execute_mux_out_Xhl
	  : ( rdata0_byp_mux_sel_Dhl == 4'd2 ) ? v_wb_mux_out_Mhl
	  : ( rdata0_byp_mux_sel_Dhl == 4'd3 ) ? v_wb_mux_out_X2hl
		: ( rdata0_byp_mux_sel_Dhl == 4'd4 ) ? v_execute_mux_out_X3hl
		: ( rdata0_byp_mux_sel_Dhl == 4'd5 ) ? v_wb_mux_out_Whl
    : ( rdata0_byp_mux_sel_Dhl == 4'd6 ) ? v_intermediate_reg
		:																			 128'bx;	

  // Operand 0 mux

  wire [31:0] op0_mux_out_Dhl
    = ( op0_mux_sel_Dhl == 2'd0 ) ? rdata0_byp_mux_out_Dhl
    : ( op0_mux_sel_Dhl == 2'd1 ) ? pc_Dhl
    : ( op0_mux_sel_Dhl == 2'd2 ) ? pc_plus4_Dhl
    : ( op0_mux_sel_Dhl == 2'd3 ) ? const0
    :                               32'bx;

  // Operand 1 mux

  wire [31:0] op1_mux_out_Dhl
    = ( op1_mux_sel_Dhl == 3'd0 ) ? rdata1_byp_mux_out_Dhl
    : ( op1_mux_sel_Dhl == 3'd1 ) ? shamt_Dhl
    : ( op1_mux_sel_Dhl == 3'd2 ) ? imm_u_Dhl
    : ( op1_mux_sel_Dhl == 3'd3 ) ? imm_sb_Dhl
    : ( op1_mux_sel_Dhl == 3'd4 ) ? imm_i_Dhl
    : ( op1_mux_sel_Dhl == 3'd5 ) ? imm_s_Dhl
    : ( op1_mux_sel_Dhl == 3'd6 ) ? const0
    :                               32'bx;

//VECTOR stuff - which are strided and which just use the thing
    // Operand 0 mux

  wire [127:0] v_op0_mux_out_Dhl
    = ( v_op0_mux_sel_Dhl == 2'd0 ) ? v_rdata0_byp_mux_out_Dhl
    : ( v_op0_mux_sel_Dhl == 2'd1 ) ? {rdata0_byp_mux_out_Dhl, rdata0_byp_mux_out_Dhl, rdata0_byp_mux_out_Dhl, rdata0_byp_mux_out_Dhl}
    : ( v_op0_mux_sel_Dhl == 2'd2 ) ? {const0,const0,const0,const0}
    :                               128'bx;

  // Operand 1 mux

  wire [31:0] v_off0_Dhl = (v_idx_Dhl << 7) * rdata1_byp_mux_out_Dhl // stride
  wire [31:0] v_off1_Dhl = ((v_idx_Dhl<<2 + 32'd1) << 5) * rdata1_byp_mux_out_Dhl // stride
  wire [31:0] v_off2_Dhl = ((v_idx_Dhl<<2 + 32'd2) << 5) * rdata1_byp_mux_out_Dhl // stride
  wire [31:0] v_off3_Dhl = ((v_idx_Dhl<<2 + 32'd3) << 5) * rdata1_byp_mux_out_Dhl // stride

  wire [127:0] v_op1_mux_out_Dhl
    = ( v_op1_mux_sel_Dhl == 2'd0 ) ? v_rdata1_byp_mux_out_Dhl
    : ( v_op1_mux_sel_Dhl == 2'd1 ) ? {v_off3_Dhl,v_off2_Dhl,v_off1_Dhl,v_off0_Dhl}
    : ( v_op1_mux_sel_Dhl == 2'd2 ) ? {const0,const0,const0,const0}
    :                               128'bx;

    
  // VECTOR dont have more muxes cuz we dont need anything other than the bypass mux sel, we're not adding vector immediates
  // WAIT yeah it does but just for addresses for mem - > figure that tf out ahadkfalkdjs 

  // wdata with bypassing

  wire [31:0] wdata_Dhl = rdata1_byp_mux_out_Dhl;

  wire [127:0] v_wdata_Dhl = v_rdata1_byp_mux_out_Dhl;
  // sorry ignore the following, this needs to know which op to take to write to memroy 


  // hmmm not really sure exactly why they set it to the second argument because it's never maintained unless the alu doens't write out
  // if you understand this explain it to me bc i hope it's not wrong (-anna)

  //----------------------------------------------------------------------
  // X <- D
  //----------------------------------------------------------------------

  reg [31:0] pc_Xhl;
  reg [31:0] branch_targ_Xhl;
  reg [31:0] op0_mux_out_Xhl;
  reg [31:0] op1_mux_out_Xhl;
  reg [31:0] wdata_Xhl;
  reg [127:0] v_op0_mux_out_Xhl;
  reg [127:0] v_op1_mux_out_Xhl;
  reg [127:0] v_wdata_Xhl;

  always @ (posedge clk) begin
    if( !stall_Xhl ) begin
      pc_Xhl          <= pc_Dhl;
      branch_targ_Xhl <= branch_targ_Dhl;
      op0_mux_out_Xhl <= op0_mux_out_Dhl;
      op1_mux_out_Xhl <= op1_mux_out_Dhl;
      wdata_Xhl       <= wdata_Dhl;
      // v_op0_mux_out_Xhl <= v_rdata0_byp_mux_out_Dhl;
      // v_op1_mux_out_Xhl <= v_rdata1_byp_mux_out_Dhl;
      v_op0_mux_out_Xhl <= v_op0_mux_out_Dhl;
      v_op1_mux_out_Xhl <= v_op1_mux_out_Dhl;
      v_wdata_Xhl <= v_wdata_Dhl;
    end
  end

  //----------------------------------------------------------------------
  // Execute Stage
  //----------------------------------------------------------------------

  // ALU

  wire [31:0] alu_out_Xhl;

  // vector alu
  wire [127:0] v_alu_out_Xhl;

  // Branch condition logic

  wire   diffSigns_Xhl         = op0_mux_out_Xhl[31] ^ op1_mux_out_Xhl[31];
  assign branch_cond_eq_Xhl    = ( alu_out_Xhl == 32'd0 );
  assign branch_cond_ne_Xhl    = ~branch_cond_eq_Xhl;
  assign branch_cond_lt_Xhl    = diffSigns_Xhl ? op0_mux_out_Xhl[31] : alu_out_Xhl[31];
  assign branch_cond_ltu_Xhl   = diffSigns_Xhl ? op1_mux_out_Xhl[31] : alu_out_Xhl[31];
  assign branch_cond_ge_Xhl    = diffSigns_Xhl ? op1_mux_out_Xhl[31] : ~alu_out_Xhl[31];
  assign branch_cond_geu_Xhl   = diffSigns_Xhl ? op0_mux_out_Xhl[31] : ~alu_out_Xhl[31];

  // Send out memory request during X, response returns in M

  assign dmemreq_msg_addr = alu_out_Xhl;
  assign dmemreq_msg_data = wdata_Xhl; // effectively is this writing to wdata? shouldnt it be the response? or like it's wdata that's being stored
  // VECTOR stuff?? 
  // assign v_dmemreq_msg_addr = skdjldsak stride????
  assign v_dmemreq_msg_addr_0 = v_alu_out_Xhl[31:0];
  assign v_dmemreq_msg_data_0 = v_wdata_Xhl[31:0];
  assign v_dmemreq_msg_addr_1 = v_alu_out_Xhl[63:32];
  assign v_dmemreq_msg_data_1 = v_wdata_Xhl[63:32];
  assign v_dmemreq_msg_addr_2 = v_alu_out_Xhl[95:64];
  assign v_dmemreq_msg_data_2 = v_wdata_Xhl[95:64];
  assign v_dmemreq_msg_addr_3 = v_alu_out_Xhl[127:96];
  assign v_dmemreq_msg_data_3 = v_wdata_Xhl[127:96];

  wire [31:0] execute_mux_out_Xhl = alu_out_Xhl;
  wire [127:0] v_execute_mux_out_Xhl = v_alu_out_Xhl;

 
  //----------------------------------------------------------------------
  // M <- X
  //----------------------------------------------------------------------

  reg  [31:0] pc_Mhl;
  reg  [31:0] execute_mux_out_Mhl;
  reg  [31:0] wdata_Mhl;
  reg  [127:0] v_execute_mux_out_Mhl;
  reg  [127:0] v_wdata_Mhl;

  always @ (posedge clk) begin
    if( !stall_Mhl ) begin
      pc_Mhl              <= pc_Xhl;
      execute_mux_out_Mhl <= execute_mux_out_Xhl;
      wdata_Mhl           <= wdata_Xhl;
      v_execute_mux_out_Mhl <= v_execute_mux_out_Xhl;
      v_wdata_Mhl           <= v_wdata_Xhl;
    end
  end

  //----------------------------------------------------------------------
  // Memory Stage
  //----------------------------------------------------------------------

  // to do: copy the following stuff for vector mem: VECTOR FIX

  // Data memory subword adjustment mux

  wire [31:0] dmemresp_lb_Mhl
    = { {24{dmemresp_msg_data[7]}}, dmemresp_msg_data[7:0] };
  wire [31:0] dmemresp_lbu_Mhl
    = { {24{1'b0}}, dmemresp_msg_data[7:0] };
  wire [31:0] dmemresp_lh_Mhl
    = { {16{dmemresp_msg_data[15]}}, dmemresp_msg_data[15:0] };
  wire [31:0] dmemresp_lhu_Mhl
    = { {16{1'b0}}, dmemresp_msg_data[15:0] };
  wire [31:0] dmemresp_mux_out_Mhl
    = ( dmemresp_mux_sel_Mhl == 3'd0 ) ? dmemresp_msg_data
    : ( dmemresp_mux_sel_Mhl == 3'd1 ) ? dmemresp_lb_Mhl
    : ( dmemresp_mux_sel_Mhl == 3'd2 ) ? dmemresp_lbu_Mhl
    : ( dmemresp_mux_sel_Mhl == 3'd3 ) ? dmemresp_lh_Mhl
    : ( dmemresp_mux_sel_Mhl == 3'd4 ) ? dmemresp_lhu_Mhl
    :                                    32'bx;

  wire [31:0] v_dmemresp_lb_0_Mhl
    = { {24{v_dmemresp_msg_data_0[7]}}, v_dmemresp_msg_data_0[7:0] };
  wire [31:0] v_dmemresp_lbu_0_Mhl
    = { {24{1'b0}}, v_dmemresp_msg_data_0[7:0] };
  wire [31:0] v_dmemresp_lh_0_Mhl
    = { {16{v_dmemresp_msg_data_0[15]}}, v_dmemresp_msg_data_0[15:0] };
  wire [31:0] v_dmemresp_lhu_0_Mhl
    = { {16{1'b0}}, v_dmemresp_msg_data_0[15:0] };
  wire [31:0] v_dmemresp_mux_out_0_Mhl
    = ( v_dmemresp_mux_sel_0_Mhl == 3'd0 ) ? v_dmemresp_msg_data_0
    : ( v_dmemresp_mux_sel_0_Mhl == 3'd1 ) ? v_dmemresp_lb_0_Mhl
    : ( v_dmemresp_mux_sel_0_Mhl == 3'd2 ) ? v_dmemresp_lbu_0_Mhl
    : ( v_dmemresp_mux_sel_0_Mhl == 3'd3 ) ? v_dmemresp_lh_0_Mhl
    : ( v_dmemresp_mux_sel_0_Mhl == 3'd4 ) ? v_dmemresp_lhu_0_Mhl
    :                                    32'bx;

  wire [31:0] v_dmemresp_lb_1_Mhl
    = { {24{v_dmemresp_msg_data_1[7]}}, v_dmemresp_msg_data_1[7:0] };
  wire [31:0] v_dmemresp_lbu_1_Mhl
    = { {24{1'b0}}, v_dmemresp_msg_data_1[7:0] };
  wire [31:0] v_dmemresp_lh_1_Mhl
    = { {16{v_dmemresp_msg_data_1[15]}}, v_dmemresp_msg_data_1[15:0] };
  wire [31:0] v_dmemresp_lhu_1_Mhl
    = { {16{1'b0}}, v_dmemresp_msg_data_1[15:0] };
  wire [31:0] v_dmemresp_mux_out_1_Mhl
    = ( v_dmemresp_mux_sel_1_Mhl == 3'd0 ) ? v_dmemresp_msg_data_1
    : ( v_dmemresp_mux_sel_1_Mhl == 3'd1 ) ? v_dmemresp_lb_1_Mhl
    : ( v_dmemresp_mux_sel_1_Mhl == 3'd2 ) ? v_dmemresp_lbu_1_Mhl
    : ( v_dmemresp_mux_sel_1_Mhl == 3'd3 ) ? v_dmemresp_lh_1_Mhl
    : ( v_dmemresp_mux_sel_1_Mhl == 3'd4 ) ? v_dmemresp_lhu_1_Mhl
    :                                    32'bx;

  wire [31:0] v_dmemresp_lb_2_Mhl
    = { {24{v_dmemresp_msg_data_2[7]}}, v_dmemresp_msg_data_2[7:0] };
  wire [31:0] v_dmemresp_lbu_2_Mhl
    = { {24{1'b0}}, v_dmemresp_msg_data_2[7:0] };
  wire [31:0] v_dmemresp_lh_2_Mhl
    = { {16{v_dmemresp_msg_data_2[15]}}, v_dmemresp_msg_data_2[15:0] };
  wire [31:0] v_dmemresp_lhu_2_Mhl
    = { {16{1'b0}}, v_dmemresp_msg_data_2[15:0] };
  wire [31:0] v_dmemresp_mux_out_2_Mhl
    = ( v_dmemresp_mux_sel_2_Mhl == 3'd0 ) ? v_dmemresp_msg_data_2
    : ( v_dmemresp_mux_sel_2_Mhl == 3'd1 ) ? v_dmemresp_lb_2_Mhl
    : ( v_dmemresp_mux_sel_2_Mhl == 3'd2 ) ? v_dmemresp_lbu_2_Mhl
    : ( v_dmemresp_mux_sel_2_Mhl == 3'd3 ) ? v_dmemresp_lh_2_Mhl
    : ( v_dmemresp_mux_sel_2_Mhl == 3'd4 ) ? v_dmemresp_lhu_2_Mhl
    :                                    32'bx;

  wire [31:0] v_dmemresp_lb_3_Mhl
    = { {24{v_dmemresp_msg_data_3[7]}}, v_dmemresp_msg_data_3[7:0] };
  wire [31:0] v_dmemresp_lbu_3_Mhl
    = { {24{1'b0}}, v_dmemresp_msg_data_3[7:0] };
  wire [31:0] v_dmemresp_lh_3_Mhl
    = { {16{v_dmemresp_msg_data_3[15]}}, v_dmemresp_msg_data_3[15:0] };
  wire [31:0] v_dmemresp_lhu_3_Mhl
    = { {16{1'b0}}, v_dmemresp_msg_data_3[15:0] };
  wire [31:0] v_dmemresp_mux_out_3_Mhl
    = ( v_dmemresp_mux_sel_3_Mhl == 3'd0 ) ? v_dmemresp_msg_data_3
    : ( v_dmemresp_mux_sel_3_Mhl == 3'd1 ) ? v_dmemresp_lb_3_Mhl
    : ( v_dmemresp_mux_sel_3_Mhl == 3'd2 ) ? v_dmemresp_lbu_3_Mhl
    : ( v_dmemresp_mux_sel_3_Mhl == 3'd3 ) ? v_dmemresp_lh_3_Mhl
    : ( v_dmemresp_mux_sel_3_Mhl == 3'd4 ) ? v_dmemresp_lhu_3_Mhl
    :                                    32'bx;


  //----------------------------------------------------------------------
  // Queue for data memory response
  //----------------------------------------------------------------------

  reg [31:0] dmemresp_queue_reg_Mhl;
  reg [31:0] v_dmemresp_queue_reg_0_Mhl;
  reg [31:0] v_dmemresp_queue_reg_2_Mhl;
  reg [31:0] v_dmemresp_queue_reg_1_Mhl;
  reg [31:0] v_dmemresp_queue_reg_3_Mhl;

  always @ ( posedge clk ) begin
    if ( dmemresp_queue_en_Mhl ) begin
      dmemresp_queue_reg_Mhl <= dmemresp_mux_out_Mhl;
    end
  end

  //vec
  reg [31:0] v_dmemresp_queue_reg_0_Mhl;
  always @ ( posedge clk ) begin
    if ( v_dmemresp_queue_en_0_Mhl ) begin
      v_dmemresp_queue_reg_0_Mhl <= v_dmemresp_mux_out_0_Mhl;
    end
  end
  reg [31:0] v_dmemresp_queue_reg_1_Mhl;
  always @ ( posedge clk ) begin
    if ( v_dmemresp_queue_en_1_Mhl ) begin
      v_dmemresp_queue_reg_1_Mhl <= v_dmemresp_mux_out_1_Mhl;
    end
  end
  reg [31:2] v_dmemresp_queue_reg_2_Mhl;
  always @ ( posedge clk ) begin
    if ( v_dmemresp_queue_en_2_Mhl ) begin
      v_dmemresp_queue_reg_2_Mhl <= v_dmemresp_mux_out_2_Mhl;
    end
  end
  reg [31:3] v_dmemresp_queue_reg_3_Mhl;
  always @ ( posedge clk ) begin
    if ( v_dmemresp_queue_en_3_Mhl ) begin
      v_dmemresp_queue_reg_3_Mhl <= v_dmemresp_mux_out_3_Mhl;
    end
  end

  //----------------------------------------------------------------------
  // Data memory queue mux
  //----------------------------------------------------------------------

  wire [31:0] dmemresp_queue_mux_out_Mhl
    = ( !dmemresp_queue_val_Mhl ) ? dmemresp_mux_out_Mhl
    : ( dmemresp_queue_val_Mhl )  ? dmemresp_queue_reg_Mhl
    :                               32'bx;
  //vec 
  wire [31:0] v_dmemresp_queue_mux_out_0_Mhl
    = ( !v_dmemresp_queue_val_0_Mhl ) ? v_dmemresp_mux_out_0_Mhl
    : ( v_dmemresp_queue_val_0_Mhl )  ? v_dmemresp_queue_reg_0_Mhl
    :                               32'bx;
  wire [31:0] v_dmemresp_queue_mux_out_1_Mhl
    = ( !v_dmemresp_queue_val_1_Mhl ) ? v_dmemresp_mux_out_1_Mhl
    : ( v_dmemresp_queue_val_1_Mhl )  ? v_dmemresp_queue_reg_1_Mhl
    :                               32'bx;
  wire [31:0] v_dmemresp_queue_mux_out_2_Mhl
    = ( !v_dmemresp_queue_val_2_Mhl ) ? v_dmemresp_mux_out_2_Mhl
    : ( v_dmemresp_queue_val_2_Mhl )  ? v_dmemresp_queue_reg_2_Mhl
    :                               32'bx;
  wire [31:0] v_dmemresp_queue_mux_out_3_Mhl
    = ( !v_dmemresp_queue_val_3_Mhl ) ? v_dmemresp_mux_out_3_Mhl
    : ( v_dmemresp_queue_val_3_Mhl )  ? v_dmemresp_queue_reg_3_Mhl
    :                               32'bx;

  //----------------------------------------------------------------------
  // Writeback mux
  //----------------------------------------------------------------------

  wire [31:0] wb_mux_out_Mhl
    = ( wb_mux_sel_Mhl == 1'd0 ) ? execute_mux_out_Mhl
    : ( wb_mux_sel_Mhl == 1'd1 ) ? dmemresp_queue_mux_out_Mhl
    :                              32'bx;

  wire [127:0] v_wb_mux_out_Mhl
    = ( wb_mux_sel_Mhl == 1'd0 ) ? v_execute_mux_out_Mhl
    : ( wb_mux_sel_Mhl == 1'd1 ) ? {v_dmemresp_queue_mux_out_3_Mhl,v_dmemresp_queue_mux_out_2_Mhl,v_dmemresp_queue_mux_out_1_Mhl,v_dmemresp_queue_mux_out_0_Mhl}
    :                              128'bx;
  

	//----------------------------------------------------------------------
  // X2 <- M
  //----------------------------------------------------------------------

  reg  [31:0] pc_X2hl;
  reg  [31:0] wb_mux_out_X2hl;
  reg [127:0] v_wb_mux_out_X2hl;

  always @ (posedge clk) begin
    if( !stall_X2hl ) begin
      pc_X2hl                 <= pc_Mhl;
      wb_mux_out_X2hl         <= wb_mux_out_Mhl;
      v_wb_mux_out_X2hl         <= v_wb_mux_out_Mhl;
    end
  end

		
	//----------------------------------------------------------------------
  // X3 <- X2
  //----------------------------------------------------------------------

  reg  [31:0] pc_X3hl;
  reg  [31:0] wb_mux_out_X3hl;
  reg [127:0] v_wb_mux_out_X3hl;

  always @ (posedge clk) begin
    if( !stall_X3hl ) begin
      pc_X3hl                 <= pc_X2hl;
      wb_mux_out_X3hl         <= wb_mux_out_X2hl;
      v_wb_mux_out_X3hl         <= v_wb_mux_out_X2hl;
    end
  end
  

  wire [63:0] muldivresp_msg_result_X3hl;
  //vec
  wire [63:0] v_muldivresp_msg_result_1_X3hl;
  wire [63:0] v_muldivresp_msg_result_0_X3hl;
  wire [63:0] v_muldivresp_msg_result_2_X3hl;
  wire [63:0] v_muldivresp_msg_result_3_X3hl;

  // Muldiv Result Mux
  wire [31:0] muldiv_mux_out_X3hl
    = ( muldiv_mux_sel_X3hl == 1'd0 ) ? muldivresp_msg_result_X3hl[31:0]
    : ( muldiv_mux_sel_X3hl == 1'd1 ) ? muldivresp_msg_result_X3hl[63:32]
    :                                   32'bx;
  // Execute Result Mux
  wire [31:0] execute_mux_out_X3hl
    = ( execute_mux_sel_X3hl == 1'd0 ) ? wb_mux_out_X3hl
    : ( execute_mux_sel_X3hl == 1'd1 ) ? muldiv_mux_out_X3hl
    :                                    32'bx;

//vector
  // Muldiv Result Mux v0
  wire [31:0] v_muldiv_mux_out_0_X3hl
    = ( muldiv_mux_sel_X3hl == 1'd0 ) ? v_muldivresp_msg_result_0_X3hl[31:0]
    : ( muldiv_mux_sel_X3hl == 1'd1 ) ? v_muldivresp_msg_result_0_X3hl[63:32]
    :                                   32'bx;
    // Muldiv Result Mux v1
  wire [31:0] v_muldiv_mux_out_1_X3hl
    = ( muldiv_mux_sel_X3hl == 1'd0 ) ? v_muldivresp_msg_result_1_X3hl[31:0]
    : ( muldiv_mux_sel_X3hl == 1'd1 ) ? v_muldivresp_msg_result_1_X3hl[63:32]
    :                                   32'bx;
    // Muldiv Result Mux v2
  wire [31:0] v_muldiv_mux_out_2_X3hl
    = ( muldiv_mux_sel_X3hl == 1'd0 ) ? v_muldivresp_msg_result_2_X3hl[31:0]
    : ( muldiv_mux_sel_X3hl == 1'd1 ) ? v_muldivresp_msg_result_2_X3hl[63:32]
    :                                   32'bx;
    // Muldiv Result Mux v3
  wire [31:0] v_muldiv_mux_out_3_X3hl
    = ( muldiv_mux_sel_X3hl == 1'd0 ) ? v_muldivresp_msg_result_3_X3hl[31:0]
    : ( muldiv_mux_sel_X3hl == 1'd1 ) ? v_muldivresp_msg_result_3_X3hl[63:32]
    :                                   32'bx;

  // Execute Result Mux vectors
  wire [127:0] v_execute_mux_out_X3hl
    = ( execute_mux_sel_X3hl == 1'd0 ) ? v_wb_mux_out_X3hl
    : ( execute_mux_sel_X3hl == 1'd1 ) ? {v_muldiv_mux_out_3_X3hl,v_muldiv_mux_out_2_X3hl,v_muldiv_mux_out_1_X3hl,v_muldiv_mux_out_0_X3hl}
    :                                    128'bx;


  //----------------------------------------------------------------------
  // W <- X3
  //----------------------------------------------------------------------

  reg  [31:0] pc_Whl;
  reg  [31:0] wb_mux_out_Whl;
  reg  [127:0] v_wb_mux_out_Whl;

  always @ (posedge clk) begin
    if( !stall_Whl ) begin
      pc_Whl                 <= pc_X3hl;
      wb_mux_out_Whl         <= execute_mux_out_X3hl;
      v_wb_mux_out_Whl       <= v_execute_mux_out_X3hl;
    end
  end

  //----------------------------------------------------------------------
  // Writeback Stage
  //----------------------------------------------------------------------

  // CSR write data

  assign proc2csr_data_Whl = wb_mux_out_Whl;

  //----------------------------------------------------------------------
  // Debug registers for instruction disassembly
  //----------------------------------------------------------------------

  reg [31:0] pc_debug;

  always @ ( posedge clk ) begin
    pc_debug <= pc_Whl;
  end
  
  //----------------------------------------------------------------------
  // Submodules
  //----------------------------------------------------------------------
  
  // Address Generation

  riscv_InstMsgFromBits inst_msg_from_bits
  (
    .msg      (inst_Dhl),
    .opcode   (),
    .rs1      (inst_rs1_Dhl),
    .rs2      (inst_rs2_Dhl),
    .rd       (inst_rd_Dhl),
    .funct3   (),
    .funct7   (),
    .shamt    (inst_shamt_Dhl),
    .imm_i    (imm_i_Dhl),
    .imm_s    (imm_s_Dhl),
    .imm_sb   (imm_sb_Dhl),
    .imm_u    (imm_u_Dhl),
    .imm_uj   (imm_uj_Dhl)
  );

  // Register File

  riscv_CoreDpathRegfile rfile
  (
    .clk     (clk),
    .raddr0  (rf_raddr0_Dhl),
    .rdata0  (rf_rdata0_Dhl),
    .raddr1  (rf_raddr1_Dhl),
    .rdata1  (rf_rdata1_Dhl),
    .wen_p   (rf_wen_Whl&&(!v_isvec_Whl)),
    .waddr_p (rf_waddr_Whl),
    .wdata_p (wb_mux_out_Whl)
  );

  // VECTOR Register File

  riscv_CoreDpathVectorRegfile v_rfile
  (
    .clk     (clk),
    .v_raddr0  (rf_raddr0_Dhl),
    .v_ridx0 (v_idx_Dhl),
    .v_rdata0  (v_rf_rdata0_Dhl),
    .v_raddr1  (rf_raddr1_Dhl),
    .v_ridx1 (v_idx_Dhl),
    .v_rdata1  (v_rf_rdata1_Dhl),
    .v_lanes (v_lanes_Whl),
    .v_wen_p   ((rf_wen_Whl&&v_isvec_Whl)),
    .v_waddr_p (rf_waddr_Whl),
    .v_widx_p  ({v_idx_Whl,2'd0}),
    .v_wdata_p (v_wb_mux_out_Whl),
    .v_rinter0 (v_rinter0_Dhl),
    .v_rinter1 (v_rinter1_Dhl),
    .v_winter (v_winter_Whl)
  );

  

  riscv_CoreDpathAlu alu
  (
    .in0  (op0_mux_out_Xhl),
    .in1  (op1_mux_out_Xhl),
    .fn   (alu_fn_Xhl),
    .out  (alu_out_Xhl)
  );

  riscv_CoreDpathAlu v_alu_0
  (
    .in0  (v_op0_mux_out_Xhl[31:0]),
    .in1  (v_op1_mux_out_Xhl[31:0]),
    .fn   (alu_fn_Xhl),
    .out  (v_alu_out_Xhl[31:0])
  );

  riscv_CoreDpathAlu v_alu_1
  (
    .in0  (v_op0_mux_out_Xhl[63:32]),
    .in1  (v_op1_mux_out_Xhl[63:32]),
    .fn   (alu_fn_Xhl),
    .out  (v_alu_out_Xhl[63:32])
  );

  riscv_CoreDpathAlu v_alu_2
  (
    .in0  (v_op0_mux_out_Xhl[95:64]),
    .in1  (v_op1_mux_out_Xhl[95:64]),
    .fn   (alu_fn_Xhl),
    .out  (v_alu_out_Xhl[95:64])
  );

  riscv_CoreDpathAlu v_alu_3
  (
    .in0  (v_op0_mux_out_Xhl[127:96]),
    .in1  (v_op1_mux_out_Xhl[127:96]),
    .fn   (alu_fn_Xhl),
    .out  (v_alu_out_Xhl[127:96])
  );


  // Multiplier/Divider
	
	riscv_CoreDpathPipeMulDiv pmuldiv
	(
	  .clk											(clk									),
    .reset										(reset								),
    
		.muldivreq_msg_fn					(muldivreq_msg_fn_Dhl	),
    .muldivreq_msg_a					(op0_mux_out_Dhl			),
    .muldivreq_msg_b					(op1_mux_out_Dhl			),
    .muldivreq_val						(muldivreq_val && !v_isvec_Dhl		),
    .muldivreq_rdy						(s_muldivreq_rdy				),
                                                   
    .muldivresp_msg_result		(muldivresp_msg_result_X3hl),
    .muldivresp_val						(s_muldivresp_val				),
    .muldivresp_rdy						(muldivresp_rdy	&& !v_isvec_X3hl				),
                                                
		.stall_Xhl								(stall_Xhl						),
    .stall_Mhl								(stall_Mhl						),
    .stall_X2hl								(stall_X2hl						),
    .stall_X3hl               (stall_X3hl           )
	);

  riscv_CoreDpathPipeMulDiv v_pmuldiv_0
	(
	  .clk											(clk									),
    .reset										(reset								),
    
		.muldivreq_msg_fn					(muldivreq_msg_fn_Dhl	),
    .muldivreq_msg_a					(v_op0_mux_out_Xhl[31:0]	),
    .muldivreq_msg_b					(v_op0_mux_out_Xhl[31:0] ),
    .muldivreq_val						(muldivreq_val && v_isvec_Dhl				),
    .muldivreq_rdy						(v_muldivreq_rdy_0			),
                                                   
    .muldivresp_msg_result		(v_muldivresp_msg_result_0_X3hl),
    .muldivresp_val						(v_muldivresp_val_0				),
    .muldivresp_rdy						(muldivresp_rdy	&& v_isvec_X3hl			),
                                                
		.stall_Xhl								(stall_Xhl						),
    .stall_Mhl								(stall_Mhl						),
    .stall_X2hl								(stall_X2hl						),
    .stall_X3hl               (stall_X3hl           )
	);

  riscv_CoreDpathPipeMulDiv v_pmuldiv_1
	(
	  .clk											(clk									),
    .reset										(reset								),
    
		.muldivreq_msg_fn					(muldivreq_msg_fn_Dhl	),
    .muldivreq_msg_a					(v_op0_mux_out_Xhl[63:32]	),
    .muldivreq_msg_b					(v_op0_mux_out_Xhl[63:32] ),
    .muldivreq_val						(muldivreq_val && v_isvec_Dhl				),
    .muldivreq_rdy						(v_muldivreq_rdy_1				),
                                                   
    .muldivresp_msg_result		(v_muldivresp_msg_result_1_X3hl),
    .muldivresp_val						(v_muldivresp_val_1				),
    .muldivresp_rdy						(muldivresp_rdy	&& v_isvec_X3hl			),
                                                
		.stall_Xhl								(stall_Xhl						),
    .stall_Mhl								(stall_Mhl						),
    .stall_X2hl								(stall_X2hl						),
    .stall_X3hl               (stall_X3hl           )
	);

  riscv_CoreDpathPipeMulDiv v_pmuldiv_2
	(
	  .clk											(clk									),
    .reset										(reset								),
    
		.muldivreq_msg_fn					(muldivreq_msg_fn_Dhl	),
    .muldivreq_msg_a					(v_op0_mux_out_Xhl[95:64]	),
    .muldivreq_msg_b					(v_op0_mux_out_Xhl[95:64] ),
    .muldivreq_val						(muldivreq_val && v_isvec_Dhl				),
    .muldivreq_rdy						(v_muldivreq_rdy_2				),
                                                   
    .muldivresp_msg_result		(v_muldivresp_msg_result_2_X3hl),
    .muldivresp_val						(v_muldivresp_val_2				),
    .muldivresp_rdy						(muldivresp_rdy	&& v_isvec_X3hl			),
                                                
		.stall_Xhl								(stall_Xhl						),
    .stall_Mhl								(stall_Mhl						),
    .stall_X2hl								(stall_X2hl						),
    .stall_X3hl               (stall_X3hl           )
	);

  riscv_CoreDpathPipeMulDiv v_pmuldiv_3
	(
	  .clk											(clk									),
    .reset										(reset								),
    
		.muldivreq_msg_fn					(muldivreq_msg_fn_Dhl	),
    .muldivreq_msg_a					(v_op0_mux_out_Xhl[127:96]	),
    .muldivreq_msg_b					(v_op0_mux_out_Xhl[127:96] ),
    .muldivreq_val						(muldivreq_val && v_isvec_Dhl				),
    .muldivreq_rdy						(v_muldivreq_rdy_3				),
                                                   
    .muldivresp_msg_result		(v_muldivresp_msg_result_3_X3hl),
    .muldivresp_val						(v_muldivresp_val_3				),
    .muldivresp_rdy						(muldivresp_rdy	&& v_isvec_X3hl			),
                                                
		.stall_Xhl								(stall_Xhl						),
    .stall_Mhl								(stall_Mhl						),
    .stall_X2hl								(stall_X2hl						),
    .stall_X3hl               (stall_X3hl           )
	);

  assign muldivresp_val 
      = (!v_isvec_X3hl) ? s_muldivresp_val 
      :                 (v_muldivresp_val_0 && v_muldivresp_val_1 && v_muldivresp_val_2 && v_muldivresp_val_3);
  
  assign muldivreq_rdy
      = (!v_isvec_Dhl) ? s_muldivreq_rdy 
      :                 (v_muldivresq_rdy_0 && v_muldivreq_rdy_1 && v_muldivreq_rdy_2 && v_muldivreq_rdy_3);


endmodule

`endif

// vim: set textwidth=0 ts=2 sw=2 sts=2 :
