#!/bin/bash

set -ex
bash firmware.sh nopush

iverilog -o testbench.exe -s testbench -DSIMULATION \
		testbench.v c3demo.v ledpanel.v picorv32.v \
		$(yosys-config --datdir/ice40/cells_sim.v)
chmod -x testbench.exe
vvp -N testbench.exe
