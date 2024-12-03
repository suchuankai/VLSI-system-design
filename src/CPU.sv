`include "IF_ID.sv"
`include "ID_EXE.sv"

module CPU(
	input clk, 
	input rst,
	input [31:0] instr,
	output [13:0] pc
	);


logic [13:0] pc;  // connect to IM
IF_ID IF_ID_0(.clk(clk),
	          .rst(rst),
	          .pc(pc)
	          );

ID_EXE ID_EXE_0(.clk(clk),
	            .rst(rst),
	            .instr(instr)
	            );


endmodule