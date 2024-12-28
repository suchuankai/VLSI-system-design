`include "define.svh"

module Controller(
	input clk, 
	input rst,
	input [6:0] opcode,
	input [2:0] funct3,
	input [6:0] funct7,
	input [4:0] rs1_addr,
	input [4:0] rs2_addr,
	input [31:0] rs1_data,
	input [31:0] rs2_data,
	input [4:0] rd_addr_ex,
	input [4:0] rd_addr_mem,
	input wb_en_mem,
	input [4:0] rd_addr_wb,
	input wb_en_wb,
	input float_wb_en_mem,
	input float_wb_en_wb,
	input taken,                   // Signal to check branch instruction
	output logic [1:0] mux1_sel,   // Select the src1 1st stage mux before ALU 
	output logic [1:0] mux2_sel,   // Select the src2 1st stage mux before ALU 
	output logic mux3_sel,   // Select the src1 2nd stage mux before ALU 
	output logic mux4_sel,   // Select the src2 2nd stage mux before ALU 
	output logic [1:0] pc_sel, // Select PC+4, PC, jump/branch address
	output logic [3:0] alu_ctrl,
	output logic [1:0] mul_ctrl,
	output logic [1:0] alu_mul_sel,
	output logic DM_WEB_EX,
	output logic [2:0] is_load_ex,
	output logic [1:0] is_store_ex, 
	output logic [2:0] is_branch,
	output logic wb_en,
	output logic [1:0] instr_sel, 
	output logic float_wb_en_ex,
	output logic floatAddSub
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

always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		mul_ctrl <= 2'b00;
	end
	else begin
		if(opcode==`Rtype) begin
			case({funct7[0], funct3[1:0]})
				3'b100: mul_ctrl <= 2'b00;
				3'b101: mul_ctrl <= 2'b01;
				3'b110: mul_ctrl <= 2'b10;
				3'b111: mul_ctrl <= 2'b11;
			endcase
		end
	end
end

always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		alu_mul_sel <= 2'b00;
	end
	else begin
		if(opcode==`Rtype && funct7[0]) alu_mul_sel <= 2'b01;
		else if(opcode==`JALR || opcode==`JAL) alu_mul_sel <= 2'b10;
		else alu_mul_sel <= 2'b00;
	end
end

// ALU dataflow
always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		mux1_sel <= 2'b00;
	end
	else begin
		if(rs1_addr==rd_addr_ex && rd_addr_ex!=5'd0 && (wb_en || float_wb_en_ex)) mux1_sel <= 2'b01;
		else if(rs1_addr==rd_addr_mem && rd_addr_mem!=5'd0 && (wb_en_mem || float_wb_en_mem)) mux1_sel <= 2'b10;
		else mux1_sel <= 2'b00;
	end
end

always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		mux2_sel <= 2'b00;
	end
	else begin
		if(rs2_addr==rd_addr_ex && rd_addr_ex!=5'd0 && (wb_en || float_wb_en_ex)) mux2_sel <= 2'b01;
		else if(rs2_addr==rd_addr_mem && rd_addr_mem!=5'd0 && (wb_en_mem || float_wb_en_mem)) mux2_sel <= 2'b10;
		else mux2_sel <= 2'b00;
	end
end

always_ff@(posedge clk or posedge rst) begin  // PC or rs1
	if(rst) begin
		mux3_sel <= 1'b0;
	end
	else begin
		mux3_sel <= (opcode==`Branch || opcode==`AUIPC || opcode==`JAL)? 1'b1:1'b0; // PC relate instruction
	end
end

always_ff@(posedge clk or posedge rst) begin // imm or rs2
	if(rst) begin
		mux4_sel <= 1'b0;
	end
	else begin
		mux4_sel <= (opcode==`Rtype || opcode==`FALU)? 1'b0:1'b1;
	end
end

// Load use stall control
logic [6:0] opcode_reg;
logic load_use, load_use_reg;

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		opcode_reg <= 1'b0;
	end
	else begin
		opcode_reg <= (load_use)? 7'd0: opcode;
	end
end

assign load_use = ( (opcode_reg==`Load || opcode_reg==`FLW) && ((rd_addr_ex==rs1_addr) || (rd_addr_ex==rs2_addr)) );

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		load_use_reg <= 1'b0;
	end
	else begin
		load_use_reg <= load_use;
	end
end

// DM Load/Store enable 
logic delay;
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		DM_WEB_EX <= 1'b1;  // read
		delay <= 1'b0;
	end
	else begin
		delay <= 1'b1;
		if(delay)
			DM_WEB_EX <= ((opcode==`Store || opcode==`FSW) && !load_use)? 0:1;
	end
end

// Write back control (Only branch instruction don't need write back)
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		wb_en <= 1'b0;
	end
	else begin
		wb_en <= (opcode==`Branch || opcode==`Store || opcode==`FSW || opcode==`FLW || pc_sel==2'b01 || load_use)? 0:1;
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

always_comb begin
	if(pc_sel==2'b01) instr_sel = 2'b10;
	else if(load_use_reg) instr_sel = 2'b01; // When load use occur, still use previous instr.
	else instr_sel = 2'b00;
end

always_comb begin
	case(opcode_reg)
		`JAL: pc_sel = 2'b01; // ALU out  
		`JALR: pc_sel = 2'b01; // ALU out  
		`Branch: pc_sel = (taken==1'b1)? 2'b01 : 2'b00; // ALU out
		`Load,
		`FLW: pc_sel = ((rd_addr_ex==rs1_addr) || (rd_addr_ex==rs2_addr))? 2'b10:2'b00;
		default: pc_sel = 2'b00;
	endcase
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		is_store_ex <= 2'b00;
	end
	else begin
		if(opcode == `Store || opcode == `FSW) begin
			case(funct3)
				3'b010: is_store_ex <= 2'b01;  // SW
				3'b001: is_store_ex <= 2'b10;  // SH
				3'b000: is_store_ex <= 2'b11;  // SB
			endcase
		end
		else is_store_ex <= 2'b00;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		is_load_ex <= 3'b000;
	end
	else begin
		if(opcode==`Load || opcode==`FLW) begin
			case(funct3)
				3'b000: is_load_ex <= 3'b001;  // LB
				3'b001: is_load_ex <= 3'b010;  // LH
				3'b010: is_load_ex <= 3'b011;  // LW, FLW
				3'b100: is_load_ex <= 3'b100;  // LHU
				3'b101: is_load_ex <= 3'b101;  // LBU
				default: is_load_ex <= 3'b000;
			endcase
		end
		else is_load_ex <= 3'b000;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		is_branch <= 3'b000;
	end
	else begin
		if(opcode == `Branch) begin
			case(funct3[2:1])
				2'b00: begin   // BEQ, BNE
					is_branch <= {funct3[0], 2'b01};
				end
				2'b10: begin   // BLT, BGE
					is_branch <= {funct3[0], 2'b10};
				end  
				2'b11: begin   // BLTU、 BGEU
					is_branch <= {funct3[0], 2'b11};
				end
				default: begin
					is_branch <= {funct3[0], 2'b00};
				end
			endcase
		end
		else is_branch <= 3'b000;
	end
end

// Floating Register control
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		float_wb_en_ex <= 1'b0;
	end
	else begin
		if(load_use) float_wb_en_ex <= 1'b0;
		else float_wb_en_ex <= (opcode==`FLW || opcode==`FALU)? 1'b1:1'b0;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		floatAddSub <= 1'b0;
	end
	else begin
		floatAddSub <= (funct7[2])? 1'b1:1'b0;  // funct5[0]
	end
end

endmodule
