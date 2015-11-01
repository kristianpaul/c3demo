#!/bin/bash

set -ex
python3 8x8font.py > 8x8font.h

riscv32-unknown-elf-gcc -Os -m32 -ffreestanding -nostdlib -o firmware.elf firmware.S firmware.c \
		--std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc
chmod -x firmware.elf

riscv32-unknown-elf-objcopy -O binary firmware.elf firmware.bin
chmod -x firmware.bin

python3 makehex.py firmware.bin 2048 > firmware.hex
