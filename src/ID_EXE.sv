module ID_EXE(
	input clk, 
	input rst,
	input wb_en_ID,
	input [31:0] imm_wire,
	input [4:0] rd_addr,
	output logic wb_en_ex,
	output logic [4:0] rd_addr_ex,
	output logic [31:0] imm_ex
	);

always@(posedge clk or posedge rst) begin
	if(rst) begin
		rd_addr_ex <= 5'd0;
	end
	else begin
		rd_addr_ex <= rd_addr;
	end
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
		wb_en_ex <= 1'b0;
	end
	else begin
		wb_en_ex <= wb_en_ID;
	end
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
		imm_ex <= 32'd0;
	end
	else begin
		imm_ex <= imm_wire;
	end
end

endmodule