#!/bin/bash
iverilog -o testbench.exe testbench.v c3demo.v
vvp -N testbench.exe
