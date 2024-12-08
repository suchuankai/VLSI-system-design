`include "ALU.sv"

module EX_MEM(
	input clk,
	input rst,
	input mux1_sel,        
	input mux2_sel, 
	input mux3_sel, 
	input mux4_sel, 
	input alu_ctrl,
	input [31:0] rs1_data,
	input [31:0] rs2_data,
	output [31:0] alu_out_wire,
	output logic [31:0] alu_out
	);


logic [31:0] src1_st1, src1_st2;
logic [31:0] src2_st1, src2_st2;

always_comb begin
	case(mux1_sel)
		2'b00: src1_st1 = rs1_data;
		//2'b01: src1_st1 = rd_from_EX;
		//2'b10: src1_st1 = rd_from_MEM;
		//default:
	endcase
end

always_comb begin
	case(mux2_sel)
		2'b00: src2_st1 = rs2_data;
		//2'b01: src2_st1 = rd_from_EX;
		//2'b10: src2_st1 = rd_from_MEM;
		//default:
	endcase
end

always_comb begin
	case(mux3_sel)
		1'b0: src1_st2 = src1_st1;
		//1'b1: src1_st2 = ;
	endcase
end

always_comb begin
	case(mux4_sel)
		1'b0: src2_st2 = src2_st1;
		//1'b1: src2_st2 = 
	endcase
end

logic [31:0] alu_out_wire;
ALU ALU_0(
	.alu_ctrl(alu_ctrl),
	.src1(src1_st2),
	.src2(src2_st2),
	.alu_out(alu_out_wire)
	);

always@(posedge clk, posedge rst) begin
	if(rst) begin
		alu_out <= 32'd0;
	end
	else begin
		alu_out <= alu_out_wire;
	end
end


endmodule