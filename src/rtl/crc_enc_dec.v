/*
 * This CRC module that uses crc polynomail to compute the remainder and data output for 
 * using the the input data and the lut values.  
 */
module crc_enc_dec #(parameter CRC_POLY_WIDTH = 32,
                     parameter DATA_IN_WIDTH = 192)
                    (input clk,
                     input rst, 
                     input enc_dec_mode_in,
                     input [DATA_IN_WIDTH - 1:0] data_in,
                     input load_data_in,
                     input lut_done_in,
                     input [CRC_POLY_WIDTH-1:0] lut_value_in,
                     input lut_value_ready_in,
                     output reg en_read_out,
                     output reg [7:0] lut_addr_out,
                     output reg [DATA_IN_WIDTH + CRC_POLY_WIDTH - 1: 0] enc_data_out,
                     output reg [DATA_IN_WIDTH - CRC_POLY_WIDTH - 1: 0] dec_data_out,
                     output reg [CRC_POLY_WIDTH - 1:0] remainder_out,
                     output reg enc_done_out,
                     output reg dec_done_out
                    );

    // Control Registers 
    reg load_shift_data_reg;
    reg shift_data;
    reg load_byte_reg;
    reg calc_addr_reg;
    reg clear_crc_reg; 
    reg calc_crc;
    reg calc_byte_counter;
    reg dec_byte_counter;


    // Registers
    reg [DATA_IN_WIDTH - 1:0] shift_data_reg;
    reg [7:0] byte_reg; 
    reg [4:0] byte_counter;
    reg [7:0] addr_reg;
    reg [CRC_POLY_WIDTH - 1:0] crc_reg;

    // State Names
    parameter S_IDLE = 0;
    parameter S_CALC_BYTE_COUNTER = 1;
    parameter S_LD_SHIFT_DATA_REG = 2;
    parameter S_LD_BYTE_REG = 3;
    parameter S_CALC_ADDR = 4;
    parameter S_RD_CRC_LUT = 5;
    parameter S_CALC_CRC = 6;
    parameter S_CHECK_BYTE_COUNTER = 7;
    parameter S_SHIFT_DATA_REG = 8;
    parameter S_CHECK_ENC_DEC = 9;
    parameter S_ENC = 10;
    parameter S_DEC = 11;

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

    // FSM for ENC/DEC
    always @(state, load_data_in) begin 

        {load_shift_data_reg,
         shift_data,
         load_byte_reg,
         clear_crc_reg,
         calc_addr_reg,
         calc_crc,
         calc_byte_counter,
         dec_byte_counter
        } <= 8'b0;

        {en_read_out,
         enc_done_out,
         dec_done_out
        } <= 3'b0;

        lut_addr_out <= 0; 
        enc_data_out <= 0;
        dec_data_out <= 0;
        remainder_out <= 0;
        enc_done_out <= 0;
        dec_done_out <= 0;

        case(state) 

            S_IDLE: begin
                if(load_data_in && lut_done_in) begin
                    next_state <= S_CALC_BYTE_COUNTER;
                end
                else begin
                    next_state <= S_IDLE;
                end
            end

            S_CALC_BYTE_COUNTER: begin
                next_state <= S_LD_SHIFT_DATA_REG;
                calc_byte_counter <= 1;

            end

            S_LD_SHIFT_DATA_REG: begin
                next_state <= S_LD_BYTE_REG;
                load_shift_data_reg <= 1;
            end

            S_LD_BYTE_REG: begin
                next_state <= S_CALC_ADDR;
                load_byte_reg <= 1;
            end

            S_CALC_ADDR: begin
                next_state <= S_RD_CRC_LUT;
                calc_addr_reg <= 1;
            end

            S_RD_CRC_LUT: begin
                next_state <= S_CALC_CRC;
                lut_addr_out <= addr_reg;
                en_read_out <= 1;
            end

            S_CALC_CRC: begin
                if(lut_value_ready_in) begin
                    next_state <= S_CHECK_BYTE_COUNTER;
                    calc_crc <= 1;
                end
                else begin
                    next_state <= S_CALC_CRC;
                end
            end

            S_CHECK_BYTE_COUNTER: begin
                if(byte_counter != 1) begin
                    next_state <= S_SHIFT_DATA_REG;
                end
                else begin
                    next_state <= S_CHECK_ENC_DEC;
                end
            end

            S_SHIFT_DATA_REG: begin
                next_state <= S_LD_BYTE_REG;
                shift_data <= 1;
                dec_byte_counter <= 1;
            end

            S_CHECK_ENC_DEC: begin
                if(enc_dec_mode_in) begin
                    next_state <= S_ENC;
                end
                else begin
                    next_state <= S_DEC;
                end
            end

            S_ENC: begin
                if(load_data_in) begin
                    next_state <= S_CALC_BYTE_COUNTER;
                    clear_crc_reg <= 1; 
                end
                else begin
                    next_state <= S_ENC;
                end

                enc_data_out <= {data_in, crc_reg};
                remainder_out <= crc_reg;
                enc_done_out <= 1;
            end

            S_DEC: begin
                if(load_data_in) begin
                    next_state <= S_CALC_BYTE_COUNTER;
                    clear_crc_reg <= 1; 
                end
                else begin
                    next_state <= S_DEC;
                end

                dec_data_out <= (data_in >> CRC_POLY_WIDTH);
                remainder_out <= crc_reg;
                dec_done_out <= 1;
            end

        endcase

    end

    // always block for shift_data_reg
    always@(posedge clk, posedge rst)begin
        if(rst)begin
            shift_data_reg <= 0;
        end
        else if (load_shift_data_reg)begin
            shift_data_reg <= data_in;
        end
        else if (shift_data)begin
            shift_data_reg <= shift_data_reg << 8;
        end
    end

    // always block for byte_reg
    always@(posedge clk, posedge rst) begin
        if(rst)begin
            byte_reg <= 0;
        end
        else if (load_byte_reg) begin
            byte_reg <= shift_data_reg [DATA_IN_WIDTH - 1: DATA_IN_WIDTH - 8]; 
        end
    end

    // always block for position -- addr_reg
    always@(posedge clk, posedge rst) begin
        if(rst)begin
            addr_reg <= 0;
        end
        else if (calc_addr_reg)begin
            addr_reg <= (crc_reg >> (CRC_POLY_WIDTH - 8)) ^ byte_reg;
        end
    end

    // always block crc_reg
    always@(posedge clk, posedge rst) begin
        if(rst)begin
            crc_reg <= 0;
        end
        else if(clear_crc_reg) begin 
            crc_reg <= 0;
        end 
        else if (calc_crc) begin
            crc_reg <= (crc_reg << 8) ^ lut_value_in;
        end
    end

    // always block for byte_counter
    always@(posedge clk, posedge rst) begin
        if(rst)begin
            byte_counter <= 0;
        end
        else if (calc_byte_counter)begin
            byte_counter <= (DATA_IN_WIDTH >> 3);
        end
        else if (dec_byte_counter)begin
            byte_counter <= byte_counter - 1;
        end
    end

endmodule
