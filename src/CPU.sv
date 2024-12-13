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

IF_ID IF_ID_0(.clk(clk),
	          .rst(rst),
	          .pc(pc)
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
	.instr(instr),
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
logic wb_en;
logic [1:0] mux1_sel, mux2_sel;
logic mux3_sel, mux3_sel;
logic [4:0] rd_addr_mem;
logic [4:0] rd_addr_ex;
logic [4:0] rd_addr_wb;

Controller controller_0(
	.clk(clk),
	.rst(rst),
	.opcode(opcode_wire),
	.funct3(funct3_wire),
	.funct7(funct7_wire),
	.rs1_addr(rs1_wire),
	.rs2_addr(rs2_wire),
	.rd_addr_ex(rd_addr_ex),
	.rd_addr_mem(rd_addr_mem),
	.rd_addr_wb(rd_addr_wb),
	.mux1_sel(mux1_sel),
	.mux2_sel(mux2_sel),
	.mux3_sel(mux3_sel),
	.mux4_sel(mux4_sel),
	.alu_ctrl(alu_ctrl),
	.DM_WEB(DM_WEB),
	.DM_BWEB(DM_BWEB),
	.wb_en(wb_en)
	);

logic wb_en_wb;
logic [31:0] rs1_data, rs2_data;
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

logic wb_en_ex;
logic [31:0] imm_ex;
logic [31:0] rs1_data_reg, rs2_data_reg;

ID_EXE ID_EXE_0(
	.clk(clk),
    .rst(rst),
    .wb_en_ID(wb_en),
    .imm_wire(imm_wire),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .rd_addr(rd_wire),
    .wb_en_ex(wb_en_ex),
    .rd_addr_ex(rd_addr_ex),
    .rs1_data_reg(rs1_data_reg),
    .rs2_data_reg(rs2_data_reg),
    .imm_ex(imm_ex)
    );

logic [31:0] alu_out_mem;
logic [31:0] alu_out_wire;  // For DM quickly access(DM_addr)
logic wb_en_mem;

EX_MEM EX_MEM_0(
	.clk(clk),
    .rst(rst),
    .mux1_sel(mux1_sel),        
	.mux2_sel(mux2_sel), 
	.mux3_sel(mux3_sel), 
	.mux4_sel(mux4_sel), 
	.alu_ctrl(alu_ctrl),
	.rs1_data(rs1_data),
	.rs2_data(rs2_data),
	.rs1_data_reg(rs1_data_reg),
	.rs2_data_reg(rs2_data_reg),
	.fw_from_mem(alu_out_mem),
	.fw_from_wb(alu_out_wb),
	.imm(imm_ex),
	.rd_addr_ex(rd_addr_ex),
	.wb_en_ex(wb_en_ex),
	.rd_addr_mem(rd_addr_mem),
	.wb_en_mem(wb_en_mem),
	.src2_st1(DM_IN),
	.alu_out_wire(DM_A),
	.alu_out_mem(alu_out_mem)
    );


MEM_WB MEM_WB_0(
	.clk(clk),
    .rst(rst),
    .wb_en_mem(wb_en_mem),
    .rd_addr_mem(rd_addr_mem),
    .alu_out_mem(alu_out_mem),
    .alu_out_wb(alu_out_wb),
    .wb_en_wb(wb_en_wb),
    .rd_addr_wb(rd_addr_wb)  // Write back register address
    );

endmodule