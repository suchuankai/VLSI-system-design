module MEM_WB(
	input clk, 
	input rst,
	input wb_en_mem,
	input [4:0] rd_addr_mem,
	input [31:0] alu_out_mem,
	output logic wb_en_wb,
	output logic [4:0] rd_addr_wb,
	output logic [31:0] alu_out_wb
	);

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		rd_addr_wb <= 5'd0;
	end
	else begin
		rd_addr_wb <= rd_addr_mem;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		wb_en_wb <= 5'd0;
	end
	else begin
		wb_en_wb <= wb_en_mem;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		alu_out_wb <= 32'd0;
	end
	else begin
		alu_out_wb <= alu_out_mem;
	end
end


endmodule