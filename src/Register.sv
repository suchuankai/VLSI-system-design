module Register(
	input clk,
	input rst,
	input wb_en,
	input [5:0] wb_addr,
	input [31:0] write_data,
	input [5:0] rs1_addr,
	input [5:0] rs2_addr,
	output [31:0] rs1_data,
	output [31:0] rs2_data
	);

integer i;
logic [31:0] register[31:1];  // Save register[0] cost

assign rs1_data = (rs1_addr[4:0]==5'd0 || rs1_addr[5])? 32'd0 : register[rs1_addr[4:0]];
assign rs2_data = (rs2_addr[4:0]==5'd0 || rs2_addr[5])? 32'd0 : register[rs2_addr[4:0]];

always@(posedge clk, posedge rst) begin
	if(rst) begin
		for(i=1; i<32; i=i+1) begin
			register[i] <= 32'd0;
		end
	end
	else begin
		if(wb_en && wb_addr[4:0]!=5'd0 && !wb_addr[5]) begin
			register[wb_addr[4:0]] <= write_data;
		end
	end
end

endmodule