module WDT(
	input clk,
	input rst,
	input clk2,
	input rst2,
	input w_en,
	input [31:0] w_addr,
	input [31:0] w_data,
	output WTO
	);

logic WDEN;
logic WDLIVE;
logic [31:0] WTOCNT;

logic [31:0] counter;
assign WTO = (WDEN && counter==WTOCNT);

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		WDEN  <= 1'b0;
		WDLIVE <= 1'b0;
		WTOCNT <= 32'd0;
	end
	else begin
		if(w_en) begin
			if(w_addr==32'h1001_0100) WDEN <= w_data[0];
			else if(w_addr==32'h1001_0200) WDLIVE <= w_data[0];
			else if(w_addr==32'h1001_0300) WTOCNT <= w_data;
		end
	end
end

always_ff@(posedge clk2, posedge rst2) begin
	if(rst2) begin
		counter <= 32'd0;
	end
	else begin
		if(WDLIVE) counter <= 32'd0;
		else if(WDEN) counter <= (counter==WTOCNT)? counter : counter + 1;
		else counter <= 32'd0;
	end
end

endmodule