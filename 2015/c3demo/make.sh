#!/bin/bash

set -ex
bash firmware.sh nopush

yosys -v2 -p 'synth_ice40 -top c3demo -blif c3demo.blif' c3demo.v ledpanel.v picorv32.v
arachne-pnr -d 8k -p c3demo.pcf -o c3demo.txt c3demo.blif
icepack c3demo.txt c3demo.bin

scp c3demo.bin pi@raspi:icoprog/
ssh pi@raspi 'set -ex && cd icoprog/ && sudo ./icoprog < c3demo.bin'
