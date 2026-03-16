module sync_fifo #(parameter DATA_WIDTH = 4, DEPTH = 4, PROG_FULL_VALUE = 3, PROG_EMPTY_VALUE = 1, MODE = 1)
  				(input clk,
                 input rst,
                 input r_en,
                 input w_en,
                 input [DATA_WIDTH - 1 : 0]data_in,
                 output reg [DATA_WIDTH - 1 : 0]data_out,
                 output reg full,
                 output empty,
                 output rst_busy,
                 output half_full,
                 output half_empty,
                 output reg [PTR_WIDTH:0] data_count,
                 output  almost_full,
                 output  almost_empty,
                 output prog_full,
                 output prog_empty,
                 output reg overflow,
                 output reg underflow,
                 output reg wr_ack,
                 output reg rd_valid);
  
  // One extra bit for wrap
  reg [$clog2(DEPTH) : 0] w_ptr,r_ptr;
  
  (* ram_style = "block" *)
  reg [DATA_WIDTH - 1 : 0] mem[0 : DEPTH - 1];

  localparam PTR_WIDTH  = $clog2(DEPTH);

   // Actual memory addresses
   wire [$clog2(DEPTH)-1:0] w_addr = w_ptr[$clog2(DEPTH)-1:0];
   wire [$clog2(DEPTH)-1:0] r_addr = r_ptr[$clog2(DEPTH)-1:0];

  //Write data
  always@(posedge clk) begin
    if(!rst) begin    
      w_ptr <= 0;
      wr_ack <= 1'b0;
    end
    else begin
      wr_ack <= 1'b0;
      if(w_en && !full) begin
        mem[w_addr] <= data_in;
        w_ptr <= w_ptr + 1;
        wr_ack <= 1'b1;
      end
 	 end
  end

always @(posedge clk) begin
  if (!rst) begin
    r_ptr <= 0;
    data_out <= 0;
    rd_valid <= 1'b0;
  end 
  else begin
    rd_valid <= 1'b0;

    // STANDARD MODE
    if(MODE) begin
      if(r_en && !empty) begin
        data_out <= mem[r_addr];
        r_ptr <= r_ptr + 1;
        rd_valid <= 1'b1;
      end
    end

    // FWFT MODE
    else begin
      if(!empty) begin
        data_out <= mem[r_addr];  // data always visible
        rd_valid <= 1'b1;
      end

      if(r_en && !empty) begin
        r_ptr <= r_ptr + 1;
      end
    end
  end
end

  //data count
  always @(posedge clk) begin
  if(!rst)
    data_count <= 0;
  else begin
    case({w_en && !full, r_en && !empty})
      2'b10: data_count <= data_count + 1;
      2'b01: data_count <= data_count - 1;
      default: data_count <= data_count;
    endcase
  end
end

  //overflow
  always@(posedge clk) begin
    if(!rst) begin
      overflow <= 1'b0;
    end
    else begin
      if(w_en && full) begin
        overflow <= 1'b1;
      end
      else begin
        overflow <= 1'b0;
      end
    end
  end

  //underflow
  always@(posedge clk) begin
    if(!rst) begin
      underflow <= 1'b0;
    end
    else begin
      if(r_en && empty) begin
        underflow <= 1'b1;
      end
      else begin
        underflow <= 1'b0;
      end
    end
  end       

  assign empty = (data_count == 0);

  assign almost_empty = (data_count <= 1);
  assign prog_empty = (data_count <= PROG_EMPTY_VALUE);
  assign half_full = (data_count >= DEPTH/2);
  assign prog_full = (data_count >= PROG_FULL_VALUE);
  assign almost_full = (data_count >= DEPTH-1);
  assign half_empty = (data_count <= DEPTH/2 );

  assign full = (data_count == DEPTH);
  assign rst_busy = !rst;
  
endmodule      
