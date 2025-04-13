/* 
 * TB that checks CRC correctness for encoder after populated mem module and only
 * changing the data input. 
 */
module tb_crc_top();

    parameter CRC_POLY_WIDTH = 32;
    parameter DATA_IN_WIDTH = 72; 

    reg clk;
    reg rst; 
    reg load_crc_poly_in; 
    reg [CRC_POLY_WIDTH - 1:0] crc_poly_in;
    reg enc_dec_mode_in;
    reg [DATA_IN_WIDTH - 1:0] data_in;
    reg load_data_in;

    wire crc_lut_done_out; 
    wire [DATA_IN_WIDTH + CRC_POLY_WIDTH - 1:0] data_out;
    wire [CRC_POLY_WIDTH - 1:0] remainder_out;
    wire enc_done_out;
    wire dec_done_out;

    integer i;
    reg [CRC_POLY_WIDTH - 1:0] expected_crc_result;

    crc #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH),
          .DATA_IN_WIDTH(DATA_IN_WIDTH)) dut 
         (.clk(clk),
          .rst(rst), 
          .load_crc_poly_in(load_crc_poly_in), 
          .crc_poly_in(crc_poly_in),
          .enc_dec_mode_in(enc_dec_mode_in),
          .data_in(data_in),
          .crc_lut_done_out(crc_lut_done_out),
          .load_data_in(load_data_in),
          .enc_data_out(data_out),
          .dec_data_out(),
          .remainder_out(remainder_out),
          .enc_done_out(enc_done_out),
          .dec_done_out(dec_done_out)
         );

    initial begin

        crc_poly_in = 0;
        rst = 1;
        clk = 0;
        load_crc_poly_in = 0;
        load_data_in = 0; 
        enc_dec_mode_in = 1;

        @(posedge clk) begin 
            rst = 0;
            crc_poly_in = 32'hBA137F9E; 
            load_crc_poly_in = 1;
        end 

        @(posedge clk) begin 
            load_crc_poly_in = 0;
        end 

        @(posedge crc_lut_done_out); 

        @(posedge clk) begin
            data_in = 72'h313233343536373839;
            load_data_in = 1;
        end

        @(posedge clk) begin
            load_data_in = 0;
        end

        @(posedge enc_done_out)begin
            #1; $display("data_out: %h, remainder_out: %h", data_out, remainder_out);
            if((remainder_out != 32'h24a18a26) || (data_out != 104'h31323334353637383924a18a26))begin
                #1; $display("tb_crc FAILING"); 
            end
            else begin
                #1; $display("tb_crc PASSING"); 
            end
        end

        @(posedge clk) begin
            data_in = 72'h414243444546474849;
            load_data_in = 1;
        end

        @(posedge clk) begin
            load_data_in = 0;
        end

        @(posedge enc_done_out)begin
            #1; $display("data_out: %h, remainder_out: %h", data_out, remainder_out);
            if((remainder_out != 32'h903A9698) || (data_out != 104'h414243444546474849903A9698))begin
                #1; $display("tb_crc FAILING"); 
            end
            else begin
                #1; $display("tb_crc PASSING"); 
            end
        end


        crc_poly_in = 0;
        rst = 1;
        load_crc_poly_in = 0;
        load_data_in = 0; 
        enc_dec_mode_in = 1;

        @(posedge clk) begin 
            rst = 0;
            crc_poly_in = 32'hDEADBEEF; 
            load_crc_poly_in = 1;
        end 

        @(posedge clk) begin 
            load_crc_poly_in = 0;
        end 

        @(posedge crc_lut_done_out); 

        @(posedge clk) begin
            data_in = 72'h313233343536373839;
            load_data_in = 1;
        end

        @(posedge clk) begin
            load_data_in = 0;
        end

        @(posedge enc_done_out)begin
            #1; $display("data_out: %h, remainder_out: %h", data_out, remainder_out);
            if((remainder_out != 32'hF9895947) || (data_out != 104'h313233343536373839F9895947))begin
                #1; $display("tb_crc FAILING"); 
            end
            else begin
                #1; $display("tb_crc PASSING"); 
            end
        end

        $stop; 

    end

    always #20 clk = ~clk;

endmodule