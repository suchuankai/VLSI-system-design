module MEM_WB(
	input clk, 
	input rst,
	input [1:0] busStall,
	input wb_en_MEM,
	input fwb_en_MEM,
	input [2:0] is_load_MEM,
	input [5:0] rd_addr_MEM,
	input [31:0] alu_out_MEM,
	input [31:0] DM_OUT,
	output logic wb_en_WB,
	output logic fwb_en_WB,
	output logic [5:0] rd_addr_WB,
	output logic [31:0] alu_out_WB
	);

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		rd_addr_WB <= 6'd0;
	end
	else begin
		if(busStall[1]) rd_addr_WB <= rd_addr_WB;
		else rd_addr_WB <= rd_addr_MEM;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		wb_en_WB <= 1'b0;
		fwb_en_WB <= 1'b0;
	end
	else begin
		if(busStall[1]) wb_en_WB <= wb_en_WB;
		else wb_en_WB <= wb_en_MEM;
		if(busStall[1]) fwb_en_WB <= fwb_en_WB;
		else fwb_en_WB <= fwb_en_MEM;
	end
end

logic [31:0] readBuffer;
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		readBuffer <= 32'd0;
	end
	else begin
		readBuffer <= DM_OUT;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		alu_out_WB <= 32'd0;
	end
	else begin
		if(busStall[1]) alu_out_WB <= alu_out_WB;
		else begin
			case(is_load_MEM)
				3'b000: alu_out_WB  <= alu_out_MEM;
				3'b001: alu_out_WB  <= {{24{readBuffer[7]}}, readBuffer[7:0]};   //LB
				3'b010: alu_out_WB  <= {{16{readBuffer[15]}}, readBuffer[15:0]}; //LH
				3'b011: alu_out_WB  <= readBuffer;                               //LW
				3'b100: alu_out_WB  <= {24'd0, readBuffer[7:0]};                 //LBU
				3'b101: alu_out_WB  <= {16'd0, readBuffer[15:0]};                //LHU
				default: alu_out_WB <= 32'd0;
			endcase
		end
	end
end

endmodule