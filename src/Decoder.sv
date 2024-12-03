`include "define.svh"

module Decoder(
	input clk, 
	input rst,
	input [31:0] instr,
	output [6:0] opcode,
	output [4:0] rd,
	output [2:0] funct3,
	output [4:0] rs1,
	output [4:0] rs2,
	output [6:0] funct7,
	output [31:0] imm);

// Decode
assign opcode = instr[6:0];
assign rd     = instr[11:7];
assign funct3 = instr[14:12];
assign rs1    = instr[19:15];
assign rs2    = instr[24:20];
assign funct7 = instr[31:25];

// Immediate generate
logic [31:0] imm;

always_comb begin
	case(opcode)
		`Rtype: imm = 32'd0;
		default: imm = 32'd0;
	endcase
end

endmodule