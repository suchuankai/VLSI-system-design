module ID_EXE(
	input clk, 
	input rst,
	input [31:0] pc_ID,
	input [31:0] imm_wire,
	input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input [4:0] rd_addr_wb,
    input wb_en_wb,
    input [31:0] alu_out_wb,
	input [4:0] rd_addr,
	input [31:0] rs1_data,
	input [31:0] rs2_data,
	output logic [31:0] pc_EX, 
	output logic [4:0] rd_addr_ex,
	output logic [31:0] rs1_data_reg,
	output logic [31:0] rs2_data_reg,
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
		imm_ex <= 32'd0;
	end
	else begin
		imm_ex <= imm_wire;
	end
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
		rs1_data_reg <= 32'd0;
	end
	else begin
		rs1_data_reg <= ((rs1_addr==rd_addr_wb && rd_addr_wb!=5'd0 && wb_en_wb))? alu_out_wb : rs1_data;
	end
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
		rs2_data_reg <= 32'd0;
	end
	else begin
		rs2_data_reg <= (rs2_addr==rd_addr_wb && rd_addr_wb!=5'd0 && wb_en_wb)? alu_out_wb : rs2_data;
	end
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
		pc_EX <= 32'd0;
	end
	else begin
		pc_EX <= pc_ID;
	end
end

endmodule