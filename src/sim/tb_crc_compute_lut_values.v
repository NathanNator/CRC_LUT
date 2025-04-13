/*
 * TB that checks correctness of computing all the CRC LUT values. 
 */
module tb_crc_compute_lut_values ();

    parameter CRC_POLY_WIDTH = 64;

    reg  clk;
    reg  rst; 
    reg  load_crc_poly_in; 
    reg  [CRC_POLY_WIDTH - 1:0] crc_poly_in;
    wire [7:0] crc_addr_out;
    wire [CRC_POLY_WIDTH - 1:0] crc_lut_value_out;
    wire crc_lut_value_ready_out;
    wire crc_lut_done_out;

    integer i;
    reg [CRC_POLY_WIDTH - 1:0] expected_crc_result;

    crc_compute_lut_values #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH)) uut 
                            (.clk(clk), 
                             .rst(rst),
                             .crc_poly_in(crc_poly_in), 
                             .load_crc_poly_in(load_crc_poly_in),  
                             .crc_addr_out(crc_addr_out),
                             .crc_lut_value_out(crc_lut_value_out),
                             .crc_lut_value_ready_out(crc_lut_value_ready_out),
                             .crc_lut_done_out(crc_lut_done_out)
                            );

    initial begin

        crc_poly_in = 0;
        rst = 1;
        clk = 0;
        load_crc_poly_in = 0;

        @(posedge clk) begin 
            rst = 0;
            crc_poly_in = 64'h42F0E1EBA9EA3693; 
        end 

        @(posedge clk) begin
            load_crc_poly_in = 1;
        end 

        @(posedge clk) begin 
            load_crc_poly_in = 0;
        end 

        for(i = 0; i < 256; i = i + 1) begin

            #1; expected_crc_result = crc_table_check(i, crc_poly_in);
            @(posedge crc_lut_value_ready_out);
            @(negedge clk);

            if ((crc_lut_value_out != expected_crc_result) || (crc_lut_value_ready_out != 1) || (crc_lut_done_out == 1)) begin
                #1; $display("tb_compute_crc_lut_values FAILING");
                #1; $display("Expected value: %h, crc_lut_value_out: %h, crc_lut_value_ready_out: %b, crc_lut_done_out: %b", expected_crc_result, crc_lut_value_out, crc_lut_value_ready_out, crc_lut_done_out); $stop;
            end

            @(posedge clk);
        end

        @(posedge crc_lut_done_out);
        if((crc_lut_value_out != 0) || (crc_lut_value_ready_out != 0))begin
            #1; $display("tb_compute_crc_lut_values FAILING");
            #1; $display("Expected value: %h, crc_lut_value_out: %h, crc_lut_value_ready_out: %b, crc_lut_done_out: %b", expected_crc_result, crc_lut_value_out, crc_lut_value_ready_out, crc_lut_done_out); $stop;
        end

        @(posedge clk);
        #1; $display("tb_compute_crc_lut_values PASSING"); $stop;

end

    function automatic [CRC_POLY_WIDTH-1:0] crc_table_check (input[7:0] index, input [CRC_POLY_WIDTH - 1:0] crc_poly_in);

        reg [3:0] bit; 

        reg [CRC_POLY_WIDTH-1:0] curr_byte;

        begin 

            curr_byte = (index << (CRC_POLY_WIDTH - 8));

            for(bit = 0; bit < 8; bit = bit + 1) begin 
                
                if(curr_byte[CRC_POLY_WIDTH - 1] == 1'b1) begin 
                    curr_byte = curr_byte << 1;
                    curr_byte = curr_byte ^ crc_poly_in;
                end 
                else begin
                    curr_byte = curr_byte << 1;
                end 

            end   

            crc_table_check = curr_byte;

        end 

    endfunction 

always #20 clk = ~clk;

endmodule
