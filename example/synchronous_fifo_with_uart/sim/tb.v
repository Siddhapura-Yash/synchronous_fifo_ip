`timescale 1ns/1ps

module tb;

reg clk;
reg rst;
reg data_in;
reg debug_start;
wire data_out;

wire tb_sync_full;
wire tb_sync_half_full;
wire tb_sync_prog_full;
wire tb_sync_almost_full;

parameter CLKS_PER_BIT = 100;

top DUT(
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .debug_start(debug_start),
    .data_out(data_out),

    .sync_full(tb_sync_full),
    .sync_half_full(tb_sync_half_full),
    .sync_prog_full(tb_sync_prog_full),
    .sync_almost_full(tb_sync_almost_full)
);

initial clk = 0;
always #5 clk = ~clk;   //100MHz


initial begin
    rst = 0;
    data_in = 1;
    debug_start = 0;

    repeat(10) @(posedge clk);
    rst = 1;
    
    send_byte(8'hA0);
    send_byte(8'hB0);
    send_byte(8'hC0);
    send_byte(8'hD0);

    send_byte(8'hE0);
    send_byte(8'hF0);
    send_byte(8'hAA);
    send_byte(8'hBB);

    #200000;
    $finish;
end


task send_byte(input [7:0] data);
integer i;
begin

    data_in = 0;
    repeat(CLKS_PER_BIT) @(posedge clk);

    for(i=0;i<8;i=i+1)
    begin
        data_in = data[i];
        repeat(CLKS_PER_BIT) @(posedge clk);
    end

    data_in = 1;
    repeat(CLKS_PER_BIT) @(posedge clk);

end
endtask


initial begin
    $dumpfile("uart_loopback.vcd");
    $dumpvars(0,tb);
end

endmodule