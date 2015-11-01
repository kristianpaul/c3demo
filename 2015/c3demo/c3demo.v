// Description of the LED panel:
// http://bikerglen.com/projects/lighting/led-panel-1up/#The_LED_Panel
//
// PANEL_[ABCD] ... select rows (in pairs from top and bottom half)
// PANEL_OE ....... display the selected rows (active low)
// PANEL_CLK ...... serial clock for color data
// PANEL_STB ...... latch shifted data (active high)
// PANEL_[RGB]0 ... color channel for top half
// PANEL_[RGB]1 ... color channel for bottom half

module c3demo (
	input clk,
	output LED1, LED2, LED3,
	output PANEL_R0, PANEL_G0, PANEL_B0, PANEL_R1, PANEL_G1, PANEL_B1,
	output PANEL_A, PANEL_B, PANEL_C, PANEL_D, PANEL_CLK, PANEL_STB, PANEL_OE
);
	// -------------------------------
	// Reset Generator

	reg [7:0] resetn_counter = 0;
	wire resetn = &resetn_counter;

	always @(posedge clk) begin
		if (!resetn)
			resetn_counter <= resetn_counter + 1;
	end


	// -------------------------------
	// LED Panel Driver

	reg led_wr_enable;
	reg [4:0] led_wr_addr_x = 0;
	reg [4:0] led_wr_addr_y = 0;
	reg [23:0] led_wr_rgb_data;

	ledpanel ledpanel (
		.clk        (clk            ),
		.wr_enable  (led_wr_enable  ),
		.wr_addr_x  (led_wr_addr_x  ),
		.wr_addr_y  (led_wr_addr_y  ),
		.wr_rgb_data(led_wr_rgb_data),

		.PANEL_R0   (PANEL_R0 ),
		.PANEL_G0   (PANEL_G0 ),
		.PANEL_B0   (PANEL_B0 ),
		.PANEL_R1   (PANEL_R1 ),
		.PANEL_G1   (PANEL_G1 ),
		.PANEL_B1   (PANEL_B1 ),
		.PANEL_A    (PANEL_A  ),
		.PANEL_B    (PANEL_B  ),
		.PANEL_C    (PANEL_C  ),
		.PANEL_D    (PANEL_D  ),
		.PANEL_CLK  (PANEL_CLK),
		.PANEL_STB  (PANEL_STB),
		.PANEL_OE   (PANEL_OE )
	);


	// -------------------------------
	// PicoRV32 Core

	wire mem_valid;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;

	reg mem_ready;
	reg [31:0] mem_rdata;

	picorv32 #(
		.ENABLE_COUNTERS(0),
		.LATCHED_MEM_RDATA(1),
		.TWO_STAGE_SHIFT(0),
		.TWO_CYCLE_ALU(1),
		.CATCH_MISALIGN(0),
		.CATCH_ILLINSN(0)
	) cpu (
		.clk      (clk      ),
		.resetn   (resetn   ),
		.mem_valid(mem_valid),
		.mem_ready(mem_ready),
		.mem_addr (mem_addr ),
		.mem_wdata(mem_wdata),
		.mem_wstrb(mem_wstrb),
		.mem_rdata(mem_rdata)
	);


	// -------------------------------
	// Memory/IO Interface

	// 2048 32bit words = 8k bytes memory
	// 128 32bit words = 512 bytes memory
	localparam MEM_SIZE = 128;
	reg [31:0] memory [0:MEM_SIZE-1];
	initial $readmemh("firmware.hex", memory);

	always @(posedge clk) begin
		mem_ready <= 0;
		led_wr_enable <= 0;
		if (resetn && mem_valid && !mem_ready) begin
			(* parallel_case *)
			case (1)
				!mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					mem_rdata <= memory[mem_addr >> 2];
					mem_ready <= 1;
				end
				|mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
					if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
					if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
					if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
					mem_ready <= 1;
				end
				|mem_wstrb && (mem_addr & 32'hF000_0000) == 32'h1000_0000: begin
					{led_wr_addr_y, led_wr_addr_x} <= mem_addr >> 2;
					led_wr_rgb_data <= mem_wdata;
					led_wr_enable <= 1;
					mem_ready <= 1;
				end
			endcase
		end
	end
endmodule
