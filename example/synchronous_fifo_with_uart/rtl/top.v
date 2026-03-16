module top(input clk,
           input rst,
           input data_in,
           input debug_start,       //to start read opeartion
           output data_out,

           //signal to obersece by led's
           output sync_full,
           output sync_half_full,
           output sync_prog_full,
           output reg sync_almost_full
);

wire [7:0] rx_data;
wire byte_done;

parameter TB_DEPTH = 8;
parameter TB_DATA_WIDTH = 8;
parameter TB_PROG_EMPTY_VALUE = (TB_DEPTH/2) + 1;
parameter TB_PROG_FULL_VALUE = (TB_DEPTH/2) - 1;
parameter TB_MODE = 1;

rx uart_rx_inst (
    .i_Clock(clk),
    .i_Rx_Serial(data_in),
    .o_Rx_DV(byte_done),
    .o_Rx_Byte(rx_data)
);

wire [TB_DATA_WIDTH-1 :0]fifo_data_out;
wire [$clog2(TB_DEPTH): 0]sync_data_count;
wire sync_empty;
// wire sync_prog_full;
// wire sync_full;
// wire sync_half_full;
// wire sync_almost_full;
wire sync_prog_empty;
wire rst_busy;
wire sync_half_empty;
wire sync_almost_empty;
wire sync_overflow;
wire sync_underflow;
wire sync_wr_ack;
wire sync_rd_valid;

sync_fifo #(.DATA_WIDTH(TB_DATA_WIDTH), .DEPTH(TB_DEPTH), .PROG_FULL_VALUE(TB_PROG_FULL_VALUE), .PROG_EMPTY_VALUE(TB_PROG_EMPTY_VALUE), .MODE(TB_MODE)) fifo_inst (
    .clk(clk),
    .rst(rst),
    .r_en(sync_ren),
    .w_en(byte_done),
    .data_in(rx_data),
    .prog_full(sync_prog_full),
    .prog_empty(sync_prog_empty),
    .data_out(fifo_data_out),
    .full(sync_full),
    .empty(sync_empty),
    .rst_busy(rst_busy),
    .half_full(sync_half_full),
    .half_empty(sync_half_empty),
    .data_count(sync_data_count),
    .almost_full(sync_almost_full),                    
    .almost_empty(sync_almost_empty),
    .overflow(sync_overflow),
    .underflow(sync_underflow),
    .wr_ack(sync_wr_ack),
    .rd_valid(sync_rd_valid)
);

//extra
reg start;

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        start <= 1'b0;
    end
    else begin
        if (sync_data_count == TB_DEPTH && start == 1'b0) begin
            start <= 1'b1;
        end 
        end
end


wire tx_done;
wire tx_active;
wire sync_ren;

//---------------------------------------------------------------logic for Normal FWFT---------------------------------------------------------------
 assign sync_ren = !sync_empty && !tx_active && !tx_done && start;

uart_tx uart_tx_inst (
    .i_Clock(clk),
    .i_Tx_DV(sync_ren),
    .i_Tx_Byte(fifo_data_out),
    .o_Tx_Active(tx_active),
    .o_Tx_Serial(data_out),
    .o_Tx_Done(tx_done)
);

//---------------------------------------------------------------End of logic for Normal FWFT---------------------------------------------------------------


//---------------------------------------------------------------logic for FWFT---------------------------------------------------------------
/*
wire tx_start;
assign tx_start = !sync_empty && !tx_active && start && !tx_done;

assign sync_ren = tx_done;

uart_tx uart_tx_inst (
    .i_Clock(clk),
    .i_Tx_DV(tx_start),
    .i_Tx_Byte(fifo_data_out),
    .o_Tx_Active(tx_active),
    .o_Tx_Serial(data_out),
    .o_Tx_Done(tx_done)
);
*/
//---------------------------------------------------------------end of logic---------------------------------------------------------------

endmodule