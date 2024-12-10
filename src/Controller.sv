`include "define.svh"

module Controller(
	input clk, 
	input rst,
	input [6:0] opcode,
	input [2:0] funct3,
	input [6:0] funct7,
	output logic mux3_sel,   // Select the src1 2nd stage mux before ALU 
	output logic mux4_sel,   // Select the src2 2nd stage mux before ALU 
	output logic [3:0] alu_ctrl,
	output logic DM_WEB,
	output logic [31:0] DM_BWEB,
	output logic wb_en
	);


// alu_ctrl signal needs opcode, func3, func7 to define
always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		alu_ctrl <= 4'b0000;
	end
	else begin
		case(opcode)
			`Rtype: alu_ctrl <= {funct7[5], funct3};
			`Itype: alu_ctrl <= (funct3==3'b001 || funct3==3'b101)? {funct7[5], funct3} : {1'b0, funct3};
			`JAL, 
			`JALR,
			`Load,
			`Store,
			`Branch,
			`AUIPC:  alu_ctrl <= 4'b0000;
			`LUI:    alu_ctrl <= 4'b1001;
			default: alu_ctrl <= 4'b0000;
		endcase
	end
end

// ALU dataflow
always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		mux3_sel <= 1'b0;
	end
	else begin
		mux3_sel <= 1'b0;
	end
end

always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		mux4_sel <= 1'b1;
	end
	else begin
		mux4_sel <= (opcode==`Rtype)? 0:1;
	end
end

// DM Load/Store enable 
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		DM_WEB <= 1'b1;  // read
		DM_BWEB <= 32'd0;
	end
	else begin
		DM_WEB <= (opcode==`Store)? 0:1;
	end
end

// Write back control (Only branch instruction don't need write back)
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		wb_en <= 1'b0;
	end
	else begin
		wb_en <= (opcode==`Branch)? 0:1;
	end
end


endmodule
