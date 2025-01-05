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
	input [31:0] rs1_data_reg,
	input [31:0] rs2_data_reg,
	input [31:0] fw_from_MEM,
	input [31:0] fw_from_WB,
	input [31:0] pc_EX,
	input [31:0] imm_EX,
	input isCSR,
	input [31:0] CSR_out,
	input [1:0] alu_mul_sel,
	input [5:0] rd_addr_EX,
	input wb_en_EX,
	input fwb_en_EX,
	input floatAddSub,
	input [2:0] is_load_EX,
	input [1:0] is_store_EX,
	input [2:0] is_branch_EX,
	output logic [31:0] src1_st1,    // For Store
	output logic [31:0] src2_st1,    // For Store
	output logic [31:0] alu_out_wire,
	output logic [31:0] alu_out_MEM,
	output logic taken,
	output logic [5:0] rd_addr_MEM,
	output logic wb_en_MEM,
	output logic fwb_en_MEM,
	output logic [2:0] is_load_MEM,
	output logic [31:0] DM_BWEB_MEM
	);

logic [31:0] src1_st1, src1_st2;
logic [31:0] src2_st2;

// Data from register or forward
always_comb begin
	case(mux1_sel)
		2'b00: src1_st1 = rs1_data_reg;
		2'b01: src1_st1 = fw_from_MEM;
		2'b10: src1_st1 = fw_from_WB;
		default: src1_st1 = rs1_data_reg;
	endcase
end

logic [31:0] src2_st1_tmp;
always_comb begin
	case(mux2_sel)
		2'b00: src2_st1_tmp = rs2_data_reg;
		2'b01: src2_st1_tmp = fw_from_MEM;
		2'b10: src2_st1_tmp = fw_from_WB;
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
		1'b1: src2_st2 = imm_EX; 
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
	if(is_branch_EX!=3'b000) begin
		case(is_branch_EX[1:0])
			2'b01: begin   // BEQ, BNE
				taken = (src1_st1 == src2_st1_tmp) ^ is_branch_EX[2];
			end
			2'b10: begin   // BLT, BGE
				taken = ($signed(src1_st1) < $signed(src2_st1_tmp)) ^ is_branch_EX[2];
			end  
			2'b11: begin   // BLTU、 BGEU
				taken = ($unsigned(src1_st1) < $unsigned(src2_st1_tmp)) ^ is_branch_EX[2];
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
		alu_out_MEM <= 32'd0;
	end
	else begin
		if(isCSR) alu_out_MEM <= CSR_out;
		else if(fwb_en_EX) alu_out_MEM <= fpu_out;
		else begin
			case(alu_mul_sel)
				2'b00: alu_out_MEM <= alu_out_wire;
				2'b01: alu_out_MEM <= mul_out;
				2'b10: alu_out_MEM <= pc_EX + 4;   // For jalr
				default: alu_out_MEM <= alu_out_MEM;  // Load use
			endcase
		end
	end
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		rd_addr_MEM <= 6'd0;
	end
	else begin
		rd_addr_MEM <= rd_addr_EX;
	end
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		wb_en_MEM <= 1'b0;
		fwb_en_MEM <= 1'b0;
	end
	else begin
		wb_en_MEM <= wb_en_EX;
		fwb_en_MEM <= fwb_en_EX;
	end
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		is_load_MEM <= 3'b000;
	end
	else begin
		is_load_MEM <= is_load_EX;
	end
end

always_comb begin
	if(is_store_EX!=2'b00) begin
		if(alu_out_wire[1:0]==2'b00)begin
			case(is_store_EX)
				2'b01: DM_BWEB_MEM = 32'h0000_0000; // SW
				2'b10: DM_BWEB_MEM = 32'hffff_0000; // SH
				2'b11: DM_BWEB_MEM = 32'hffff_ff00; // SB
				default: DM_BWEB_MEM = 32'hffff_ffff; // Error instruction
			endcase
			src2_st1 = src2_st1_tmp;
		end
		else if(alu_out_wire[1:0]==2'b01)begin
			case(is_store_EX)
				2'b01: DM_BWEB_MEM = 32'h0000_00ff; // SW
				2'b10: DM_BWEB_MEM = 32'hff00_00ff; // SH
				2'b11: DM_BWEB_MEM = 32'hffff_00ff; // SB
				default: DM_BWEB_MEM = 32'hffff_ffff; // Error instruction
			endcase
			src2_st1 = src2_st1_tmp << 8;
		end
		else if(alu_out_wire[1:0]==2'b10) begin
			case(is_store_EX)
				2'b01: DM_BWEB_MEM = 32'h0000_ffff; // SW
				2'b10: DM_BWEB_MEM = 32'h0000_ffff; // SH
				2'b11: DM_BWEB_MEM = 32'hff00_ffff; // SB
				default: DM_BWEB_MEM = 32'hffff_ffff; // Error instruction
			endcase
			src2_st1 = src2_st1_tmp << 16;
		end
		else begin  // 2'b11
			case(is_store_EX)
				2'b01: DM_BWEB_MEM = 32'h00ff_ffff; // SW
				2'b10: DM_BWEB_MEM = 32'h00ff_ffff; // SH
				2'b11: DM_BWEB_MEM = 32'h00ff_ffff; // SB
				default: DM_BWEB_MEM = 32'hffff_ffff; // Error instruction
			endcase
			src2_st1 = src2_st1_tmp << 24;
		end
	end
	else begin
		DM_BWEB_MEM = 32'hffff_ffff;
		src2_st1 = src2_st1_tmp;
	end
end

endmodule