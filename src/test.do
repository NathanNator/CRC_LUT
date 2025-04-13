vlib work
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/crc.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/crc_compute_lut_values.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/crc_enc_dec.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/crc_lut_mem.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/crc_mux.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/prbs.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/tb_crc_compute_lut_and_mem.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/tb_crc_compute_lut_values.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/tb_crc_dec.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/tb_crc_enc.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/tb_crc_enc_dec.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/tb_crc_enc_to_dec_8.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/tb_crc_enc_to_dec_16.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/tb_crc_enc_to_dec_32.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/tb_crc_enc_to_dec_32_noise.v
vlog -reportprogress 300 -work work /home/u1089358/ECE6710_Project/CRC_Verilog/tb_crc_lut.v
vsim work.tb_crc_compute_lut_and_mem -voptargs=+acc
run -all
vsim -voptargs=+acc work.tb_crc_compute_lut_values
run -all
vsim -voptargs=+acc work.tb_crc_dec
run -all
vsim -voptargs=+acc work.tb_crc_enc
run -all
vsim -voptargs=+acc work.tb_crc_enc_dec
run -all
vsim -voptargs=+acc work.tb_crc_enc_to_dec_16
run -all
vsim -voptargs=+acc work.tb_crc_enc_to_dec_32
run -all
vsim -voptargs=+acc work.tb_crc_enc_to_dec_32_noise
run -all
vsim -voptargs=+acc work.tb_crc_enc_to_dec_8
run -all
vsim -voptargs=+acc work.tb_crc_lut
run -all
