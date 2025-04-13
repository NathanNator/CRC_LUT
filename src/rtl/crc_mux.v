/*
 * CRC module that uses crc acts as the mux to switch between lut values based upon 
 * when the CRC LUT DONE in. 
 */
module crc_mux (input clk,
                input [7:0] enc_dec_crc_addr_lut_in,
                input [7:0] compute_crc_addr_lut_in,
                input crc_lut_done_in,
                output reg [7:0] addr_out
               );


    always@(crc_lut_done_in or enc_dec_crc_addr_lut_in or compute_crc_addr_lut_in) begin
        if(crc_lut_done_in) begin
            addr_out <= enc_dec_crc_addr_lut_in;
        end
        else begin
            addr_out <= compute_crc_addr_lut_in;
        end
    end


endmodule