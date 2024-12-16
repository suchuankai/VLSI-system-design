`include "ALU.sv"

module EX_MEM(
	input clk,
	input rst,
	input [1:0] mux1_sel,        
	input [1:0] mux2_sel, 
	input mux3_sel, 
	input mux4_sel, 
	input [3:0] alu_ctrl,
	input [31:0] pc_EX,
	input [31:0] rs1_data,
	input [31:0] rs2_data,
	input [31:0] rs1_data_reg,
	input [31:0] rs2_data_reg,
	input [31:0] fw_from_mem,
	input [31:0] fw_from_wb,
	input [31:0] imm,
	input [4:0] rd_addr_ex,
	input wb_en_ex,
	output logic [4:0] rd_addr_mem,
	output logic wb_en_mem,
	output logic [31:0] src1_st1,    // For Store
	output logic [31:0] src2_st1,    // For Store
	output logic [31:0] alu_out_wire,
	output logic [31:0] alu_out_mem
	);

logic [31:0] src1_st1, src1_st2;
logic [31:0] src2_st2;

// Data from register or forward
always_comb begin
	case(mux1_sel)
		2'b00: src1_st1 = rs1_data_reg;
		2'b01: src1_st1 = fw_from_mem;
		2'b10: src1_st1 = fw_from_wb;
		2'b11: src1_st1 = rs1_data;
		default: src1_st1 = rs1_data_reg;
	endcase
end

always_comb begin
	case(mux2_sel)
		2'b00: src2_st1 = rs2_data_reg;
		2'b01: src2_st1 = fw_from_mem;
		2'b10: src2_st1 = fw_from_wb;
		2'b11: src2_st1 = rs2_data;
		default: src2_st1 = rs2_data_reg;
	endcase
end

always_comb begin
	case(mux3_sel)
		1'b0: src1_st2 = src1_st1;
		1'b1: src1_st2 = pc_EX;
	endcase
end

always_comb begin
	case(mux4_sel)
		1'b0: src2_st2 = src2_st1;
		1'b1: src2_st2 = imm; 
	endcase
end

ALU ALU_0(
	.alu_ctrl(alu_ctrl),
	.src1(src1_st2),
	.src2(src2_st2),
	.alu_out(alu_out_wire)
	);

always@(posedge clk, posedge rst) begin
	if(rst) begin
		alu_out_mem <= 32'd0;
	end
	else begin
		alu_out_mem <= alu_out_wire;
	end
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		rd_addr_mem <= 5'd0;
	end
	else begin
		rd_addr_mem <= rd_addr_ex;
	end
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		wb_en_mem <= 1'b0;
	end
	else begin
		wb_en_mem <= wb_en_ex;
	end
end

endmodule