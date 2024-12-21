`include "ALU.sv"

module EX_MEM(
	input clk,
	input rst,
	input [1:0] mux1_sel,        
	input [1:0] mux2_sel, 
	input mux3_sel, 
	input mux4_sel, 
	input [3:0] alu_ctrl,
	input [1:0] mul_ctrl,
	input [1:0] alu_mul_sel,
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
	input [2:0] is_load_ex,
	input is_store_ex,
	output logic [4:0] rd_addr_mem,
	output logic wb_en_mem,
	output logic [2:0] is_load_mem,
	output logic is_store_mem,
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
		default: src1_st1 = rs1_data_reg;
	endcase
end

always_comb begin
	case(mux2_sel)
		2'b00: src2_st1 = rs2_data_reg;
		2'b01: src2_st1 = fw_from_mem;
		2'b10: src2_st1 = fw_from_wb;
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

logic [31:0] mul_out;
ALU ALU_0(
	.alu_ctrl(alu_ctrl),
	.mul_ctrl(mul_ctrl),
	.mul_in1(src1_st1),
	.mul_in2(src2_st1),
	.src1(src1_st2),
	.src2(src2_st2),
	.alu_out(alu_out_wire),
	.mul_out(mul_out)
	);

always@(posedge clk, posedge rst) begin
	if(rst) begin
		alu_out_mem <= 32'd0;
	end
	else begin
		case(alu_mul_sel)
			2'b00: alu_out_mem <= alu_out_wire;
			2'b01: alu_out_mem <= mul_out;
			2'b10: alu_out_mem <= pc_EX + 4;   // For jalr
			default: alu_out_mem <= alu_out_wire;
		endcase
		// alu_out_mem <= (alu_mul_sel)? mul_out : alu_out_wire;
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

always@(posedge clk, posedge rst) begin
	if(rst) begin
		is_store_mem <= 1'b0;
	end
	else begin
		is_store_mem <= is_store_ex;
	end
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		is_load_mem <= 3'b000;
	end
	else begin
		is_load_mem <= is_load_ex;
	end
end

endmodule