module Decoder(
	input clk, 
	input rst,
	input [31:0] instr,
	input interrupt,
	output [6:0] opcode_ID,
	output [2:0] funct3_ID,
	output [6:0] funct7_ID,
	output logic [5:0] rs1_addr_ID,
	output logic [5:0] rs2_addr_ID,
	output logic [5:0] rd_addr_ID,
	output logic [31:0] imm_ID,
	output logic isWFI,
	output interrupt_re
	);

// Decode

// For debug propose
typedef enum logic [6:0]{
	Rtype  = 7'b0110011,
	Itype  = 7'b0010011,
	Load   = 7'b0000011,
	Store  = 7'b0100011,
	Branch = 7'b1100011,
	JALR   = 7'b1100111,
	JAL    = 7'b1101111,
	AUIPC  = 7'b0010111,
	LUI    = 7'b0110111,
	FLW    = 7'b0000111,
	FSW    = 7'b0100111,
	FALU   = 7'b1010011,
	CSR    = 7'b1110011
} opcode_t;

opcode_t opcode_t1;
assign opcode_t1 = opcode_t'(instr[6:0]);

assign opcode_ID = instr[6:0];
assign funct3_ID = instr[14:12];
assign funct7_ID = instr[31:25];

assign interrupt_re = (instr == 32'h3020_0073);

// Extend first bit to indicate register type for fowarding judgement.
always_comb begin 
	rs1_addr_ID = (opcode_ID==`FALU)? {1'b1, instr[19:15]} : {1'b0, instr[19:15]};
	rs2_addr_ID = (opcode_ID==`FSW || opcode_ID==`FALU)? {1'b1, instr[24:20]} : {1'b0, instr[24:20]};
	rd_addr_ID  = (opcode_ID==`FLW || opcode_ID==`FALU)? {1'b1, instr[11:7]} : {1'b0, instr[11:7]};
end

// Immediate generate
always_comb begin
	case(opcode_ID)
		`Itype,
		`Load, 
		`FLW,
		`JALR  : imm_ID = {{20{instr[31]}}, instr[31:20]};  // Notice shift command use "shamt"
		`FSW,
		`Store : imm_ID = {{20{instr[31]}}, instr[31:25], instr[11:7]};
		`Branch: imm_ID = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
		`AUIPC,
		`LUI   : imm_ID = {instr[31:12], 12'd0};
		`JAL   : imm_ID = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
		default: imm_ID = 32'd0; 
	endcase
end

logic keep;
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		isWFI <= 1'b0;
		keep <= 1'b1;
	end
	else begin
		if(instr==32'h1050_0073) begin  // WFI
			isWFI <= 1'b1;
			keep <= 1'b1;
		end
		else if(interrupt) begin  // mret || interrupt
			isWFI <= 1'b0;
			keep <= 1'b0;
		end
		else if(keep) begin
			isWFI <= isWFI;
		end
		else begin
			isWFI <= 1'b0;
		end
	end
end




endmodule