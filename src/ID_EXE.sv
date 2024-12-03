`include "Register.sv"
`include "Decoder.sv"

module ID_EXE(
	input clk, 
	input rst,
	input [31:0] instr);


Decoder decode_0(.clk(clk), 
				 .rst(rst),
				 .instr(instr),
				 .opcode(),
				 .rd(),
				 .funct3(),
				 .rs1(),
				 .rs2(),
				 .funct7(),
				 .imm());


Register reg_0(.clk(clk),
		       .rst(rst),
	           .wb_en(),
	           .wb_addr(),
	           .write_data(),
		       .rs1_addr(),
		       .rs2_addr(),
		       .rs1_data(),
		       .rs2_data());




endmodule