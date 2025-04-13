/*
 * This module compute all possible CRC LUT values based upon the CRC polynomial. 
 * All possible values are comuted using FSM.
 */
module crc_compute_lut_values #(parameter CRC_POLY_WIDTH = 32)
                               (input clk, 
                                input rst, 
                                input load_crc_poly_in, 
                                input [CRC_POLY_WIDTH - 1:0] crc_poly_in,
                                output reg [7:0] crc_addr_out,
                                output reg [CRC_POLY_WIDTH - 1:0] crc_lut_value_out,
                                output reg crc_lut_value_ready_out,
                                output reg crc_lut_done_out
                               );

   // Control Registers 
   reg  load_curr_byte; 
   reg 	clear_poly_data_reg; 
   reg  clear_curr_byte; 
   reg 	clear_bit_counter; 
   reg  clear_index_counter; 
   reg  inc_index_counter; 
   reg 	inc_bit_counter;
   reg  shift_by_one;
   reg  xor_poly; 

   // Registers 
   reg [7:0] index_counter;
   reg [CRC_POLY_WIDTH - 1:0] curr_byte, crc_poly_data_reg;
   reg [4:0] bit_counter;

   // State Names 
   parameter S_IDLE = 0;  
   parameter S_SET_INIT_CURR_BYTE = 1; 
   parameter S_CHECK_MSB = 2; 
   parameter S_MSB_HIGH_SHIFT = 3;  
   parameter S_MSB_HIGH_XOR = 4;  
   parameter S_MSB_LOW_SHIFT = 5;  
   parameter S_CHECK_BIT_CNT_STATE = 6; 
   parameter S_CHECK_INDEX_CNT = 7;  
   parameter S_DONE_LUT = 8;  
   
   reg [3:0] state;  
   reg [3:0] next_state; 

   // FSM Transmit Controller 
   always @(posedge clk, posedge rst) begin 
      if(rst) begin 
         state <= S_IDLE; 
      end 
      else begin  
         state <= next_state;
      end  
   end 

   // FSM Moore Machine 
   always @(state, load_crc_poly_in) begin 
    
    {load_curr_byte, 
     clear_poly_data_reg, 
     clear_curr_byte,
     clear_bit_counter,
     clear_index_counter, 
     inc_index_counter, 
     inc_bit_counter,
     shift_by_one,
     xor_poly
    } <= 9'b0; 

    case (state)
        
        S_IDLE: begin
        
            if(load_crc_poly_in) begin 
                next_state <= S_SET_INIT_CURR_BYTE;  
                clear_poly_data_reg <= 0;
            end 
            else begin 
                next_state <= S_IDLE;
                clear_poly_data_reg <= 1;
            end 
       
            clear_curr_byte <= 1;
            clear_bit_counter <= 1; 
            clear_index_counter <= 1;

            crc_addr_out <= 0;  
            crc_lut_value_out <= 0; 
            crc_lut_value_ready_out <= 0; 
            crc_lut_done_out <= 0; 
       
        end 

        S_SET_INIT_CURR_BYTE: begin 
            
            next_state <= S_CHECK_MSB;

            load_curr_byte <= 1; 

            crc_addr_out <= 0;  
            crc_lut_value_out <= 0; 
            crc_lut_value_ready_out <= 0; 
            crc_lut_done_out <= 0; 

        end 

        S_CHECK_MSB: begin  

            if(curr_byte[CRC_POLY_WIDTH - 1] == 1'b1) begin 
                next_state <= S_MSB_HIGH_SHIFT;  
            end 
            else begin 
                next_state <= S_MSB_LOW_SHIFT;
            end 

            crc_addr_out <= 0;  
            crc_lut_value_out <= 0; 
            crc_lut_value_ready_out <= 0; 
            crc_lut_done_out <= 0; 

        end 

        S_MSB_HIGH_SHIFT: begin  
            
            next_state <= S_MSB_HIGH_XOR;  
       
            shift_by_one <= 1; 

            crc_addr_out <= 0;  
            crc_lut_value_out <= 0; 
            crc_lut_value_ready_out <= 0; 
            crc_lut_done_out <= 0; 

        end 

        S_MSB_HIGH_XOR: begin  
            
            next_state <= S_CHECK_BIT_CNT_STATE; 

            xor_poly <= 1; 

            crc_addr_out <= 0;  
            crc_lut_value_out <= 0; 
            crc_lut_value_ready_out <= 0; 
            crc_lut_done_out <= 0;
       
        end 

        S_MSB_LOW_SHIFT: begin  
            
            next_state <= S_CHECK_BIT_CNT_STATE;  
       
            shift_by_one <= 1; 
       
            crc_addr_out <= 0;  
            crc_lut_value_out <= 0; 
            crc_lut_value_ready_out <= 0; 
            crc_lut_done_out <= 0; 
        end 

        S_CHECK_BIT_CNT_STATE: begin 

            if(bit_counter < 7) begin
                next_state <=  S_CHECK_MSB;  
            end 
            else begin 
                next_state <=  S_CHECK_INDEX_CNT; 
            end 

            inc_bit_counter <= 1;

            crc_addr_out <= 0;  
            crc_lut_value_out <= 0; 
            crc_lut_value_ready_out <= 0; 
            crc_lut_done_out <= 0; 

        end 

        S_CHECK_INDEX_CNT: begin  

            if(index_counter < 255) begin 
                next_state <=  S_SET_INIT_CURR_BYTE; 
                inc_index_counter <= 1; 
                clear_bit_counter <= 1; 
          
            end 
            else begin 
                next_state <=  S_DONE_LUT;
            end 

            crc_addr_out <= index_counter;  
            crc_lut_value_out <= curr_byte; 
            crc_lut_value_ready_out <= 1; 
            crc_lut_done_out <= 0; 

        end 

        S_DONE_LUT: begin  
       
            if(rst) begin 
                next_state <=  S_IDLE; 	
            end 
            else begin 
                next_state <=  S_DONE_LUT;
            end 
       
            crc_addr_out <= 0;  
            crc_lut_value_out <= 0; 
            crc_lut_value_ready_out <= 0; 
            crc_lut_done_out <= 1; 

        end 

    endcase 

   end 

    // Status Bit Count Register
    always@(posedge clk, posedge rst)begin 
      
        if(rst) begin
            bit_counter <= 0;
        end
      
        else if(clear_bit_counter) begin
            bit_counter <= 0;
        end

        else if(inc_bit_counter) begin
            bit_counter <= bit_counter + 1;
        end

    end

    // Status Index Counter Register
    always@(posedge clk, posedge rst)begin 
        
        if(rst) begin
            index_counter <= 0;
        end

        else if(clear_index_counter) begin
            index_counter <= 0;
        end
      
        else if(inc_index_counter) begin
            index_counter <= index_counter + 1;
        end

    end

    // curr_byte Register
    always@(posedge clk, posedge rst)begin 
      
        if(rst) begin
            curr_byte <= 0;
        end

        else if(clear_curr_byte) begin
            curr_byte <= 0; 
        end
      
        else if(load_curr_byte) begin
            curr_byte <= index_counter << (CRC_POLY_WIDTH - 8);
        end
      
        else if(shift_by_one) begin
            curr_byte <= curr_byte << 1;
        end
      
        else if (xor_poly)begin
            curr_byte <= curr_byte ^ crc_poly_data_reg;
        end
    end

    // crc Poly Data Register
    always@(posedge clk, posedge rst)begin 
      
        if(rst) begin
            crc_poly_data_reg <= 0; 
        end

        else if(clear_poly_data_reg) begin
            crc_poly_data_reg <= 0; 
        end 

        else if(load_crc_poly_in) begin
            crc_poly_data_reg <= crc_poly_in; 
        end 
    end

endmodule
