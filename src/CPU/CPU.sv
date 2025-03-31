module CPU(
	input clk, 
	input rst,
	input [1:0] busStall,
	input interrupt_dma,
	input [31:0] instr,
	output IM_WEB,
	output [31:0] pc,
	output IM_CEB,

	input [31:0] DM_OUT,
	output DM_WEB,
	output [3:0]  DM_BWEB,
	output [31:0] DM_A,
	output [31:0] DM_IN, 
	output DM_CEB
	);


/* --------------- Top signal  --------------- */ 
logic [31:0] alu_out_wire;  // For DM quickly access(DM_addr)
logic [31:0] src1_st1, src2_st1;
assign DM_A = alu_out_wire;
assign DM_IN = src2_st1;


/* --------------- PC related signal  --------------- */ 
logic [31:0] pc_reg;


/* --------------- IF/ID signal  --------------- */ 
logic [31:0] pc_ID;
logic [31:0] instr_ID;


/* --------------- Decoder signal  --------------- */ 
logic [6:0] opcode_ID;
logic [2:0] funct3_ID;
logic [6:0] funct7_ID;
logic [5:0] rs1_addr_ID;
logic [5:0] rs2_addr_ID;
logic [5:0] rd_addr_ID;
logic [31:0] imm_ID;
logic isWFI;


/* --------------- CSR signal  --------------- */ 
logic isCSR;
logic [31:0] CSR_out;
logic interrupt, interrupt_re;
logic [31:0] mtvec;
logic [31:0] mepc;
logic interrupt_timer;
 

/* --------------- Controller signal  --------------- */ 
logic reg1_sel, reg2_sel;
logic [1:0] mux1_sel, mux2_sel;
logic mux3_sel, mux4_sel;
logic [3:0] alu_ctrl;
logic [1:0] mul_ctrl;
logic [1:0] alu_mul_sel;
logic [2:0] is_load_EX; 
logic [1:0] is_store_EX;
logic [2:0] is_branch_EX;
logic load_use;
logic [1:0] pc_sel;
logic [1:0] instr_sel;
logic wb_en_EX;
logic fwb_en_EX;
logic floatAddSub;


/* --------------- Register signal  --------------- */ 
logic [31:0] rs1_data, rs2_data;
logic [31:0] frs1_data, frs2_data;


/* --------------- ID/EX signal  --------------- */ 
logic [31:0] pc_EX;
logic [5:0] rd_addr_EX;
logic [31:0] rs1_data_reg, rs2_data_reg;
logic [31:0] imm_EX;


/* --------------- EX/MEM signal  --------------- */ 
logic [31:0] alu_out_MEM;
logic taken;
logic [5:0] rd_addr_MEM;
logic wb_en_MEM;
logic fwb_en_MEM;
logic [2:0] is_load_MEM;


/* --------------- MEM/WB signal  --------------- */ 
logic wb_en_WB;
logic fwb_en_WB;
logic [5:0] rd_addr_WB;
logic [31:0] alu_out_WB;


PC u_PC(
	.clk(clk),
    .rst(rst),
    .busStall(busStall),
    .isWFI(isWFI),
    .interrupt(interrupt),
    .interrupt_re(interrupt_re),
    .mtvec(mtvec),
    .mepc(mepc),
    .pc_sel(pc_sel),
    .alu_out(alu_out_wire),
    .IM_CEB(IM_CEB),
    .IM_WEB(IM_WEB),
    .pc(pc),
    .pc_reg(pc_reg)
    );


IF_ID u_IF_ID(
	.clk(clk),
	.rst(rst),
	.busStall(busStall),
	.pc(pc_reg),
	.instr(instr),
	.instr_sel(instr_sel),
	.loadUse(load_use),
	.isWFI(isWFI),
	.pc_ID(pc_ID),
	.instr_ID(instr_ID)
	);


Decoder u_decode(
	.clk(clk), 
	.rst(rst),
	.instr(instr_ID),
	.interrupt(interrupt),
	.opcode_ID(opcode_ID),
	.funct3_ID(funct3_ID),
	.funct7_ID(funct7_ID),
	.rs1_addr_ID(rs1_addr_ID),
	.rs2_addr_ID(rs2_addr_ID),
	.rd_addr_ID(rd_addr_ID),
	.imm_ID(imm_ID),
	.isWFI(isWFI),
	.interrupt_re(interrupt_re)
	);


