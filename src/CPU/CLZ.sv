module CLZ(Din, Dout);

input [31:0] Din;
output [4:0] Dout;

assign Dout[4] = (Din[31:16]!=16'd0);   // Leading "1" is in [31:16]
logic [15:0] data16;
assign data16 = (Dout[4])? Din[31:16]:Din[15:0];

assign Dout[3] = (data16[15:8]!=8'd0);
logic [7:0] data8;
assign data8 = (Dout[3])? data16[15:8]:data16[7:0];

assign Dout[2] = (data8[7:4]!=4'd0);
logic [3:0] data4;
assign data4 = (Dout[2])? data8[7:4]:data8[3:0];

assign Dout[1] = (data4[3:2]!=2'd0);
logic [1:0] data2;
assign data2 = (Dout[1])? data4[3:2]:data4[1:0];

assign Dout[0] = (data2[1]!=1'd0);

endmodule