//=========================================================================
// 7-Stage RISCV Core
//=========================================================================

`ifndef RISCV_CORE_V
`define RISCV_CORE_V

`include "vc-MemReqMsg.v"
`include "vc-MemRespMsg.v"
`include "riscvlong-CoreCtrl.v"
`include "riscvlong-CoreDpath.v"

module riscv_Core
(
  input         clk,
  input         reset,

  // Instruction Memory Request Port

  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] imemreq_msg,
  output                                 imemreq_val,
  input                                  imemreq_rdy,

  // Instruction Memory Response Port

  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] imemresp_msg,
  input                               imemresp_val,

  // Data Memory Request Port

  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq_msg,
  output                                 dmemreq_val,
  input                                  dmemreq_rdy,

  // Data Memory Response Port

  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp_msg,
  input                               dmemresp_val,

  // Data Memory Request Port vector 
  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] v_dmemreq_msg_0,
  output                                 v_dmemreq_val_0,
  input                                  v_dmemreq_rdy_0,
  // Data Memory Response Port vector
  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] v_dmemresp_msg_0,
  input                               v_dmemresp_val_0,
  // Data Memory Request Port vector 
  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] v_dmemreq_msg_1,
  output                                 v_dmemreq_val_1,
  input                                  v_dmemreq_rdy_1,
  // Data Memory Response Port vector
  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] v_dmemresp_msg_1,
  input                               v_dmemresp_val_1,
    // Data Memory Request Port vector 
  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] v_dmemreq_msg_2,
  output                                 v_dmemreq_val_2,
  input                                  v_dmemreq_rdy_2,
  // Data Memory Response Port vector
  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] v_dmemresp_msg_2,
  input                               v_dmemresp_val_2,
    // Data Memory Request Port vector 
  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] v_dmemreq_msg_3,
  output                                 v_dmemreq_val_3,
  input                                  v_dmemreq_rdy_3,
  // Data Memory Response Port vector
  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] v_dmemresp_msg_3,
  input                               v_dmemresp_val_3,

  // CSR Status Register Output to Host

  output [31:0] csr_status
);

  wire [31:0] imemreq_msg_addr;
  wire [31:0] imemresp_msg_data;

  wire        dmemreq_msg_rw;
  wire  [1:0] dmemreq_msg_len;
  wire [31:0] dmemreq_msg_addr;
  wire [31:0] dmemreq_msg_data;
  wire [31:0] dmemresp_msg_data;
  // vec
  wire        v_dmemreq_msg_rw_0;
  wire  [1:0] v_dmemreq_msg_len_0;
  wire [31:0] v_dmemreq_msg_addr_0;
  wire [31:0] v_dmemreq_msg_data_0;
  wire [31:0] v_dmemresp_msg_data_0;
  wire        v_dmemreq_msg_rw_1;
  wire  [1:1] v_dmemreq_msg_len_1;
  wire [31:1] v_dmemreq_msg_addr_1;
  wire [31:1] v_dmemreq_msg_data_1;
  wire [31:1] v_dmemresp_msg_data_1;
  wire        v_dmemreq_msg_rw_2;
  wire  [1:2] v_dmemreq_msg_len_2;
  wire [31:2] v_dmemreq_msg_addr_2;
  wire [31:2] v_dmemreq_msg_data_2;
  wire [31:2] v_dmemresp_msg_data_2;
  wire        v_dmemreq_msg_rw_3;
  wire  [1:3] v_dmemreq_msg_len_3;
  wire [31:3] v_dmemreq_msg_addr_3; 
  wire [31:3] v_dmemreq_msg_data_3;
  wire [31:3] v_dmemresp_msg_data_3;
  wire        v_muldivreq_rdy_0;
  wire        v_muldivreq_rdy_1;
  wire        v_muldivreq_rdy_2;
  wire        v_muldivreq_rdy_3;


  wire  [1:0] pc_mux_sel_Phl;
  wire  [1:0] op0_mux_sel_Dhl;
  wire  [2:0] op1_mux_sel_Dhl;
  wire [31:0] inst_Dhl;
  wire  [3:0] alu_fn_Xhl;
  wire  [2:0] muldivreq_msg_fn_Dhl;
  wire        muldivreq_val;
  wire        muldivreq_rdy;
  wire        muldivresp_val;
  wire        muldivresp_rdy;
  wire        muldiv_mux_sel_X3hl;
  wire        execute_mux_sel_X3hl;
  wire  [2:0] dmemresp_mux_sel_Mhl;
  wire        dmemresp_queue_en_Mhl;
  wire        dmemresp_queue_val_Mhl;
  wire        wb_mux_sel_Mhl;
  wire        rf_wen_Whl;
  wire  [4:0] rf_waddr_Whl;
  wire        stall_Fhl;
  wire        stall_Dhl;
  wire        stall_Xhl;
  wire        stall_Mhl;
  wire        stall_Whl;

	wire				stall_X2hl;
	wire				stall_X3hl;
	wire  [2:0] rdata0_byp_mux_sel_Dhl;
	wire  [2:0] rdata1_byp_mux_sel_Dhl;

  wire        branch_cond_eq_Xhl;
  wire        branch_cond_ne_Xhl;
  wire        branch_cond_lt_Xhl;
  wire        branch_cond_ltu_Xhl;
  wire        branch_cond_ge_Xhl;
  wire        branch_cond_geu_Xhl;
  wire [31:0] proc2csr_data_Whl;

    // VECTOR ADDED
  // input   [8:0] v_rf_waddr_Whl, // 5 bits for addr, 4 bits for the vector idx (bc its a 6 bit space but we go on mults of 4)
  wire   [4:0] rf_waddr_Dhl;
  wire   [1:0] v_lanes_Whl;// idx of last used lane of the 4 lanes - also even needed? for writeout ig
  // input         v_wfrom_intermediate_Whl, // whether or not to write from the intermediate vector register in the case of acc
  // do we do a read from intermediate? or do we just put that in the bypass signal but as an extra lane (probs latter)
  wire   [3:0] v_rdata0_byp_mux_sel_Dhl; // NOTE: it's one more bit for the above reason
	wire   [3:0] v_rdata1_byp_mux_sel_Dhl; // NOTE: it's one more bit 
  // output   [1:0] v_op0_mux_sel_Dhl, //how many bits????????
  // output   [1:0] v_op1_mux_sel_Dhl,
  wire         v_isstore_Dhl;
  wire         v_isvec_Whl; // whether or not it's a vdctor instrcution, needed in wb step only - UPDATE is it even needed? for writeout yea
  // waddr stuff is pipelined all the way throuhg in control for byp logic purposes, rest comes over to dpath asap and then is pipelineed over here
  // meoryyy stuff
  wire         v_isvec_Dhl;
  wire         v_isvec_X3hl;
  wire   [3:0] v_idx_Dhl;
  wire   [3:0] v_idx_Whl;
  // output         v_rinter0_Dhl,
  // output         v_rinter1_Dhl,
  // output         v_winter_Whl,

  wire         v_vlr_mux_sel;

  wire         v_dmemresp_queue_en_0_Mhl;
  wire         v_dmemresp_queue_val_0_Mhl;
  wire         v_dmemresp_queue_en_1_Mhl;
  wire         v_dmemresp_queue_val_1_Mhl;
  wire         v_dmemresp_queue_en_2_Mhl;
  wire         v_dmemresp_queue_val_2_Mhl;
  wire         v_dmemresp_queue_en_3_Mhl;
  wire         v_dmemresp_queue_val_3_Mhl;

  // wire          v_muldivreq_rdy_0;
  // wire          v_muldivreq_rdy_1;
  // wire          v_muldivreq_rdy_2;
  // wire          v_muldivreq_rdy_3;
  wire  [5:0] VLR_temp_Xhl;

  //----------------------------------------------------------------------
  // Pack Memory Request Messages
  //----------------------------------------------------------------------

  vc_MemReqMsgToBits#(32,32) imemreq_msg_to_bits
  (
    .type (`VC_MEM_REQ_MSG_TYPE_READ),
    .addr (imemreq_msg_addr),
    .len  (2'd0),
    .data (32'bx),
    .bits (imemreq_msg)
  );

  vc_MemReqMsgToBits#(32,32) dmemreq_msg_to_bits
  (
    .type (dmemreq_msg_rw),
    .addr (dmemreq_msg_addr),
    .len  (dmemreq_msg_len),
    .data (dmemreq_msg_data),
    .bits (dmemreq_msg)
  );
  //vec
  vc_MemReqMsgToBits#(32,32) v_dmemreq_msg_to_bits_0
  (
    .type (v_dmemreq_msg_rw_0),
    .addr (v_dmemreq_msg_addr_0),
    .len  (v_dmemreq_msg_len_0),
    .data (v_dmemreq_msg_data_0),
    .bits (v_dmemreq_msg_0)
  );
  vc_MemReqMsgToBits#(32,32) v_dmemreq_msg_to_bits_1
  (
    .type (v_dmemreq_msg_rw_1),
    .addr (v_dmemreq_msg_addr_1),
    .len  (v_dmemreq_msg_len_1),
    .data (v_dmemreq_msg_data_1),
    .bits (v_dmemreq_msg_1)
  );
  vc_MemReqMsgToBits#(32,32) v_dmemreq_msg_to_bits_2
  (
    .type (v_dmemreq_msg_rw_2),
    .addr (v_dmemreq_msg_addr_2),
    .len  (v_dmemreq_msg_len_2),
    .data (v_dmemreq_msg_data_2),
    .bits (v_dmemreq_msg_2)
  );
  vc_MemReqMsgToBits#(32,32) v_dmemreq_msg_to_bits_3
  (
    .type (v_dmemreq_msg_rw_3),
    .addr (v_dmemreq_msg_addr_3),
    .len  (v_dmemreq_msg_len_3),
    .data (v_dmemreq_msg_data_3),
    .bits (v_dmemreq_msg_3)
  );
  

  //----------------------------------------------------------------------
  // Unpack Memory Response Messages
  //----------------------------------------------------------------------

  vc_MemRespMsgFromBits#(32) imemresp_msg_from_bits
  (
    .bits (imemresp_msg),
    .type (),
    .len  (),
    .data (imemresp_msg_data)
  );

  vc_MemRespMsgFromBits#(32) dmemresp_msg_from_bits
  (
    .bits (dmemresp_msg),
    .type (),
    .len  (),
    .data (dmemresp_msg_data)
  );
  //vec
  vc_MemRespMsgFromBits#(32) v_dmemresp_msg_from_bits_0
  (
    .bits (v_dmemresp_msg_0),
    .type (),
    .len  (),
    .data (v_dmemresp_msg_data_0)
  );
  vc_MemRespMsgFromBits#(32) v_dmemresp_msg_from_bits_1
  (
    .bits (v_dmemresp_msg_1),
    .type (),
    .len  (),
    .data (v_dmemresp_msg_data_1)
  );
  vc_MemRespMsgFromBits#(32) v_dmemresp_msg_from_bits_2
  (
    .bits (v_dmemresp_msg_2),
    .type (),
    .len  (),
    .data (v_dmemresp_msg_data_2)
  );
  vc_MemRespMsgFromBits#(32) v_dmemresp_msg_from_bits_3
  (
    .bits (v_dmemresp_msg_3),
    .type (),
    .len  (),
    .data (v_dmemresp_msg_data_3)
  );

  //----------------------------------------------------------------------
  // Control Unit
  //----------------------------------------------------------------------

  riscv_CoreCtrl ctrl
  (
    .clk                    (clk),
    .reset                  (reset),

    // Instruction Memory Port

    .imemreq_val            (imemreq_val),
    .imemreq_rdy            (imemreq_rdy),
    .imemresp_msg_data      (imemresp_msg_data),
    .imemresp_val           (imemresp_val),

    // Data Memory Port

    .dmemreq_msg_rw         (dmemreq_msg_rw),
    .dmemreq_msg_len        (dmemreq_msg_len),
    .dmemreq_val            (dmemreq_val),
    .dmemreq_rdy            (dmemreq_rdy),
    .dmemresp_val           (dmemresp_val),
    //vec
    .v_dmemreq_msg_rw_0         (v_dmemreq_msg_rw_0),
    .v_dmemreq_msg_len_0        (v_dmemreq_msg_len_0),
    .v_dmemreq_val_0            (v_dmemreq_val_0),
    .v_dmemreq_rdy_0            (v_dmemreq_rdy_0),
    .v_dmemresp_val_0           (v_dmemresp_val_0),
    .v_dmemreq_msg_rw_1         (v_dmemreq_msg_rw_1),
    .v_dmemreq_msg_len_1        (v_dmemreq_msg_len_1),
    .v_dmemreq_val_1            (v_dmemreq_val_1),
    .v_dmemreq_rdy_1            (v_dmemreq_rdy_1),
    .v_dmemresp_val_1           (v_dmemresp_val_1),
    .v_dmemreq_msg_rw_2         (v_dmemreq_msg_rw_2),
    .v_dmemreq_msg_len_2        (v_dmemreq_msg_len_2),
    .v_dmemreq_val_2            (v_dmemreq_val_2),
    .v_dmemreq_rdy_2            (v_dmemreq_rdy_2),
    .v_dmemresp_val_2           (v_dmemresp_val_2),
    .v_dmemreq_msg_rw_3         (v_dmemreq_msg_rw_3),
    .v_dmemreq_msg_len_3        (v_dmemreq_msg_len_3),
    .v_dmemreq_val_3            (v_dmemreq_val_3),
    .v_dmemreq_rdy_3            (v_dmemreq_rdy_3),
    .v_dmemresp_val_3           (v_dmemresp_val_3),
    .v_muldivreq_rdy_0          (v_muldivreq_rdy_0),
    .v_muldivreq_rdy_1          (v_muldivreq_rdy_1),
    .v_muldivreq_rdy_2          (v_muldivreq_rdy_2),
    .v_muldivreq_rdy_3          (v_muldivreq_rdy_3),

    // Controls Signals (ctrl->dpath)

    .pc_mux_sel_Phl         (pc_mux_sel_Phl),
    .op0_mux_sel_Dhl        (op0_mux_sel_Dhl),
    .op1_mux_sel_Dhl        (op1_mux_sel_Dhl),
    .inst_Dhl               (inst_Dhl),
    .alu_fn_Xhl             (alu_fn_Xhl),
    .muldivreq_msg_fn_Dhl   (muldivreq_msg_fn_Dhl),
    .muldivreq_val          (muldivreq_val),
    .muldivreq_rdy          (muldivreq_rdy),
    .muldivresp_val         (muldivresp_val),
    .muldivresp_rdy         (muldivresp_rdy),
    .muldiv_mux_sel_X3hl     (muldiv_mux_sel_X3hl),
    .execute_mux_sel_X3hl    (execute_mux_sel_X3hl),
    .dmemresp_mux_sel_Mhl   (dmemresp_mux_sel_Mhl),
    .dmemresp_queue_en_Mhl  (dmemresp_queue_en_Mhl),
    .dmemresp_queue_val_Mhl (dmemresp_queue_val_Mhl),
    .wb_mux_sel_Mhl         (wb_mux_sel_Mhl),
    .rf_wen_out_Whl         (rf_wen_Whl),
    .rf_waddr_Whl           (rf_waddr_Whl),
    .stall_Fhl              (stall_Fhl),
    .stall_Dhl              (stall_Dhl),
    .stall_Xhl              (stall_Xhl),
    .stall_Mhl              (stall_Mhl),
    .stall_Whl              (stall_Whl),

		.stall_X2hl							(stall_X2hl),
		.stall_X3hl             (stall_X3hl),
		.rdata0_byp_mux_sel_Dhl (rdata0_byp_mux_sel_Dhl),
		.rdata1_byp_mux_sel_Dhl (rdata1_byp_mux_sel_Dhl),

      // VECTOR ADDED
  // input   [8:0] v_rf_waddr_Whl, // 5 bits for addr, 4 bits for the vector idx (bc its a 6 bit space but we go on mults of 4)
    .rf_waddr_Dhl           (rf_waddr_Dhl ),
    .v_lanes_Whl            (v_lanes_Whl),
     // idx of last used lane of the 4 lanes - also even needed? for writeout ig
  // input         v_wfrom_intermediate_Whl, // whether or not to write from the intermediate vector register in the case of acc
  // do we do a read from intermediate? or do we just put that in the bypass signal but as an extra lane (probs latter)
    .v_rdata0_byp_mux_sel_Dhl (v_rdata0_byp_mux_sel_Dhl), // NOTE: it's one more bit for the above reason
	  .v_rdata1_byp_mux_sel_Dhl (v_rdata1_byp_mux_sel_Dhl), // NOTE: it's one more bit 
  // output   [1:0] v_op0_mux_sel_Dhl, //how many bits????????
  // output   [1:0] v_op1_mux_sel_Dhl,
    .v_isstore_Dhl          (v_isstore_Dhl),
    .v_isvec_Whl            (v_isvec_Whl), // whether or not it's a vdctor instrcution, needed in wb step only - UPDATE is it even needed? for writeout yea
  // waddr stuff is pipelined all the way throuhg in control for byp logic purposes, rest comes over to dpath asap and then is pipelineed over here
  // meoryyy stuff
  .v_isvec_Dhl              (v_isvec_Dhl),
  .v_isvec_X3hl             (v_isvec_X3hl),
  .v_idx_Dhl                (v_idx_Dhl),
  .v_idx_Whl                (v_idx_Whl),
  // output         v_rinter0_Dhl,
  // output         v_rinter1_Dhl,
  // output         v_winter_Whl,

  .v_vlr_mux_sel (v_vlr_mux_sel),

  .v_dmemresp_queue_en_0_Mhl (v_dmemresp_queue_en_0_Mhl),
  .v_dmemresp_queue_val_0_Mhl (v_dmemresp_queue_val_0_Mhl),
  .v_dmemresp_queue_en_1_Mhl (v_dmemresp_queue_en_1_Mhl),
  .v_dmemresp_queue_val_1_Mhl (v_dmemresp_queue_val_1_Mhl),
  .v_dmemresp_queue_en_2_Mhl (v_dmemresp_queue_en_2_Mhl),
  .v_dmemresp_queue_val_2_Mhl (v_dmemresp_queue_val_2_Mhl),
  .v_dmemresp_queue_en_3_Mhl (v_dmemresp_queue_en_3_Mhl),
  .v_dmemresp_queue_val_3_Mhl (v_dmemresp_queue_val_3_Mhl),



    // Control Signals (dpath->ctrl)
    .VLR_temp_Xhl (VLR_temp_Xhl),

    .branch_cond_eq_Xhl	    (branch_cond_eq_Xhl),
    .branch_cond_ne_Xhl	    (branch_cond_ne_Xhl),
    .branch_cond_lt_Xhl	    (branch_cond_lt_Xhl),
    .branch_cond_ltu_Xhl	  (branch_cond_ltu_Xhl),
    .branch_cond_ge_Xhl	    (branch_cond_ge_Xhl),
    .branch_cond_geu_Xhl	  (branch_cond_geu_Xhl),
    .proc2csr_data_Whl      (proc2csr_data_Whl),

    // CSR Status

    .csr_status             (csr_status)
  );

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  riscv_CoreDpath dpath
  (
    .clk                     (clk),
    .reset                   (reset),

    // Instruction Memory Port

    .imemreq_msg_addr        (imemreq_msg_addr),

    // Data Memory Port

    .dmemreq_msg_addr        (dmemreq_msg_addr),
    .dmemreq_msg_data        (dmemreq_msg_data),
    .dmemresp_msg_data       (dmemresp_msg_data),
    //vec
    .v_dmemreq_msg_addr_0        (v_dmemreq_msg_addr_0),
    .v_dmemreq_msg_data_0        (v_dmemreq_msg_data_0),
    .v_dmemresp_msg_data_0       (v_dmemresp_msg_data_0),
    .v_dmemreq_msg_addr_1        (v_dmemreq_msg_addr_1),
    .v_dmemreq_msg_data_1        (v_dmemreq_msg_data_1),
    .v_dmemresp_msg_data_1       (v_dmemresp_msg_data_1),
    .v_dmemreq_msg_addr_2        (v_dmemreq_msg_addr_2),
    .v_dmemreq_msg_data_2        (v_dmemreq_msg_data_2),
    .v_dmemresp_msg_data_2       (v_dmemresp_msg_data_2),
    .v_dmemreq_msg_addr_3        (v_dmemreq_msg_addr_3),
    .v_dmemreq_msg_data_3        (v_dmemreq_msg_data_3),
    .v_dmemresp_msg_data_3       (v_dmemresp_msg_data_3),
    .v_muldivreq_rdy_0           (v_muldivreq_rdy_0),
    .v_muldivreq_rdy_1           (v_muldivreq_rdy_1),
    .v_muldivreq_rdy_2           (v_muldivreq_rdy_2),
    .v_muldivreq_rdy_3           (v_muldivreq_rdy_3),


    // Controls Signals (ctrl->dpath)

    .pc_mux_sel_Phl          (pc_mux_sel_Phl),
    .op0_mux_sel_Dhl         (op0_mux_sel_Dhl),
    .op1_mux_sel_Dhl         (op1_mux_sel_Dhl),
    .inst_Dhl                (inst_Dhl),
    .alu_fn_Xhl              (alu_fn_Xhl),
    .muldivreq_msg_fn_Dhl    (muldivreq_msg_fn_Dhl),
    .muldivreq_val           (muldivreq_val),
    .muldivreq_rdy           (muldivreq_rdy),
    .muldivresp_val          (muldivresp_val),
    .muldivresp_rdy          (muldivresp_rdy),
    .muldiv_mux_sel_X3hl      (muldiv_mux_sel_X3hl),
    .execute_mux_sel_X3hl     (execute_mux_sel_X3hl),
    .dmemresp_mux_sel_Mhl    (dmemresp_mux_sel_Mhl),
    .dmemresp_queue_en_Mhl   (dmemresp_queue_en_Mhl),
    .dmemresp_queue_val_Mhl  (dmemresp_queue_val_Mhl),
    .wb_mux_sel_Mhl          (wb_mux_sel_Mhl),
    .rf_wen_Whl              (rf_wen_Whl),
    .rf_waddr_Whl            (rf_waddr_Whl),
    .stall_Fhl               (stall_Fhl),
    .stall_Dhl               (stall_Dhl),
    .stall_Xhl               (stall_Xhl),
    .stall_Mhl               (stall_Mhl),
    .stall_Whl               (stall_Whl),

		.stall_X2hl						 	(stall_X2hl),
		.stall_X3hl             (stall_X3hl),
		.rdata0_byp_mux_sel_Dhl (rdata0_byp_mux_sel_Dhl),
		.rdata1_byp_mux_sel_Dhl (rdata1_byp_mux_sel_Dhl),

          // VECTOR ADDED
  // input   [8:0] v_rf_waddr_Whl, // 5 bits for addr, 4 bits for the vector idx (bc its a 6 bit space but we go on mults of 4)
    .rf_waddr_Dhl           (rf_waddr_Dhl ),
    .v_lanes_Whl (v_lanes_Whl),
     // idx of last used lane of the 4 lanes - also even needed? for writeout ig
  // input         v_wfrom_intermediate_Whl, // whether or not to write from the intermediate vector register in the case of acc
  // do we do a read from intermediate? or do we just put that in the bypass signal but as an extra lane (probs latter)
    .v_rdata0_byp_mux_sel_Dhl (v_rdata0_byp_mux_sel_Dhl), // NOTE: it's one more bit for the above reason
	  .v_rdata1_byp_mux_sel_Dhl (v_rdata1_byp_mux_sel_Dhl), // NOTE: it's one more bit 
  // output   [1:0] v_op0_mux_sel_Dhl, //how many bits????????
  // output   [1:0] v_op1_mux_sel_Dhl,
    .v_isstore_Dhl (v_isstore_Dhl),
    .v_isvec_Whl (v_isvec_Whl), // whether or not it's a vdctor instrcution, needed in wb step only - UPDATE is it even needed? for writeout yea
  // waddr stuff is pipelined all the way throuhg in control for byp logic purposes, rest comes over to dpath asap and then is pipelineed over here
  // meoryyy stuff
  .v_isvec_Dhl (v_isvec_Dhl),
  .v_isvec_X3hl (v_isvec_X3hl),
  .v_idx_Dhl (v_idx_Dhl),
  .v_idx_Whl (v_idx_Whl),
  // output         v_rinter0_Dhl,
  // output         v_rinter1_Dhl,
  // output         v_winter_Whl,

  .v_vlr_mux_sel (v_vlr_mux_sel),

  .v_dmemresp_queue_en_0_Mhl (v_dmemresp_queue_en_0_Mhl),
  .v_dmemresp_queue_val_0_Mhl (v_dmemresp_queue_val_0_Mhl),
  .v_dmemresp_queue_en_1_Mhl (v_dmemresp_queue_en_1_Mhl),
  .v_dmemresp_queue_val_1_Mhl (v_dmemresp_queue_val_1_Mhl),
  .v_dmemresp_queue_en_2_Mhl (v_dmemresp_queue_en_2_Mhl),
  .v_dmemresp_queue_val_2_Mhl (v_dmemresp_queue_val_2_Mhl),
  .v_dmemresp_queue_en_3_Mhl (v_dmemresp_queue_en_3_Mhl),
  .v_dmemresp_queue_val_3_Mhl (v_dmemresp_queue_val_3_Mhl),



    // Control Signals (dpath->ctrl)
    .VLR_temp_Xhl (VLR_temp_Xhl),


    // Control Signals (dpath->ctrl)

    .branch_cond_eq_Xhl	     (branch_cond_eq_Xhl),
    .branch_cond_ne_Xhl	     (branch_cond_ne_Xhl),
    .branch_cond_lt_Xhl	     (branch_cond_lt_Xhl),
    .branch_cond_ltu_Xhl	 (branch_cond_ltu_Xhl),
    .branch_cond_ge_Xhl	     (branch_cond_ge_Xhl),
    .branch_cond_geu_Xhl	 (branch_cond_geu_Xhl),
    .proc2csr_data_Whl       (proc2csr_data_Whl)
  );

endmodule

`endif

// vim: set textwidth=0 ts=2 sw=2 sts=2 :