CSR u_CSR(
	.clk(clk),
	.rst(rst),
	.busStall(busStall),
	.pc_sel(pc_sel),
	.instr(instr),
	.rs1_data(rs1_data_reg),
	.isWFI(isWFI),
	.interrupt_re(interrupt_re),  // mret
	.interrupt_dma(interrupt_dma),
	.interrupt_timer(1'b0),   // !!!!!!!!!!!!!!!!!1
	.pcInterrupt(pc_ID),
	.isCSR(isCSR),
	.CSR_out(CSR_out),
	.mtvec(mtvec),  // In this design, fix to 32'hh0001_0000. 
	.mepc(mepc),
	.interrupt(interrupt)
	);


Controller u_controller(
	.clk(clk),
	.rst(rst),
	.busStall(busStall),
	.opcode(opcode_ID),
	.funct3(funct3_ID),
	.funct7(funct7_ID),
	.rs1_addr(rs1_addr_ID),
	.rs2_addr(rs2_addr_ID),
	.rd_addr_EX(rd_addr_EX),
	.rd_addr_MEM(rd_addr_MEM),
	.wb_en_MEM(wb_en_MEM),
	.rd_addr_WB(rd_addr_WB),
	.wb_en_WB(wb_en_WB),
	.fwb_en_MEM(fwb_en_MEM),
	.fwb_en_WB(fwb_en_WB),
	.taken(taken),
	.reg1_sel(reg1_sel),
	.reg2_sel(reg2_sel),
	.mux1_sel(mux1_sel),
	.mux2_sel(mux2_sel),
	.mux3_sel(mux3_sel),
	.mux4_sel(mux4_sel),
	.alu_ctrl(alu_ctrl),
	.mul_ctrl(mul_ctrl),
	.alu_mul_sel(alu_mul_sel),
	.is_load_EX(is_load_EX),
	.is_store_EX(is_store_EX),
	.is_branch_EX(is_branch_EX),
	.load_use(load_use),
	.pc_sel(pc_sel),
	.instr_sel(instr_sel),
	.DM_CEB(DM_CEB),
	.DM_WEB_EX(DM_WEB),
	.wb_en_EX(wb_en_EX),
	.fwb_en_EX(fwb_en_EX),
	.floatAddSub(floatAddSub)	
	);


Register u_register(
	.clk(clk),
	.rst(rst),
	.busStall(busStall),
	.wb_en(wb_en_WB),
	.wb_addr(rd_addr_WB),
	.write_data(alu_out_WB),
	.rs1_addr(rs1_addr_ID),
	.rs2_addr(rs2_addr_ID),
	.rs1_data(rs1_data),
	.rs2_data(rs2_data)
	);


FloatRegister u_floatRegister(
	.clk(clk),
	.rst(rst),
	.busStall(busStall),
	.fwb_en(fwb_en_WB),
	.fwb_addr(rd_addr_WB),
	.fwb_data(alu_out_WB),
	.frs1_addr(rs1_addr_ID),
	.frs2_addr(rs2_addr_ID),
	.frs1_data(frs1_data),
	.frs2_data(frs2_data)
	);


ID_EXE u_ID_EXE(
    .clk(clk),
    .rst(rst),
    .busStall(busStall),
    .opcode(opcode_ID),
    .reg1_sel(reg1_sel),
    .reg2_sel(reg2_sel),
    .pc_ID(pc_ID),
    .imm_ID(imm_ID),
    .alu_out_WB(alu_out_WB),
    .rd_addr(rd_addr_ID),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .frs1_data(frs1_data),
    .frs2_data(frs2_data),
    .pc_EX(pc_EX),
    .rd_addr_EX(rd_addr_EX),
    .rs1_data_reg(rs1_data_reg),
    .rs2_data_reg(rs2_data_reg),
    .imm_EX(imm_EX)
    );


EX_MEM u_EX_MEM(
	.clk(clk),
    .rst(rst),
    .busStall(busStall),
    .mux1_sel(mux1_sel),        
	.mux2_sel(mux2_sel), 
	.mux3_sel(mux3_sel), 
	.mux4_sel(mux4_sel),
	.alu_ctrl(alu_ctrl),
	.mul_ctrl(mul_ctrl),
	.rs1_data_reg(rs1_data_reg),
	.rs2_data_reg(rs2_data_reg),
	.fw_from_MEM(alu_out_MEM),
	.fw_from_WB(alu_out_WB),
	.pc_EX(pc_EX),
	.imm_EX(imm_EX),
	.isCSR(isCSR), 
	.CSR_out(CSR_out),
	.alu_mul_sel(alu_mul_sel),
	.rd_addr_EX(rd_addr_EX),
	.wb_en_EX(wb_en_EX),
	.fwb_en_EX(fwb_en_EX),
	.floatAddSub(floatAddSub),
	.is_load_EX(is_load_EX),
	.is_store_EX(is_store_EX),
	.is_branch_EX(is_branch_EX),
	.src1_st1(src1_st1),
	.src2_st1(src2_st1),
	.alu_out_wire(alu_out_wire),
	.alu_out_MEM(alu_out_MEM),
	.taken(taken),
	.rd_addr_MEM(rd_addr_MEM),
	.wb_en_MEM(wb_en_MEM),
	.fwb_en_MEM(fwb_en_MEM),
	.is_load_MEM(is_load_MEM),
	.DM_BWEB_MEM(DM_BWEB)
    );


MEM_WB u_MEM_WB(
    .clk(clk),
    .rst(rst),
    .busStall(busStall),
    .wb_en_MEM(wb_en_MEM),
    .fwb_en_MEM(fwb_en_MEM),
    .is_load_MEM(is_load_MEM),
    .rd_addr_MEM(rd_addr_MEM),
    .alu_out_MEM(alu_out_MEM),
    .DM_CEB(DM_CEB),
    .DM_OUT(DM_OUT),
    .DM_shift(alu_out_wire[1:0]),
    .wb_en_WB(wb_en_WB),
    .fwb_en_WB(fwb_en_WB),
    .rd_addr_WB(rd_addr_WB),
    .alu_out_WB(alu_out_WB)
    );


endmodule