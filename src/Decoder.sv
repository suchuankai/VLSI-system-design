`include "define.svh"

module Decoder(
	input clk, 
	input rst,
	input [31:0] instr,
	output [6:0] opcode,
	output logic [5:0] rd_addr,
	output [2:0] funct3,
	output logic [5:0] rs1_addr,
	output logic [5:0] rs2_addr,
	output [6:0] funct7,
	output logic [31:0] imm
	);

// Decode
assign opcode   = instr[6:0];
assign funct3   = instr[14:12];
assign funct7   = instr[31:25];

always_comb begin
	if(opcode==`FLW || opcode==`FALU) rd_addr  = {1'b1, instr[11:7]};  // Use first bit to indicate which register type.
	else rd_addr = {1'b0, instr[11:7]};
	
	if(opcode==`FSW || opcode==`FALU) rs2_addr = {1'b1, instr[24:20]};
	else rs2_addr = {1'b0, instr[24:20]};

	if(opcode==`FALU) rs1_addr = {1'b1, instr[19:15]};
	else rs1_addr = {1'b0, instr[19:15]};
end

// Immediate generate
// logic [31:0] imm_tmp;
always_comb begin
	case(opcode)
		`Itype,
		`Load, 
		`FLW,
		`JALR  : imm = {{20{instr[31]}}, instr[31:20]};  // Notice shift command use "shamt"
		`FSW,
		`Store : imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
		`Branch: imm = {{19{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
		`AUIPC,
		`LUI   : imm = {instr[31:12], 12'd0};
		`JAL   : imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
		default: imm = 32'd0; 
	endcase
end

// always_comb begin
// 	if(opcode==`Itype && (funct3==3'b001 || funct3==3'b101) ) imm = {27'd0 ,imm_tmp[4:0]};  // Shift instruction just use shamt bit
// 	else imm = imm_tmp;
// end


endmodule