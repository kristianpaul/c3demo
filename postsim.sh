#!/bin/bash

set -ex
mode=icebox

case $mode in
	resynth)
		yosys -p '
			read_verilog c3demo.v
			read_verilog ledpanel.v
			read_verilog picorv32.v
			synth_ice40 -top c3demo
			write_verilog postsim.v
			write_ilang postsim.il
		' ;;
	blif)
		yosys c3demo.blif -o postsim.v ;;
	icebox)
		icebox_vlog -S -p c3demo.pcf -n c3demo -L c3demo.txt > postsim.v ;;
	*)
		exit 1 ;;
esac

iverilog -o testbench.exe testbench.v postsim.v \
	$(yosys-config --datdir/ice40/cells_sim.v --datdir/simlib.v)
vvp -N testbench.exe
