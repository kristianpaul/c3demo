#!/bin/bash

set -ex
bash firmware.sh nopush

iverilog -o testbench.exe -s testbench testbench.v c3demo.v ledpanel.v picorv32.v
chmod -x testbench.exe
vvp -N testbench.exe
