`include "define.svh"

module Decoder(
	input clk, 
	input rst,
	input [31:0] instr,
	output [6:0] opcode,
	output [4:0] rd_addr,
	output [2:0] funct3,
	output [4:0] rs1_addr,
	output [4:0] rs2_addr,
	output [6:0] funct7,
	output logic [31:0] imm
	);

// Decode
assign opcode   = instr[6:0];
assign rd_addr  = instr[11:7];
assign funct3   = instr[14:12];
assign rs1_addr = instr[19:15];
assign rs2_addr = instr[24:20];
assign funct7   = instr[31:25];

// Immediate generate
always_comb begin
	case(opcode)
		`Itype,
		`Load, 
		`JALR  : imm = {{20{instr[31]}}, instr[31:20]};  // Notice shift command use "shamt"
		`Store : imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
		`Branch: imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
		`AUIPC,
		`LUI   : imm = {instr[31:12], 12'd0};
		`JAL   : imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
		default: imm = 32'd0; 
	endcase
end


endmodule