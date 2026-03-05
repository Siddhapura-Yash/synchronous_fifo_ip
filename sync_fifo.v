module sync_fifo #(parameter DATA_WIDTH = 4, DEPTH = 4)
  				(input clk,
                 input rst,
                 input r_en,
                 input w_en,
                 input mode, // 0 for FWFT, 1 for mode
                 input [DATA_WIDTH - 1 : 0]data_in,
                 input [PTR_WIDTH:0]prog_full_value,
                 input [PTR_WIDTH:0]prog_empty_value,
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
  reg [DATA_WIDTH - 1 : 0] mem[0 : DEPTH - 1];

  localparam PTR_WIDTH  = $clog2(DEPTH);

   // Actual memory addresses
   wire [$clog2(DEPTH)-1:0] w_addr = w_ptr[$clog2(DEPTH)-1:0];
   wire [$clog2(DEPTH)-1:0] r_addr = r_ptr[$clog2(DEPTH)-1:0];
  
  //data count reg
  // reg [$clog2(DEPTH+1)-1:0] data_count;

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
/*
  //Read data
  always@(posedge clk) begin
    if (!rst) begin
      r_ptr <= 0;
      data_out <= 0;
      rd_valid <= 1'b0;
    end
    else begin
      rd_valid <= 1'b0;
      if(r_en && !empty) begin
        data_out <= mem[r_addr];
        r_ptr <= r_ptr + 1;
        rd_valid <= 1'b1;
      end
  	end
  end
*/
always @(posedge clk) begin
  if (!rst) begin
    r_ptr <= 0;
    data_out <= 0;
    rd_valid <= 1'b0;
  end 
  else begin
    rd_valid <= 1'b0;

    // STANDARD MODE
    if(mode) begin
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
  always @(*) begin
    data_count <= w_ptr - r_ptr;
  end
  /*
  //half full
  always@(posedge clk) begin
    if(!rst) begin
      half_full <= 1'b0;
    end
    else begin
      if(data_count >= DEPTH/2 - 1) begin
          half_full <= 1'b1;
      end
      else begin
          half_full <= 1'b0;
      end
    end
  end     */

/*
  //half empty
  always@(posedge clk) begin
    if(!rst) begin
        half_empty <= 1'b0;
    end
    else begin
      if(data_count <= DEPTH/2 + 1 && waste ) begin
          half_empty <= 1'b1;
      end
      else begin
          half_empty <= 1'b0;
      end
    end
  end         */
  
  /*
  //almost full
    always @(posedge clk or negedge rst) begin
    if (!rst)  begin
      almost_full <= 1'b0;
    end                  //----------------
    else begin
      almost_full <= 1'b0;
        if ((data_count >= DEPTH-2))begin
          almost_full <= 1'b1;
        end
    end
  end       */


/*
  //almost empty
    always @(posedge clk or negedge rst) begin
    if (!rst) begin
      almost_empty <= 1'b0;
    end
    else begin
      almost_empty <= 1'b0;
      if ((data_count == 1) && waste) begin
        almost_empty <= 1'b1;             //during writing opeartion we will get one pulse of almost empty signal
      end
    end
  end     */
/*
  //program full
    always @(posedge clk or negedge rst) begin
    if(!rst)begin
      prog_full <= 1'b0;
    end
    else begin
      if(data_count >= prog_full_value - 1) begin
        prog_full <= 1'b1;
      end
      else begin
        prog_full <= 1'b0;
      end
    end
    end         */

/*
  always@(posedge clk or negedge rst) begin
    if(!rst) begin
      prog_empty <= 1'b0;
    end
    else begin
      if(data_count <= prog_empty_value) begin
        prog_empty <= 1'b1;
      end
      else begin  
        prog_empty <= 1'b0;
      end
    end
  end         */

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
/*
//jugaaad to remove beginneing pulse 
reg waste;
always @(posedge clk or negedge rst) begin
  if(!rst) begin
    waste <= 1'b0;
  end
  else begin
    if(r_en && !empty && waste == 0) begin
      waste <= 1'b1;
    end
  end
end     */
/*
always @(posedge clk or negedge rst) begin
  if(!rst) begin
    empty <= 1'b1;
  end
  else begin
    empty <= rempty;
  end
end 
*/
/*
always @(posedge clk or negedge rst) begin
  if(!rst) begin
    full <= 1'b0;
  end
  else begin
    full <= (w_addr == r_addr) && (w_ptr[$clog2(DEPTH)] != r_ptr[$clog2(DEPTH)]);
  end
end   */




  // wire rempty;
  // assign rempty = (r_ptr == w_ptr);
  assign empty = (data_count == 0);

  assign almost_empty = (data_count == 1);
  assign prog_empty = (data_count <= prog_empty_value);
  assign half_full = (data_count >= DEPTH/2);
  assign prog_full = (data_count >= prog_full_value);
  assign almost_full = (data_count >= DEPTH-1);
  assign half_empty = (data_count <= DEPTH/2 );

  assign full = (data_count == DEPTH);
  assign rst_busy = !rst;

  // wire rfull;
  // assign full =  (w_addr == r_addr) && (w_ptr[$clog2(DEPTH)] != r_ptr[$clog2(DEPTH)]);


  // wire [$clog2(DEPTH) : 0]almost_full_reg = w_ptr + 1'b1;

  // assign almost_full = (w_addr+1'b1 == r_addr) && (almost_full_reg[$clog2(DEPTH)] != r_ptr[$clog2(DEPTH)]);
  // assign almost_empty = (r_ptr+1 == w_ptr);
  
endmodule      