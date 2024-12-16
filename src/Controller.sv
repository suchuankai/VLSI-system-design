`include "define.svh"

module Controller(
	input clk, 
	input rst,
	input [6:0] opcode,
	input [2:0] funct3,
	input [6:0] funct7,
	input [4:0] rs1_addr,
	input [4:0] rs2_addr,
	input [31:0] src1_st1,
	input [31:0] src2_st1,
	input [4:0] rd_addr_ex,
	input [4:0] rd_addr_mem,
	input wb_en_mem,
	input [4:0] rd_addr_wb,
	input wb_en_wb,
	output logic [1:0] mux1_sel,   // Select the src1 1st stage mux before ALU 
	output logic [1:0] mux2_sel,   // Select the src2 1st stage mux before ALU 
	output logic mux3_sel,   // Select the src1 2nd stage mux before ALU 
	output logic mux4_sel,   // Select the src2 2nd stage mux before ALU 
	output logic [1:0] pc_sel, // Select PC+4, PC, jump/branch address
	output logic [3:0] alu_ctrl,
	output logic DM_WEB_ID,
	output logic [31:0] DM_BWEB,
	output logic wb_en,
	output logic [1:0] instr_sel 
	);


// alu_ctrl signal needs opcode, func3, func7 to define
always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		alu_ctrl <= 4'b0000;
	end
	else begin
		case(opcode)
			`Rtype: alu_ctrl <= {funct7[5], funct3};
			`Itype: alu_ctrl <= (funct3==3'b001 || funct3==3'b101)? {funct7[5], funct3} : {1'b0, funct3};
			`JAL, 
			`JALR,
			`Load,
			`Store,
			`Branch,
			`AUIPC:  alu_ctrl <= 4'b0000;
			`LUI:    alu_ctrl <= 4'b1001;
			default: alu_ctrl <= 4'b0000;
		endcase
	end
end

// ALU dataflow
always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		mux1_sel <= 2'b00;
	end
	else begin
		if(rs1_addr==rd_addr_ex && wb_en) mux1_sel <= 2'b01;
		else if(rs1_addr==rd_addr_mem && wb_en_mem) mux1_sel <= 2'b10;
		else if(rs1_addr==rd_addr_wb && wb_en_wb) mux1_sel <= 2'b11;
		else mux1_sel <= 2'b00;
	end
end

always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		mux2_sel <= 2'b00;
	end
	else begin
		if(rs2_addr==rd_addr_ex && wb_en) mux2_sel <= 2'b01;
		else if(rs2_addr==rd_addr_mem && wb_en_mem) mux2_sel <= 2'b10;
		else if(rs2_addr==rd_addr_wb && wb_en_wb) mux2_sel <= 2'b11;
		else mux2_sel <= 2'b00;
	end
end

always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		mux3_sel <= 1'b0;
	end
	else begin
		mux3_sel <= (opcode==`Branch || opcode==`AUIPC || opcode==`JAL)? 1'b1:1'b0; // PC relate instruction
	end
end

always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		mux4_sel <= 1'b0;
	end
	else begin
		mux4_sel <= (opcode==`Rtype)? 1'b0:1'b1;
	end
end

// DM Load/Store enable 
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		DM_WEB_ID <= 1'b1;  // read
		DM_BWEB <= 32'd0;
	end
	else begin
		DM_WEB_ID <= (opcode==`Store)? 0:1;
	end
end

// Write back control (Only branch instruction don't need write back)
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		wb_en <= 1'b0;
	end
	else begin
		wb_en <= (opcode==`Branch || pc_sel==2'b01)? 0:1;
	end
end

logic [2:0] funct3_reg; 
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		funct3_reg <= 3'b000;
	end
	else begin
		funct3_reg <= funct3;
	end
end

// Branch Compare
logic taken;
always_comb begin
	if(opcode==`Branch) begin
		case(funct3_reg[2:1])
			2'b00: begin   // BEQ, BNE
				taken = (src1_st1 == src2_st1) ^ funct3_reg[0];
			end
			2'b10: begin   // BLT, BGE
				taken = ($signed(src1_st1) < $signed(src2_st1)) ^ funct3_reg[0];
			end  
			2'b11: begin   // BLTU、 BGEU
				taken = ($unsigned(src1_st1) < $unsigned(src2_st1)) ^ funct3_reg[0];
			end
			default: begin
				taken = 1'b0;
			end
		endcase
	end
	else taken = 1'b0;		
end

// logic taken_reg;
// always_ff@(posedge clk, posedge rst) begin
// 	if(rst) begin
// 		taken_reg <= 1'b0;
// 	end
// 	else begin
// 		taken_reg <= taken;
// 	end
// end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		instr_sel <= 2'b00;
	end
	else begin
		if(pc_sel==2'b01) instr_sel <= 2'b10;
		// else if() load-use
		else instr_sel <= 2'b00;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		pc_sel <= 2'b00;
	end
	else begin
		case(opcode)
			`JAL: pc_sel <= 2'b01; // ALU out
			`Branch: pc_sel <= (taken==1'b1)? 2'b01 : 2'b00; // ALU out
			default: pc_sel <= 2'b00;
		endcase
	end
end

endmodule
