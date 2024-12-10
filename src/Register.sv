module Register(
	input clk,
	input rst,
	input wb_en,
	input [4:0] wb_addr,
	input [31:0] write_data,
	input [4:0] rs1_addr,
	input [4:0] rs2_addr,
	output logic [31:0] rs1_data,
	output logic [31:0] rs2_data
	);

logic [31:0] register[31:1];  // Save register 0 cost
integer i;

always@(posedge clk, posedge rst) begin
	if(rst) begin
		for(i=1; i<32; i=i+1) begin
			register[i] <= 32'd0;
		end
		rs1_data <= 32'd0;
		rs2_data <= 32'd0;
	end
	else begin
		// Register Read
		rs1_data <= (rs1_addr==5'd0)? 32'd0 : register[rs1_addr];
		rs2_data <= (rs2_addr==5'd0)? 32'd0 : register[rs2_addr];

		// Register Write
		if(wb_en && wb_addr!=5'd0) begin
			register[wb_addr] <= write_data;
		end
	end
end

endmodule