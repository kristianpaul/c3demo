#!/bin/bash

set -ex
bash firmware.sh

yosys -v3 -p 'synth_ice40 -top c3demo -blif c3demo.blif' c3demo.v ledpanel.v picorv32.v
arachne-pnr -d 8k -p c3demo.pcf -o c3demo.txt c3demo.blif
icepack c3demo.txt c3demo.bin

scp c3demo.bin pi@192.168.1.3:icoprog/
ssh pi@192.168.1.3 'set -ex && cd icoprog/ && sudo ./icoprog < c3demo.bin'