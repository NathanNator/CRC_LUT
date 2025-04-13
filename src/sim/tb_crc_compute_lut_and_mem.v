/*
 * TB that checks to see if all the possible lut values based upon the CRC polynomial 
 * are populating the memory.
 */
module tb_crc_compute_lut_and_mem (); 

    parameter CRC_POLY_WIDTH = 64;
    parameter DATA_IN_WIDTH = 144; 

    reg clk;
    reg rst; 
    reg load_crc_poly_in; 
    reg [CRC_POLY_WIDTH - 1:0] crc_poly_in;

    integer i;
    reg [CRC_POLY_WIDTH - 1:0] expected_crc_result;

    crc #(.CRC_POLY_WIDTH(CRC_POLY_WIDTH), .DATA_IN_WIDTH(DATA_IN_WIDTH)) dut  
         (.clk(clk),
          .rst(rst), 
          .load_crc_poly_in(load_crc_poly_in), 
          .crc_poly_in(crc_poly_in),
          .enc_dec_mode_in(),
          .load_data_in(),
          .data_in(),
          .crc_lut_done_out(),
          .enc_data_out(),
          .dec_data_out(),
          .remainder_out(),
          .enc_done_out(),
          .dec_done_out()
         );

    initial begin
        
        crc_poly_in = 0;
        rst = 1;
        clk = 0;
        load_crc_poly_in = 0;

        @(posedge clk);
        rst = 0;
        crc_poly_in = 64'h42F0E1EBA9EA3693; 

        @(posedge clk);
        load_crc_poly_in = 1;

        @(posedge clk);
        load_crc_poly_in = 0;

        @(posedge dut.crc_lut_done); 

        for(i = 0; i < 256; i = i + 1) begin 
            #1; expected_crc_result = crc_table_check(i, crc_poly_in);
            if(expected_crc_result != dut.crc_lut_mem.crc_table[i]) begin
                #1; $display("tb_crc_lut_mem FAILING"); 
                #1; $display("Failed at Index: %d, Expected CRC LUT value: %h, Actual CRC LUT value: %h", i, expected_crc_result, dut.crc_lut_mem.crc_table[i]); $stop; 
            end 
            
        end         

        $display("tb_crc_lut_mem PASSING");
        $stop; 

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