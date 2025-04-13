/* 
 * TB that checks populates the all 256 mem module. 
 */
module tb_crc_lut();

    parameter CRC_POLY_WIDTH = 8;
    
    reg  clk;
    reg  rst;
    reg  en_write_in; 
    reg  en_read_in;
    reg  [7:0] addr_in;
    reg  [CRC_POLY_WIDTH - 1:0] crc_lut_value_in;
    reg  crc_lut_done_in;
    wire crc_lut_done_out;
    wire [CRC_POLY_WIDTH - 1:0] crc_lut_value_out;
    wire crc_lut_value_rd_out;

    integer i;

    crc_lut_mem #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH)) uut 
                 (.clk(clk),
                  .rst(rst),
                  .en_write_in(en_write_in), 
                  .en_read_in(en_read_in),
                  .addr_in(addr_in),
                  .crc_lut_value_in(crc_lut_value_in),
                  .crc_lut_done_in(crc_lut_done_in),
                  .crc_lut_done_out(crc_lut_done_out),
                  .crc_lut_value_out(crc_lut_value_out),
                  .crc_lut_value_rd_out(crc_lut_value_rd_out)
                 );

    initial begin

        clk = 0;
        rst = 1;

        @(posedge clk); begin 
            rst = 0;
        end 
        @(posedge clk);

        for(i = 0; i < 256; i = i + 1) begin

            @(posedge clk);

            en_write_in = 1;
            addr_in = i;
            crc_lut_value_in = i;

            @(posedge clk);

            en_write_in = 0;

        end

        @(posedge clk) begin 
            #1; 
            crc_lut_done_in = 1; 
        end 

        @(posedge clk);
        @(posedge clk);

        for(i = 0; i < 256; i = i + 1) begin

            @(posedge clk)begin 
                en_read_in = 1;
                addr_in = i;
                crc_lut_value_in = i;
            end 

            @(posedge clk);
            @(posedge clk);
            
            if((crc_lut_value_out != crc_lut_value_in) || (crc_lut_value_rd_out != 1)) begin
                #1; $display("tb_crc_lut FAILING");
                #1; $display("crc_lut_value_in: %h, crc_lut_value_out: %h, crc_lut_value_rd_out: %b", crc_lut_value_in, crc_lut_value_out, crc_lut_value_rd_out); $stop;
            end

            @(posedge clk) begin 
                en_read_in = 0;
            end 
            
            @(posedge clk);

        end
        
        #1; $display("tb_crc_lut PASSING");
        $stop;

    end

    always #20 clk = ~clk;

endmodule
             