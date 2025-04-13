/* 
 * TB that checks the correctness by passing the data out of encoder into the decoder, resuling
 * in a remainder out to be zero. This is done by using Random Number Generator and seeing if the 
 * results are the same on the output.
 */
module tb_crc_enc_to_dec_32();

    parameter CRC_POLY_WIDTH = 32;
    
    parameter DATA_IN_WIDTH_ENC = 160; 
    
    parameter DATA_IN_WIDTH_DEC = DATA_IN_WIDTH_ENC + CRC_POLY_WIDTH; 
    
    reg clk;
    reg rst; 
    reg load_crc_poly_in_enc; 
    reg load_crc_poly_in_dec; 
    
    reg [CRC_POLY_WIDTH - 1:0] crc_poly_in;
    
    reg [DATA_IN_WIDTH_ENC - 1:0] data_in_enc;
    reg load_data_in_enc;
    reg load_data_in_dec;

    wire crc_lut_done_out_enc; 
    wire crc_lut_done_out_dec;

    wire [DATA_IN_WIDTH_ENC + CRC_POLY_WIDTH - 1:0] data_out_enc;
    wire [DATA_IN_WIDTH_DEC - CRC_POLY_WIDTH - 1:0] data_out_dec;
    wire [CRC_POLY_WIDTH - 1:0] remainder_out_enc, remainder_out_dec;
    wire enc_done_out;
    wire dec_done_out;

    reg [CRC_POLY_WIDTH - 1:0] expected_crc_result;

    integer i;

    wire rand; 

    prbs pr (.clk(clk), .reset(rst), .rand(rand));

    crc #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH), .DATA_IN_WIDTH(DATA_IN_WIDTH_ENC)) CRC_ENC 
         (.clk(clk),
          .rst(rst), 
          .load_crc_poly_in(load_crc_poly_in_enc), 
          .crc_poly_in(crc_poly_in),
          .enc_dec_mode_in(1'b1),
          .data_in(data_in_enc),
          .crc_lut_done_out(crc_lut_done_out_enc),
          .load_data_in(load_data_in_enc),
          .enc_data_out(data_out_enc),
          .dec_data_out(),
          .remainder_out(remainder_out_enc),
          .enc_done_out(enc_done_out),
          .dec_done_out()
         );

    crc #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH), .DATA_IN_WIDTH(DATA_IN_WIDTH_DEC)) CRC_DEC
         (.clk(clk),
          .rst(rst), 
          .load_crc_poly_in(load_crc_poly_in_dec), 
          .crc_poly_in(crc_poly_in),
          .enc_dec_mode_in(1'b0),
          .data_in(data_out_enc),
          .crc_lut_done_out(crc_lut_done_out_dec),
          .load_data_in(load_data_in_dec),
          .enc_data_out(),
          .dec_data_out(data_out_dec),
          .remainder_out(remainder_out_dec),
          .enc_done_out(),
          .dec_done_out(dec_done_out)
         );

    initial begin
 
        rst = 1;
        clk = 0;
        load_crc_poly_in_enc = 0;
        load_data_in_enc = 0; 

        @(posedge clk) begin 
            rst = 0;
        end 

        for(i = 0; i < CRC_POLY_WIDTH; i = i + 1) begin 
            @(posedge clk) begin
                crc_poly_in[i] = rand;
            end
        end 

        @(posedge clk) begin 
            load_crc_poly_in_enc = 1;
        end 

        @(posedge clk) begin 
            load_crc_poly_in_enc = 0;
        end 

        @(posedge crc_lut_done_out_enc); 

        for(i = 0; i < DATA_IN_WIDTH_ENC; i = i + 1) begin 

            @(posedge clk) begin
                data_in_enc[i] = rand;
            end
        
        end 

        @(posedge clk) begin
            load_data_in_enc = 1;
        end

        @(posedge clk) begin
            load_data_in_enc = 0;
        end

        #1; $display("CRC Polynomial: %h", crc_poly_in);
        #1; $display("Data Input: %h", data_in_enc);

        @(posedge enc_done_out) begin
            #1; $display("ENCODER: data_out = %h, remainder_out = %h", data_out_enc, remainder_out_enc);
        end 

        load_crc_poly_in_dec = 0;
        load_data_in_dec = 0; 
      
        @(posedge clk) begin 
            load_crc_poly_in_dec = 1;
        end 

        @(posedge clk) begin 
            load_crc_poly_in_dec = 0;
        end 

        @(posedge crc_lut_done_out_dec); 

        @(posedge clk) begin
            load_data_in_dec = 1;
        end

        @(posedge clk) begin
            load_data_in_dec = 0;
        end

        @(posedge dec_done_out)begin
            #1; $display("DECODER: data_out = %h, remainder_out = %h", data_out_dec, remainder_out_dec);
        end

        if(remainder_out_dec == 0) begin 
             #1; $display("No errors in transmission");
        end 
        else begin   
            #1; $display("Errors Found in Transmission");
        end 

        $stop; 
        

    end

    always #20 clk = ~clk;

endmodule

