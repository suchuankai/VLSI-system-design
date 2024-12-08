module ALU(
	input alu_ctrl,
	input [31:0] src1,
	input [31:0] src2,
	output logic [31:0] alu_out 
	);

always_comb begin
	case(alu_ctrl)
		4'b0000: alu_out = src1 + src2;

	endcase
end



endmodule