module Addr_decoder(
    input        [`AXI_ADDR_BITS-1:0] address,
    output logic [3:0] slaveID
);

always_comb begin
    if(address < 32'h0000_2000) slaveID = 4'd0;
    else if(address[31:16] == 16'h0001) slaveID = 4'd1;
    else if(address[31:16] == 16'h0002) slaveID = 4'd2;
    else if(address <= 32'h1002_0400 && address >= 32'h1002_0000) slaveID = 4'd3;
    else if(address <= 32'h1001_03FF && address >= 32'h1001_0000) slaveID = 4'd4;
    else if(address <= 32'h201F_FFFF && address >= 32'h2000_0000) slaveID = 4'd5;
    else slaveID = 4'd6;
end

endmodule
