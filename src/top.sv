`include "SRAM_wrapper.sv"
`include "CPU.sv"

module top (
	input clk, 
	input rst
);

logic [31:0] instr;
logic [13:0] pc;    // Instruction memory address

CPU CPU_0(.clk(clk),
	      .rst(rst),
	      .instr(instr),
          .pc(pc)
          );

SRAM_wrapper IM1(.CLK(clk), 
	             .RST(rst), 
	             .CEB(1'b0),     // Chip enable (active low)
	             .WEB(1'b1),     // Read->active high | Write->active low 
	             .BWEB(4'b1111), // Bit write enable (active low) 
	             .A(pc),         // Address
	             .DI(32'd0),     // Data input
	             .DO(instr)      // Data output
	             );         


logic w_en;            // Read/Write enable
logic [31:0] bweb;     // Bit write enable 
logic [13:0] addr;     // Data memory Read/Write address
logic [31:0] DM_input; 
logic [31:0] DM_output;


SRAM_wrapper DM1(.CLK(clk), 
	             .RST(rst), 
	             .CEB(1'b0),    // Chip enable (active low)
	             .WEB(1'b0), 
	             .BWEB(32'd0), 
	             .A(32'd0), 
	             .DI(32'd0), 
	             .DO(DM_output));


endmodule