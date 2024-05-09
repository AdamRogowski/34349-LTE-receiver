quit -sim

vsim -t ns main_tb
# INPUTS
add wave clk
add wave rst
add wave -radix Sfixed data_in
add wave -radix Sfixed data_out
add wave -radix Sfixed out_arr
add wave ena
add wave evm
add wave out_rdy
run 10 us