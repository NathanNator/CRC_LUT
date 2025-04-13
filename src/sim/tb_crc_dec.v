/*
 * TB that checks the decoder mode. Used predefined LUT values and not Mem module.
 */
module tb_crc_dec ();

    parameter CRC_POLY_WIDTH = 16;
    parameter DATA_IN_WIDTH = 88; 

    reg clk;
    reg rst; 
    reg enc_dec_mode_in;
    reg [DATA_IN_WIDTH - 1:0] data_in;
    reg load_data_in;
    reg lut_done_in;
    reg [CRC_POLY_WIDTH-1:0] lut_value_in;
    reg lut_value_ready_in;

    wire en_read_out;
    wire [7:0] lut_addr_out;
    wire [DATA_IN_WIDTH - CRC_POLY_WIDTH - 1: 0] data_out;
    wire [CRC_POLY_WIDTH - 1:0] remainder_out;
    wire enc_done_out;
    wire dec_done_out;

    integer i;
    reg [CRC_POLY_WIDTH-1:0] lut [10:0];

    crc_enc_dec #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH), .DATA_IN_WIDTH(DATA_IN_WIDTH)) uut
                 (.clk(clk),
                  .rst(rst), 
                  .enc_dec_mode_in(enc_dec_mode_in),
                  .data_in(data_in),
                  .load_data_in(load_data_in),
                  .lut_done_in(lut_done_in),
                  .lut_value_in(lut_value_in),
                  .lut_value_ready_in(lut_value_ready_in),
                  .en_read_out(en_read_out),
                  .lut_addr_out(lut_addr_out),
                  .enc_data_out(),
                  .dec_data_out(data_out),
                  .remainder_out(remainder_out),
                  .enc_done_out(enc_done_out),
                  .dec_done_out(dec_done_out)
                 );

    initial begin
        
        lut [0] = 16'h2672;
        lut [1] = 16'h52B5;
        lut [2] = 16'h2252;
        lut [3] = 16'h8589;
        lut [4] = 16'hDD6C;
        lut [5] = 16'h4CE4;
        lut [6] = 16'h62D6;
        lut [7] = 16'h4615;
        lut [8] = 16'h24C3;
        lut [9] = 16'h0000;
        lut [10] = 16'h0000;

        data_in = 0;
        load_data_in = 0;
        rst = 1;
        clk = 0;

        @(posedge clk) begin
            rst = 0;
        end

        @(posedge clk) begin
            data_in = 88'h31323334353637383931C3;
        end
        
        @(posedge clk) begin
            lut_done_in = 1; 
            load_data_in = 1;
            enc_dec_mode_in = 0;
        end

        @(posedge clk) begin
            load_data_in = 0;
        end

        for (i = 0; i < 11; i = i + 1) begin
            
            @(posedge clk) begin
                lut_value_ready_in = 0;
            end

            @(uut.state == uut.S_RD_CRC_LUT) begin
                lut_value_in = lut[i];
                lut_value_ready_in = 1;
                #1; $display("addr_reg: %d", uut.addr_reg);
            end
            
            @(posedge clk);
        end
        
        @(posedge dec_done_out)begin
            #1; $display("data_out: %h, remainder_out: %h", data_out, remainder_out);
            if((remainder_out != 0) || (data_out != 72'h313233343536373839))begin
                #1; $display("tb_crc_dec FAILING"); $stop;
            end
            else begin
                #1; $display("tb_crc_dec PASSING"); $stop;
            end
        end
        
    end

    always #20 clk = ~clk;

endmodule