module ALU(
	input [3:0] alu_ctrl,
	input [1:0] mul_ctrl,
	input [31:0] mul_in1,
	input [31:0] mul_in2,
	input [31:0] src1,
	input [31:0] src2,
	output logic [31:0] alu_out,
	output logic [31:0] mul_out  
	);

// 10 Rtype instructions
always_comb begin
	case(alu_ctrl)
		4'b0000: alu_out = src1 + src2;          // ADD
		4'b1000: alu_out = src1 - src2;          // SUB
		4'b0001: alu_out = src1 << (src2[4:0]);  // SLL
		4'b0010: alu_out = ($signed(src1) < $signed(src2))? 1:0; // SLT
		4'b0011: alu_out = ($unsigned(src1) < $unsigned(src2))? 1:0; // SLTU
		4'b0100: alu_out = src1 ^ src2;          // XOR
		4'b0101: alu_out = src1 >> (src2[4:0]);  // SRL
		4'b1101: alu_out = ($signed(src1) >>> (src2[4:0]));  // SRA
		4'b0110: alu_out = src1 | src2;          // OR
		4'b0111: alu_out = src1 & src2;          // AND
		4'b1001: alu_out = src2;                 // LUI
		default: alu_out = src1 + src2;          
	endcase
end

// 4 mul instructions
logic [63:0] mul_out_tmp;
always_comb begin
	case(mul_ctrl)
		2'b00: mul_out_tmp = ({32'd0, mul_in1} * {32'd0, mul_in2});
		2'b01: mul_out_tmp = ({{32{mul_in1[31]}}, mul_in1} * {{32{mul_in2[31]}}, mul_in2});
		2'b10: mul_out_tmp = ({{32{mul_in1[31]}}, mul_in1} * {32'd0, mul_in2});
		2'b11: mul_out_tmp = ({32'd0, mul_in1} * {32'd0, mul_in2});
	endcase
end

always_comb begin
	case(mul_ctrl)
		2'b00: mul_out = mul_out_tmp[31:0];
		2'b01: mul_out = mul_out_tmp[63:32];
		2'b10: mul_out = mul_out_tmp[63:32];
		2'b11: mul_out = mul_out_tmp[63:32];
	endcase
end

endmodule