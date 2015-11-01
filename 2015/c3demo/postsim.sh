#!/bin/bash
set -ex

if false; then
	yosys c3demo.blif -o postsim.v
fi

if true; then
	yosys -p '
		read_verilog c3demo.v
		read_verilog ledpanel.v
		read_verilog picorv32.v
		synth_ice40 -top c3demo
		write_verilog postsim.v
		write_ilang postsim.il
	'
fi


iverilog -o testbench.exe testbench.v postsim.v \
	$(yosys-config --datdir/ice40/cells_sim.v --datdir/simlib.v)
vvp -N testbench.exe
