`include "CLZ.sv"

module FPU(
	input [31:0] FA,
	input [31:0] FB,
	input add_sub,
	output logic [31:0] fpu_out
	);

// Step1. Combine operator with FB
logic [31:0] src1, src2;
assign src1 = FA;
assign src2 = {FB[31]^add_sub, FB[30:0]};

// Step2. Compare and Swap 
logic A_S, B_S;
logic [7:0] A_E, B_E;
logic [22:0] A_F, B_F;
assign {A_S, A_E, A_F} = (src1[30:23] > src2[30:23])? src1 : src2;
assign {B_S, B_E, B_F} = (src1[30:23] > src2[30:23])? src2 : src1;

// Step3. Extend Fraction and Caculate exponential distance
logic [28:0] A_F_ext, B_F_ext, B_F_ext_tmp;
assign A_F_ext = {3'b001, A_F, 3'b000};   // Sign Carry 1 | guard round stick (add 6bit)
assign B_F_ext_tmp = {3'b001, B_F, 3'b000};
logic [4:0] exDiff;
assign exDiff = A_E - B_E;
assign B_F_ext = B_F_ext_tmp >> exDiff;

// Step4. Change all fraction data positive
logic [28:0] PA_F_ext, PB_F_ext;
assign PA_F_ext = (A_S)? ~A_F_ext + 29'd1 : A_F_ext;
assign PB_F_ext = (A_S)? ~B_F_ext + 29'd1 : B_F_ext;

// Step5. Add two number
logic [28:0] F_sum, F_out;
logic [25:0] F_round;
assign F_sum = PA_F_ext + PB_F_ext;
assign F_out = (F_sum[28])? ~F_sum + 29'd1 : F_sum;
always_comb begin
	if(F_out[2:1]==2'b11) F_round = F_out[28:3] + 29'd1;
	else if(F_out[2:1]==2'b01) F_round = F_out[28:3] + F_out[3];  // Add LSB
	else F_round = F_out[28:3];
end

logic [4:0] shift;
CLZ CLZ_0(.Din({8'd0, F_round[22:0]}), .Dout(shift));

// Step6. Normalized
assign fpu_out[31] = F_sum[28];
assign fpu_out[30:23] = (F_sum[27])? A_E+8'd1 : A_E - (5'd23-shift);
assign fpu_out[22:0] = (F_sum[27])? F_round[23:1] : F_round[22:0] << (5'd23-shift);

endmodule