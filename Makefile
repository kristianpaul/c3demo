
SSH_RASPI := ssh pi@raspi

help:
	@echo ""
	@echo "Building FPGA bitstream and program:"
	@echo "   make prog_sram"
	@echo "   make prog_flash"
	@echo ""
	@echo "Building firmware image and update:"
	@echo "   make prog_firmware"
	@echo ""
	@echo "Resetting FPGA (prevent boot from flash):"
	@echo "   make reset_halt"
	@echo ""
	@echo "Resetting FPGA (load image from flash):"
	@echo "   make reset_boot"
	@echo ""
	@echo "Console session (close with Ctrl-D):"
	@echo "   make console"
	@echo ""
	@echo "Download debug trace (to 'debug.vcd'):"
	@echo "   make debug"
	@echo ""

firmware.elf: firmware.S firmware.c firmware.lds
	riscv32-unknown-elf-gcc -Os -m32 -ffreestanding -nostdlib -o firmware.elf firmware.S firmware.c \
			--std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc
	chmod -x firmware.elf

firmware.bin: firmware.elf
	riscv32-unknown-elf-objcopy -O binary firmware.elf firmware.bin
	chmod -x firmware.bin

firmware.hex: makehex.py firmware.bin
	python3 makehex.py firmware.bin 2048 > firmware.hex
	@echo "Firmware size: $(grep .. firmware.hex | wc -l) / $(wc -l < firmware.hex)"

c3demo.blif: c3demo.v ledpanel.v picorv32.v firmware.hex
	yosys -v2 -p 'synth_ice40 -top c3demo -blif c3demo.blif' c3demo.v ledpanel.v picorv32.v

c3demo.txt: c3demo.pcf c3demo.blif
	arachne-pnr -s 3 -d 8k -p c3demo.pcf -o c3demo.txt c3demo.blif

c3demo.bin: c3demo.txt
	icepack c3demo.txt c3demo.bin

prog_sram: c3demo.bin
	$(SSH_RASPI) 'icoprog -p' < c3demo.bin

prog_flash: c3demo.bin
	$(SSH_RASPI) 'icoprog -f' < c3demo.bin

prog_firmware: firmware.bin
	$(SSH_RASPI) 'icoprog -w1' < firmware.bin

reset_halt:
	$(SSH_RASPI) 'icoprog -R'

reset_boot:
	$(SSH_RASPI) 'icoprog -b'

console:
	$(SSH_RASPI) 'icoprog -c2'

debug:
	sedexpr="$$( grep '//.*debug_.*->' c3demo.v | sed 's,.*\(debug_\),s/\1,; s, *-> *, /,; s, *$$, /;,;'; )"; \
	$(SSH_RASPI) 'icoprog -V16' | sed -e "$$sedexpr" > debug.vcd

.SECONDARY:
.PHONY: prog_sram prog_flash prog_firmware reset_halt reset_boot console debug

