/*
 * CRC module that is a memory storage. Saves the CRC lut values based upon
 * the lut value and address. 
 */
module crc_lut_mem #(parameter CRC_POLY_WIDTH = 32)
                    (input clk,
                     input rst,
                     input en_write_in, 
                     input en_read_in, 
                     input [7:0] addr_in,
                     input [CRC_POLY_WIDTH - 1:0] crc_lut_value_in,
                     input crc_lut_done_in,
                     output reg crc_lut_done_out,
                     output reg [CRC_POLY_WIDTH - 1:0] crc_lut_value_out,
                     output reg crc_lut_value_rd_out
                    );

   reg [CRC_POLY_WIDTH - 1:0] crc_table[255:0]; 
   
   always @(posedge clk, posedge rst) begin 
      if(rst) begin
	      crc_lut_value_out <= 0;
	      crc_lut_value_rd_out <= 0;
      end

      else if(en_write_in) begin
	      crc_table[addr_in] <= crc_lut_value_in;
	      crc_lut_value_rd_out <= 0;
      end

      else if (en_read_in) begin
	      crc_lut_value_out <= crc_table[addr_in];
         crc_lut_value_rd_out <= 1;
      end
      
      else if(~en_read_in) begin
         crc_lut_value_rd_out <= 0;
      end

    end 

   always@(posedge clk, posedge rst) begin
      if(rst) begin
	      crc_lut_done_out <= 0;
      end

      else if(crc_lut_done_in) begin 
	      crc_lut_done_out <= crc_lut_done_in; 
      end
      
   end

endmodule
