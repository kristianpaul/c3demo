#!/bin/bash

set -ex
bash firmware.sh nopush

if false; then
	iverilog -o testbench.exe -s testbench testbench.v \
			c3demo.v ledpanel.v picorv32.v \
			$(yosys-config --datdir/ice40/cells_sim.v)
else
	yosys -l synth.log -p 'synth_ice40 -top c3demo' -o synth.v \
			c3demo.v ledpanel.v picorv32.v
	iverilog -o testbench.exe -s testbench testbench.v synth.v \
			$(yosys-config --datdir/ice40/cells_sim.v --datdir/simlib.v)
fi

chmod -x testbench.exe
vvp -N testbench.exe
