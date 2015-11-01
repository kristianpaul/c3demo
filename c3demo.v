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
	input CLK12MHZ,
	output reg DEBUG0, DEBUG1, LED1, LED2, LED3,
	output PANEL_R0, PANEL_G0, PANEL_B0, PANEL_R1, PANEL_G1, PANEL_B1,
	output PANEL_A, PANEL_B, PANEL_C, PANEL_D, PANEL_CLK, PANEL_STB, PANEL_OE
);
	// 2048 32bit words = 8k bytes memory
	// 128 32bit words = 512 bytes memory
	parameter MEM_SIZE = 2048;

	// set to 0 for simulation
	parameter USE_PLL = 1;


	// -------------------------------
	// PLL

	wire clk;

	// always @* DEBUG0 = clk;
	// always @* DEBUG1 = CLK12MHZ;

	generate if (USE_PLL) begin
		// wire [7:0] DYNAMICDELAY = 0;
		// wire PLLOUTCORE, EXTFEEDBACK = 0, LATCHINPUTVALUE = 0;
		// SB_PLL40_CORE #(
		// 	.FEEDBACK_PATH("SIMPLE"),
		// 	.DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
		// 	.DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
		// 	.PLLOUT_SELECT("GENCLK"),
		// 	.FDA_FEEDBACK(0),
		// 	.FDA_RELATIVE(0),
		// 	.DIVR(10),
		// 	.DIVF(0),
		// 	.DIVQ(1),
		// 	.FILTER_RANGE(0),
		// 	.ENABLE_ICEGATE(0),
		// 	.TEST_MODE(0)
		// ) uut (
		// 	.REFERENCECLK   (CLK12MHZ       ),
		// 	.PLLOUTGLOBAL   (clk            ),
		// 	.LOCK           (pll_lock       ),
		// 	.BYPASS         (1'b0           ),
		// 	.RESETB         (1'b1           ),

		// 	.PLLOUTCORE     (PLLOUTCORE     ),
		// 	.EXTFEEDBACK    (EXTFEEDBACK    ),
		// 	.DYNAMICDELAY   (DYNAMICDELAY   ),
		// 	.LATCHINPUTVALUE(LATCHINPUTVALUE)
		// );

		reg [7:0] divided_clock;
		always @(posedge CLK12MHZ)
			divided_clock <= divided_clock + 1;

		// SB_GB clock_buffer (
		// 	.USER_SIGNAL_TO_GLOBAL_BUFFER(divided_clock[0]),
		// 	.GLOBAL_BUFFER_OUTPUT(clk)
		// );

		assign clk = divided_clock[1];
	end else begin
		assign pll_lock = 1, clk = CLK12MHZ;
	end endgenerate


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
		// .ENABLE_COUNTERS(1),
		// .LATCHED_MEM_RDATA(1),
		// .TWO_STAGE_SHIFT(1),
		// .TWO_CYCLE_ALU(1),
		// .CATCH_MISALIGN(0),
		// .CATCH_ILLINSN(0)
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

	reg [31:0] memory [0:MEM_SIZE-1];
	initial $readmemh("firmware.hex", memory);

	always @(posedge clk) begin
		mem_ready <= 0;
		led_wr_enable <= 0;
		if (!resetn) begin
			LED1 <= 0;
			LED2 <= 0;
			LED3 <= 0;
			DEBUG0 <= 0;
			DEBUG1 <= 0;
		end else
		if (mem_valid && !mem_ready) begin
			(* parallel_case *)
			case (1)
				(mem_addr >> 2) < MEM_SIZE: begin
					if (mem_wstrb) begin
						if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
						if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
						if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
						if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
					end else begin
						mem_rdata <= memory[mem_addr >> 2];
					end
					mem_ready <= 1;
				end
				(mem_addr & 32'hF000_0000) == 32'h1000_0000: begin
					if (mem_wstrb) begin
						{led_wr_addr_y, led_wr_addr_x} <= mem_addr >> 2;
						led_wr_rgb_data <= mem_wdata;
						led_wr_enable <= 1;
					end
					mem_ready <= 1;
				end
				(mem_addr & 32'hF000_0000) == 32'h2000_0000: begin
					if (mem_wstrb) begin
						if (mem_addr[7:0] == 8'h 00) LED1 <= mem_wdata;
						if (mem_addr[7:0] == 8'h 04) LED2 <= mem_wdata;
						if (mem_addr[7:0] == 8'h 08) LED3 <= mem_wdata;
						if (mem_addr[7:0] == 8'h 0c) DEBUG0 <= mem_wdata;
						if (mem_addr[7:0] == 8'h 10) DEBUG1 <= mem_wdata;
					end
					mem_ready <= 1;
				end
			endcase
		end
	end
endmodule
