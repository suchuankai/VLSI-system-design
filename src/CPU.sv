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
logic mux3_sel, mux3_sel;
Controller controller_0(
	.clk(clk),
	.rst(rst),
	.opcode(opcode_wire),
	.mux3_sel(mux3_sel),
	.mux4_sel(mux4_sel),
	.alu_ctrl(alu_ctrl)
	);


logic [31:0] rs1_data, rs2_data;
Register reg_0(
	.clk(clk),
	.rst(rst),
	.wb_en(),
	.wb_addr(),
	.write_data(),
	.rs1_addr(rs1_wire),
	.rs2_addr(rs2_wire),
	.rs1_data(rs1_data),
	.rs2_data(rs2_data)
	);


ID_EXE ID_EXE_0(
	.clk(clk),
    .rst(rst)
    );


logic [31:0] alu_out;
logic [31:0] alu_out_wire;  // For DM quickly access

EX_MEM EX_MEM_0(
	.clk(clk),
    .rst(rst),
    .mux1_sel(2'b00),        
	.mux2_sel(2'b00), 
	.mux3_sel(mux3_sel), 
	.mux4_sel(mux4_sel), 
	.alu_ctrl(alu_ctrl),
	.rs1_data(rs1_data),
	.rs2_data(rs2_data),
	.alu_out_wire(alu_out_wire),
	.alu_out(alu_out)
    );

endmodule