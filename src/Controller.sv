module Controller(
	input clk, 
	input rst,
	input [6:0] opcode,
	output logic mux3_sel,   // Select the src1 2nd stage mux before ALU 
	output logic mux4_sel,   // Select the src2 2nd stage mux before ALU 
	output logic [3:0] alu_ctrl
	);

always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
		alu_ctrl <= 4'b0000;
	end
	else begin
		case(opcode)
			7'b0110011: alu_ctrl <= 4'b0000;
			default: alu_ctrl <= 4'b0000;
		endcase
	end
end

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
		mux4_sel <= 1'b1;
	end
end

endmodule
