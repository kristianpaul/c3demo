#!/bin/bash
set -ex
iverilog -o testbench.exe testbench.v c3demo.v
vvp -N testbench.exe
