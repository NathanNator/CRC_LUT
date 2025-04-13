/*
 * CRC module that uses crc polynomail to compute the remainder and data output for 
 * for encoder and decoder modes. 
 */
module crc #(parameter CRC_POLY_WIDTH = 32,
             parameter DATA_IN_WIDTH = 192)
            (input clk,
             input rst, 
             input load_crc_poly_in, 
             input [CRC_POLY_WIDTH - 1:0] crc_poly_in,
             input enc_dec_mode_in,
             input load_data_in,
             input [DATA_IN_WIDTH - 1:0] data_in,
             output wire crc_lut_done_out,
             output wire [DATA_IN_WIDTH + CRC_POLY_WIDTH - 1: 0] enc_data_out,
             output wire [DATA_IN_WIDTH - CRC_POLY_WIDTH - 1: 0] dec_data_out,
             output wire [CRC_POLY_WIDTH - 1:0] remainder_out,
             output wire enc_done_out, 
             output wire dec_done_out
            );

    // Compute CRC Values  
    wire [7:0] compute_crc_addr_lut; 
    wire [CRC_POLY_WIDTH - 1:0] compute_crc_lut_value;
    wire compute_crc_lut_value_ready; 
    wire compute_crc_lut_done;

    // CRC enc/dec 
    wire [7:0] enc_dec_crc_addr_lut; 
    wire crc_lut_done; 
    wire [CRC_POLY_WIDTH - 1:0] crc_lut_value; 
    wire lut_rd_out; 
    wire en_read;

    assign crc_lut_done_out = crc_lut_done; 

    // MUX 
    wire [7:0] addr_lut;

    crc_mux crc_mux(.clk(clk),
                    .enc_dec_crc_addr_lut_in(enc_dec_crc_addr_lut),
                    .compute_crc_addr_lut_in(compute_crc_addr_lut),
                    .crc_lut_done_in(crc_lut_done),
                    .addr_out(addr_lut)
                   );

    crc_compute_lut_values #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH)) crc_compute_lut_values
                            (.clk(clk),
                             .rst(rst), 
                             .load_crc_poly_in(load_crc_poly_in), 
                             .crc_poly_in(crc_poly_in),
                             .crc_addr_out(compute_crc_addr_lut),
                             .crc_lut_value_out(compute_crc_lut_value),
                             .crc_lut_value_ready_out(compute_crc_lut_value_ready),
                             .crc_lut_done_out(compute_crc_lut_done)
                            );

    crc_lut_mem #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH)) crc_lut_mem
                 (.clk(clk),
                  .rst(rst), 
                  .en_write_in(compute_crc_lut_value_ready), 
                  .en_read_in(en_read), 
                  .addr_in(addr_lut),
                  .crc_lut_value_in(compute_crc_lut_value),
                  .crc_lut_done_in(compute_crc_lut_done),
                  .crc_lut_done_out(crc_lut_done),
                  .crc_lut_value_out(crc_lut_value),
                  .crc_lut_value_rd_out(lut_rd_out)
                 );


    crc_enc_dec #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH), .DATA_IN_WIDTH(DATA_IN_WIDTH)) crc_enc_dec
                 (.clk(clk),
                  .rst(rst), 
                  .enc_dec_mode_in(enc_dec_mode_in),
                  .data_in(data_in),
                  .load_data_in(load_data_in),
                  .lut_done_in(crc_lut_done),
                  .lut_value_in(crc_lut_value),
                  .lut_value_ready_in(lut_rd_out),
                  .en_read_out(en_read),
                  .lut_addr_out(enc_dec_crc_addr_lut),
                  .enc_data_out(enc_data_out),
                  .dec_data_out(dec_data_out),
                  .remainder_out(remainder_out),
                  .enc_done_out(enc_done_out),
                  .dec_done_out(dec_done_out)
                 );


endmodule