/* 
 * TB that checks the correctness by passing the result of encoder into the decoder, resuling
 * in a remainder out to be zero. 
 */
module tb_crc_enc_dec ();

    reg clk;
    reg rst; 

    parameter CRC_POLY_WIDTH = 16;

    // Encoder Signals 
    parameter DATA_ENCODER_WIDTH = 72; 

    reg enc_mode_in;
    reg [DATA_ENCODER_WIDTH - 1:0] enc_data_in;
    reg enc_load_data_in;
    reg enc_lut_done_in;
    reg [CRC_POLY_WIDTH-1:0] enc_lut_value_in;
    reg enc_lut_value_ready_in;

    wire enc_en_read_out;
    wire [7:0] enc_lut_addr_out;
    wire [DATA_ENCODER_WIDTH + CRC_POLY_WIDTH - 1: 0] enc_data_out;
    wire [CRC_POLY_WIDTH - 1:0] enc_remainder_out;
    wire enc_done_out;

    reg [CRC_POLY_WIDTH-1:0] lut_enc [8:0];
    
    // Decoder Signals 
    parameter DATA_DECODER_WIDTH = 88; 

    reg dec_mode_in;
    reg [DATA_DECODER_WIDTH - 1:0] dec_data_in;
    reg dec_load_data_in;
    reg dec_lut_done_in;
    reg [CRC_POLY_WIDTH-1:0] dec_lut_value_in;
    reg dec_lut_value_ready_in;

    wire dec_en_read_out;
    wire [7:0] dec_lut_addr_out;
    wire [DATA_DECODER_WIDTH - CRC_POLY_WIDTH - 1: 0] dec_data_out;
    wire [CRC_POLY_WIDTH - 1:0] dec_remainder_out;
    wire dec_done_out;

    reg [CRC_POLY_WIDTH-1:0] lut_dec [10:0];

    integer i;

    crc_enc_dec #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH), .DATA_IN_WIDTH(DATA_ENCODER_WIDTH)) encoder_uut
                 (.clk(clk),
                  .rst(rst), 
                  .enc_dec_mode_in(enc_mode_in),
                  .data_in(enc_data_in),
                  .load_data_in(enc_load_data_in),
                  .lut_done_in(enc_lut_done_in),
                  .lut_value_in(enc_lut_value_in),
                  .lut_value_ready_in(enc_lut_value_ready_in),
                  .en_read_out(enc_en_read_out),
                  .lut_addr_out(enc_lut_addr_out),
                  .enc_data_out(enc_data_out),
                  .dec_data_out(),
                  .remainder_out(enc_remainder_out),
                  .enc_done_out(enc_done_out),
                  .dec_done_out()
                 );


    crc_enc_dec #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH), .DATA_IN_WIDTH(DATA_DECODER_WIDTH)) decoder_uut
                 (.clk(clk),
                  .rst(rst), 
                  .enc_dec_mode_in(dec_mode_in),
                  .data_in(enc_data_out),
                  .load_data_in(dec_load_data_in),
                  .lut_done_in(dec_lut_done_in),
                  .lut_value_in(dec_lut_value_in),
                  .lut_value_ready_in(dec_lut_value_ready_in),
                  .en_read_out(dec_en_read_out),
                  .lut_addr_out(dec_lut_addr_out),
                  .enc_data_out(),
                  .dec_data_out(dec_data_out),
                  .remainder_out(dec_remainder_out),
                  .enc_done_out(),
                  .dec_done_out(dec_done_out)
                 );    
 
    initial begin

        // Encoder 

        lut_enc [0] = 16'h2672;
        lut_enc [1] = 16'h52B5;
        lut_enc [2] = 16'h2252;
        lut_enc [3] = 16'h8589;
        lut_enc [4] = 16'hDD6C;
        lut_enc [5] = 16'h4CE4;
        lut_enc [6] = 16'h62D6;
        lut_enc [7] = 16'h4615;
        lut_enc [8] = 16'h24C3;

        enc_data_in = 0;
        enc_load_data_in = 0;
        rst = 1;
        clk = 0;

        @(posedge clk) begin
            rst = 0;
        end

        @(posedge clk) begin
            enc_data_in = 72'h313233343536373839;
        end
        
        @(posedge clk) begin
            enc_lut_done_in = 1; 
            enc_load_data_in = 1;
            enc_mode_in = 1;
        end

        @(posedge clk) begin
            enc_load_data_in = 0;
        end

        for (i = 0; i < 9; i = i + 1) begin
            
            @(posedge clk) begin
                enc_lut_value_ready_in = 0;
            end

            @(encoder_uut.state == encoder_uut.S_RD_CRC_LUT) begin
                enc_lut_value_in = lut_enc[i];
                enc_lut_value_ready_in = 1;
                // #1; $display("addr_reg: %d", encoder_uut.addr_reg);
            end
            
            @(posedge clk);
        end
        
        @(posedge enc_done_out)begin
            #1; $display("data_out: %h, remainder_out: %h", enc_data_out, enc_remainder_out);
            if((enc_remainder_out != 16'h31C3) || (enc_data_out != 88'h31323334353637383931C3))begin
                #1; $display("Encoder FAILING");
            end
            else begin
                #1; $display("Encoder PASSING"); 
            end
        end

        
        @(posedge clk);

        // Decoder 

        lut_dec [0] = 16'h2672;
        lut_dec [1] = 16'h52B5;
        lut_dec [2] = 16'h2252;
        lut_dec [3] = 16'h8589;
        lut_dec [4] = 16'hDD6C;
        lut_dec [5] = 16'h4CE4;
        lut_dec [6] = 16'h62D6;
        lut_dec [7] = 16'h4615;
        lut_dec [8] = 16'h24C3;
        lut_dec [9] = 16'h0000;
        lut_dec [10] = 16'h0000;

        @(posedge clk) begin 
            dec_data_in = 0;
            dec_load_data_in = 0;
        end 

        @(posedge clk) begin
            dec_lut_done_in = 1; 
            dec_load_data_in = 1;
            dec_mode_in = 0;
        end

        @(posedge clk) begin
            dec_load_data_in = 0;
        end

        for (i = 0; i < 11; i = i + 1) begin
            
            @(posedge clk) begin
                dec_lut_value_ready_in = 0;
            end

            @(decoder_uut.state == decoder_uut.S_RD_CRC_LUT) begin
                dec_lut_value_in = lut_dec[i];
                dec_lut_value_ready_in = 1;
                //#1; $display("addr_reg: %d", decoder_uut.addr_reg);
            end
            
            @(posedge clk);
        end
        
        @(posedge dec_done_out)begin
            #1; $display("data_out: %h, remainder_out: %h", dec_data_out, dec_remainder_out);
            if((dec_remainder_out != 0) || (dec_data_out != 72'h313233343536373839))begin
                #1; $display("Decoder FAILING"); 
            end
            else begin
                #1; $display("Decoder PASSING"); 
            end
        end   

        $stop; 
        
    end

    always #20 clk = ~clk;

endmodule