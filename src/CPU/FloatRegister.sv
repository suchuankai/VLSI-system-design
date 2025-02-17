module FloatRegister(
	input clk,
	input rst,
	input [1:0] busStall,
	input fwb_en,
	input [5:0] fwb_addr,
	input [31:0] fwb_data,
	input [5:0] frs1_addr,
	input [5:0] frs2_addr,
	output [31:0] frs1_data,
	output [31:0] frs2_data
	);

logic [31:0] floatReg[31:1];
integer i;

assign frs1_data = (frs1_addr[4:0]==5'd0 || !frs1_addr[5])? 32'd0 : floatReg[frs1_addr[4:0]];  // MSB is 1 means need to read.
assign frs2_data = (frs2_addr[4:0]==5'd0 || !frs2_addr[5])? 32'd0 : floatReg[frs2_addr[4:0]];

always@(posedge clk, posedge rst) begin
	if(rst) begin
		for(i=1; i<32; i=i+1) begin
			floatReg[i] <= 32'd0;
		end
	end
	else begin
		// Register Write
		if(!busStall[1] && fwb_en && fwb_addr[4:0]!=5'd0 /*&& fwb_addr[5]*/) begin
			floatReg[fwb_addr[4:0]] <= fwb_data;
		end
	end
end

endmodule