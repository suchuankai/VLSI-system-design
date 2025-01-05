`include "define.svh"

module CSR(
	input clk, 
	input rst,
	input [1:0] pc_sel,
	input [31:0] instr,
	output logic isCSR,
	output logic [31:0] CSR_out
	);

logic [6:0] opcode;
logic [10:0] imm12;
logic [1:0] csr_sel;
logic [63:0] cycleCnt, instretCnt;

assign opcode = instr[6:0];
assign imm12 = instr[31:20]; 
assign csr_sel = {imm12[7], imm12[1]};

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		isCSR <= 1'b0;
	end
	else begin
		isCSR <= (opcode==`CSR)? 1'b1 : 1'b0;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		cycleCnt <= 64'd0;
	end
	else begin
		cycleCnt <= cycleCnt + 64'd1;
	end
end 

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		instretCnt <= 64'd0;
	end
	else begin
		if(cycleCnt!=64'd0) begin
			case(pc_sel)
				2'b00: instretCnt <= instretCnt + 64'd1;  // Normal case
				2'b01: instretCnt <= instretCnt - 64'd1;  // Flush 2 instructions 
				2'b10: instretCnt <= instretCnt;          // Stall(Load use)
			endcase
		end
	end
end 

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		CSR_out <= 32'd0;
	end
	else begin 
		if(opcode==`CSR) begin
			case(csr_sel)
				2'b00: CSR_out <= cycleCnt[31:0];    // RDCYCLE
				2'b01: CSR_out <= instretCnt[31:0];  // RDINSTRET
				2'b10: CSR_out <= cycleCnt[63:32];   // RDCYCLEH
				2'b11: CSR_out <= instretCnt[63:32]; // RDINSTRETH
			endcase
		end
		else CSR_out <= 32'd0;
	end
end

endmodule