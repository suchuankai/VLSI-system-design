`include "SRAM_wrapper.sv"
`include "CPU.sv"

module top (
	input clk, 
	input rst
);

CPU CPU_0();

SRAM_wrapper IM1(.CLK(clk), 
	             .RST(rst), 
	             .CEB(), 
	             .WEB(), 
	             .BWEB(), 
	             .A(), 
	             .DI(), 
	             .DO());

SRAM_wrapper DM1(.CLK(clk), 
	             .RST(rst), 
	             .CEB(), 
	             .WEB(), 
	             .BWEB(), 
	             .A(), 
	             .DI(), 
	             .DO());


endmodule