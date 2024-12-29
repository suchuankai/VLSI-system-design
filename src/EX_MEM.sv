`include "ALU.sv"
`include "FPU.sv"
`include "define.svh"

module EX_MEM(
	input clk,
	input rst,
	input [1:0] mux1_sel,        
	input [1:0] mux2_sel, 
	input mux3_sel, 
	input mux4_sel, 
	input [3:0] alu_ctrl,
	input [1:0] mul_ctrl,
	input isCSR,
	input [31:0] CSR_out,
	input [1:0] alu_mul_sel,
	input [31:0] pc_EX,
	input [31:0] rs1_data_reg,
	input [31:0] rs2_data_reg,
	input [31:0] fw_from_mem,
	input [31:0] fw_from_wb,
	input [31:0] imm,
	input [5:0] rd_addr_ex,
	input wb_en_ex,
	input float_wb_en_ex,
	input floatAddSub,
	input floatOpEx,
	input [2:0] is_load_ex,
	input [1:0] is_store_ex,
	input [2:0] is_branch,
	output logic taken,
	output logic [5:0] rd_addr_mem,
	output logic wb_en_mem,
	output logic float_wb_en_mem,
	output logic floatOpMem,
	output logic [2:0] is_load_mem,
	output logic [31:0] src1_st1,    // For Store
	output logic [31:0] src2_st1,    // For Store
	output logic [31:0] alu_out_wire,
	output logic [31:0] alu_out_mem,
	output logic [31:0] DM_BWEB_mem
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

logic [31:0] src2_st1_tmp;
always_comb begin
	case(mux2_sel)
		2'b00: src2_st1_tmp = rs2_data_reg;
		2'b01: src2_st1_tmp = fw_from_mem;
		2'b10: src2_st1_tmp = fw_from_wb;
		default: src2_st1_tmp = rs2_data_reg;
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
		1'b0: src2_st2 = src2_st1_tmp;
		1'b1: src2_st2 = imm; 
	endcase
end

logic [31:0] mul_out;
ALU ALU_0(
	.alu_ctrl(alu_ctrl),
	.mul_ctrl(mul_ctrl),
	.mul_in1(src1_st1),
	.mul_in2(src2_st1_tmp),
	.src1(src1_st2),
	.src2(src2_st2),
	.alu_out(alu_out_wire),
	.mul_out(mul_out)
	);


logic [31:0] fpu_out;
FPU FPU_0(
	.FA(src1_st2),
	.FB(src2_st2),
	.add_sub(floatAddSub),
	.fpu_out(fpu_out)
	);

// Branch 
always_comb begin
	if(is_branch!=3'b000) begin
		case(is_branch[1:0])
			2'b01: begin   // BEQ, BNE
				taken = (src1_st1 == src2_st1_tmp) ^ is_branch[2];
			end
			2'b10: begin   // BLT, BGE
				taken = ($signed(src1_st1) < $signed(src2_st1_tmp)) ^ is_branch[2];
			end  
			2'b11: begin   // BLTU、 BGEU
				taken = ($unsigned(src1_st1) < $unsigned(src2_st1_tmp)) ^ is_branch[2];
			end
			default: begin
				taken = 1'b0;
			end
		endcase
	end
	else taken = 1'b0;	
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		alu_out_mem <= 32'd0;
	end
	else begin
		if(isCSR) alu_out_mem <= CSR_out;
		else if(float_wb_en_ex) alu_out_mem <= fpu_out;
		else begin
			case(alu_mul_sel)
				2'b00: alu_out_mem <= alu_out_wire;
				2'b01: alu_out_mem <= mul_out;
				2'b10: alu_out_mem <= pc_EX + 4;   // For jalr
				default: alu_out_mem <= alu_out_mem;  // Load use
			endcase
		end
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
		float_wb_en_mem <= 1'b0;
	end
	else begin
		wb_en_mem <= wb_en_ex;
		float_wb_en_mem <= float_wb_en_ex;
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

always@(posedge clk, posedge rst) begin
	if(rst) begin
		floatOpMem <= 1'b0;
	end
	else begin
		floatOpMem <= floatOpEx;
	end
end

always_comb begin
	if(is_store_ex!=2'b00) begin
		if(alu_out_wire[1:0]==2'b00)begin
			case(is_store_ex)
				2'b01: DM_BWEB_mem = 32'h0000_0000; // SW
				2'b10: DM_BWEB_mem = 32'hffff_0000; // SH
				2'b11: DM_BWEB_mem = 32'hffff_ff00; // SB
				default: DM_BWEB_mem = 32'hffff_ffff; // Error instruction
			endcase
			src2_st1 = src2_st1_tmp;
		end
		else if(alu_out_wire[1:0]==2'b01)begin
			case(is_store_ex)
				2'b01: DM_BWEB_mem = 32'h0000_00ff; // SW
				2'b10: DM_BWEB_mem = 32'hff00_00ff; // SH
				2'b11: DM_BWEB_mem = 32'hffff_00ff; // SB
				default: DM_BWEB_mem = 32'hffff_ffff; // Error instruction
			endcase
			src2_st1 = src2_st1_tmp << 8;
		end
		else if(alu_out_wire[1:0]==2'b10) begin
			case(is_store_ex)
				2'b01: DM_BWEB_mem = 32'h0000_ffff; // SW
				2'b10: DM_BWEB_mem = 32'h0000_ffff; // SH
				2'b11: DM_BWEB_mem = 32'hff00_ffff; // SB
				default: DM_BWEB_mem = 32'hffff_ffff; // Error instruction
			endcase
			src2_st1 = src2_st1_tmp << 16;
		end
		else begin  // 2'b11
			case(is_store_ex)
				2'b01: DM_BWEB_mem = 32'h00ff_ffff; // SW
				2'b10: DM_BWEB_mem = 32'h00ff_ffff; // SH
				2'b11: DM_BWEB_mem = 32'h00ff_ffff; // SB
				default: DM_BWEB_mem = 32'hffff_ffff; // Error instruction
			endcase
			src2_st1 = src2_st1_tmp << 24;
		end
	end
	else begin
		DM_BWEB_mem = 32'hffff_ffff;
		src2_st1 = src2_st1_tmp;
	end
end

endmodule