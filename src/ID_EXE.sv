`include "define.svh"

module ID_EXE(
	input clk, 
	input rst,
	input [6:0] opcode,
	input reg1_sel,
	input reg2_sel,
	input [31:0] pc_ID,
	input [31:0] imm_ID,
    input [31:0] alu_out_WB,
	input [5:0] rd_addr,
	input [31:0] rs1_data,
	input [31:0] rs2_data,
	input [31:0] frs1_data,
	input [31:0] frs2_data,
	output logic [31:0] pc_EX, 
	output logic [5:0] rd_addr_EX,
	output logic [31:0] rs1_data_reg,
	output logic [31:0] rs2_data_reg,
	output logic [31:0] imm_EX
	);

always@(posedge clk or posedge rst) begin
	if(rst) begin
		rd_addr_EX <= 5'd0;
	end
	else begin
		rd_addr_EX <= rd_addr;
	end
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
		imm_EX <= 32'd0;
	end
	else begin
		imm_EX <= imm_ID;
	end
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
		rs1_data_reg <= 32'd0;
	end
	else begin
		if(reg1_sel) rs1_data_reg <= alu_out_WB;
		else if(opcode==`FALU) rs1_data_reg <= frs1_data;  // opcode==`FSW || 
		else rs1_data_reg <= rs1_data;
	end
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
		rs2_data_reg <= 32'd0;
	end 
	else begin
		if(reg2_sel) rs2_data_reg <= alu_out_WB;
		else if(opcode==`FSW || opcode==`FALU) rs2_data_reg <= frs2_data;
		else rs2_data_reg <= rs2_data;
	end
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
		pc_EX <= 32'd0;
	end
	else begin
		pc_EX <= pc_ID;
	end
end

endmodule