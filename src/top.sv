`include "SRAM_wrapper.sv"
`include "CPU.sv"

module top (
	input clk, 
	input rst
);

// IM
logic [31:0] instr;
logic [13:0] pc;    // Instruction memory address

// DM
logic DM_WEB;
logic [31:0] DM_BWEB;
logic [13:0] DM_A; 
logic [31:0] DM_IN;
logic [31:0] DM_OUT;
logic DM_CEB;

CPU u_CPU(
	.clk(clk),
    .rst(rst),
    .instr(instr),
    .pc(pc),
    .DM_WEB(DM_WEB), 
    .DM_BWEB(DM_BWEB), 
    .DM_A(DM_A), 
    .DM_IN(DM_IN), 
    .DM_OUT(DM_OUT),
    .DM_CEB(DM_CEB)
    );


SRAM_wrapper IM1(
	.CLK(clk), 
	.RST(rst), 
	.CEB(1'b0),          // Chip enable (active low)
	.WEB(1'b1),          // Read->active high | Write->active low 
	.BWEB(32'hffffffff), // Bit write enable (active low) 
	.A(pc),              // Address
	.DI(32'd0),          // Data input
	.DO(instr)           // Data output
	);         


SRAM_wrapper DM1(
	.CLK(clk), 
	.RST(rst), 
	.CEB(DM_CEB),
	.WEB(DM_WEB),
	.BWEB(DM_BWEB), 
	.A(DM_A), 
	.DI(DM_IN), 
	.DO(DM_OUT));


endmodule