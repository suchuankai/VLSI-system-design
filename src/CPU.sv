`include "PC.sv"
`include "IF_ID.sv"
`include "ID_EXE.sv"
`include "EX_MEM.sv"
`include "MEM_WB.sv"
`include "Decoder.sv"
`include "Controller.sv"
`include "Register.sv"

module CPU(
	input clk, 
	input rst,
	/* IM */
	input [31:0] instr,
	output [13:0] pc,
	/* DM */
	input [31:0] DM_OUT,
	output DM_WEB,
	output [31:0] DM_BWEB,
	output [13:0] DM_A,
	output [31:0] DM_IN 
	);

logic [31:0] src1_st1, src2_st1;
assign DM_IN = src2_st1;
logic [31:0] alu_out_wire;  // For DM quickly access(DM_addr)
assign DM_A = alu_out_wire[15:2];

logic [1:0] pc_sel;
logic [31:0] pc_reg;
logic [1:0] instr_sel;

PC PC_0(
	.clk(clk),
    .rst(rst),
    .pc_sel(pc_sel),
    .alu_out(alu_out_wire),
    .pc(pc),
    .pc_reg(pc_reg)
    );

logic [31:0] pc_ID;
logic [31:0] instr_ID;
IF_ID IF_ID_0(
	.clk(clk),
	.rst(rst),
	.pc(pc_reg),
	.instr(instr),
	.instr_sel(instr_sel),
	.pc_ID(pc_ID),
	.instr_ID(instr_ID)
	);

logic [6:0] opcode_wire;
logic [4:0] rd_wire;
logic [2:0] funct3_wire;
logic [4:0] rs1_wire;
logic [4:0] rs2_wire;
logic [6:0] funct7_wire;
logic [31:0] imm_wire;

Decoder decode_0(
	.clk(clk), 
	.rst(rst),
	.instr(instr_ID),
	.opcode(opcode_wire),
	.rd_addr(rd_wire),
	.funct3(funct3_wire),
	.rs1_addr(rs1_wire),
	.rs2_addr(rs2_wire),
	.funct7(funct7_wire),
	.imm(imm_wire)
	);

// Control signals
logic [3:0] alu_ctrl;
logic [1:0] mul_ctrl;
logic wb_en, wb_en_mem, wb_en_wb;
logic [1:0] mux1_sel, mux2_sel;
logic mux3_sel, mux3_sel;
logic [4:0] rd_addr_mem;
logic [4:0] rd_addr_ex;
logic [4:0] rd_addr_wb;
logic DM_WEB_ID;
logic [1:0] alu_mul_sel;
logic [31:0] rs1_data, rs2_data;
logic [2:0] is_load_ex; 
logic is_store_ex;

Controller controller_0(
	.clk(clk),
	.rst(rst),
	.opcode(opcode_wire),
	.funct3(funct3_wire),
	.funct7(funct7_wire),
	.rs1_addr(rs1_wire),
	.rs2_addr(rs2_wire),
	.rs1_data(rs1_data),
	.rs2_data(rs2_data),
	.rd_addr_ex(rd_addr_ex),
	.rd_addr_mem(rd_addr_mem),
	.wb_en_mem(wb_en_mem),
	.rd_addr_wb(rd_addr_wb),
	.wb_en_wb(wb_en_wb),
	.mux1_sel(mux1_sel),
	.mux2_sel(mux2_sel),
	.mux3_sel(mux3_sel),
	.mux4_sel(mux4_sel),
	.pc_sel(pc_sel),
	.alu_ctrl(alu_ctrl),
	.mul_ctrl(mul_ctrl),
	.alu_mul_sel(alu_mul_sel),
	.DM_WEB_EX(DM_WEB),
	.is_load_ex(is_load_ex),
	.is_store_ex(is_store_ex),
	.DM_BWEB(DM_BWEB),
	.wb_en(wb_en),
	.instr_sel(instr_sel)
	);


logic [31:0] alu_out_wb;

Register reg_0(
	.clk(clk),
	.rst(rst),
	.wb_en(wb_en_wb),
	.wb_addr(rd_addr_wb),
	.write_data(alu_out_wb),
	.rs1_addr(rs1_wire),
	.rs2_addr(rs2_wire),
	.rs1_data(rs1_data),
	.rs2_data(rs2_data)
	);

logic [31:0] imm_ex;
logic [31:0] rs1_data_reg, rs2_data_reg;
logic [31:0] pc_EX;
logic DM_WEB_EX;

ID_EXE ID_EXE_0(
    .clk(clk),
    .rst(rst),
    .pc_ID(pc_ID),
    .imm_wire(imm_wire),
    .rs1_addr(rs1_wire),
    .rs2_addr(rs2_wire),
    .rd_addr_wb(rd_addr_wb),
    .wb_en_wb(wb_en_wb),
    .alu_out_wb(alu_out_wb),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .rd_addr(rd_wire),
    .pc_EX(pc_EX),
    .rd_addr_ex(rd_addr_ex),
    .rs1_data_reg(rs1_data_reg),
    .rs2_data_reg(rs2_data_reg),
    .imm_ex(imm_ex)
    );

logic [31:0] alu_out_mem;
logic DM_WEB_MEM;
logic [2:0] is_load_mem;
logic is_store_mem;

EX_MEM EX_MEM_0(
	.clk(clk),
    .rst(rst),
    .mux1_sel(mux1_sel),        
	.mux2_sel(mux2_sel), 
	.mux3_sel(mux3_sel), 
	.mux4_sel(mux4_sel),
	.alu_ctrl(alu_ctrl),
	.mul_ctrl(mul_ctrl), 
	.alu_mul_sel(alu_mul_sel),
	.pc_EX(pc_EX),
	.rs1_data(rs1_data),
	.rs2_data(rs2_data),
	.rs1_data_reg(rs1_data_reg),
	.rs2_data_reg(rs2_data_reg),
	.fw_from_mem(alu_out_mem),
	.fw_from_wb(alu_out_wb),
	.imm(imm_ex),
	.rd_addr_ex(rd_addr_ex),
	.wb_en_ex(wb_en),
	.is_load_ex(is_load_ex),
	.is_store_ex(is_store_ex),
	.rd_addr_mem(rd_addr_mem),
	.wb_en_mem(wb_en_mem),
	.is_load_mem(is_load_mem),
	.is_store_mem(is_store_mem),
	.src1_st1(src1_st1),
	.src2_st1(src2_st1),
	.alu_out_wire(alu_out_wire),
	.alu_out_mem(alu_out_mem)
    );


MEM_WB MEM_WB_0(
    .clk(clk),
    .rst(rst),
    .wb_en_mem(wb_en_mem),
    .is_load_mem(is_load_mem),
    .is_store_mem(is_store_mem),
    .rd_addr_mem(rd_addr_mem),
    .alu_out_mem(alu_out_mem),
    .DM_OUT(DM_OUT),
    .alu_out_wb(alu_out_wb),
    .wb_en_wb(wb_en_wb),
    .rd_addr_wb(rd_addr_wb)  // Write back register address
    );

endmodule