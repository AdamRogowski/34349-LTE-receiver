quit -sim

vsim -t ns analyser_tb
# INPUTS
add wave clk
add wave rst
add wave ena
add wave -radix Sfixed data_in
add wave evm
run 10 us