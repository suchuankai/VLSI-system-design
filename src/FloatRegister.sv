module FloatRegister(
	input clk,
	input rst,
	input float_wb_en,
	input [4:0] float_wb_addr,
	input [31:0] float_write_data,
	input [4:0] float_rs1_addr,
	input [4:0] float_rs2_addr,
	output [31:0] float_rs1_data,
	output [31:0] float_rs2_data
	);

logic [31:0] floatReg[31:1];  // Save register 0 cost
integer i;

assign float_rs1_data = (float_rs1_addr==5'd0)? 32'd0 : floatReg[float_rs1_addr];
assign float_rs2_data = (float_rs2_addr==5'd0)? 32'd0 : floatReg[float_rs2_addr];

always@(posedge clk, posedge rst) begin
	if(rst) begin
		for(i=1; i<32; i=i+1) begin
			floatReg[i] <= 32'd0;
		end
	end
	else begin
		// Register Write
		if(float_wb_en && float_wb_addr!=5'd0) begin
			floatReg[float_wb_addr] <= float_write_data;
		end
	end
end

endmodule