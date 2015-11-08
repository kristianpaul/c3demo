// Synplify Pro is not comfortable inferring iCE40 4K brams for
// clock domain crossing FIFOs. Yosys does not have this issue.
`define BEHAVIORAL_FIFO_MODEL

// Divide the 12 MHz by this power of two: 0=12MHz, 1=6MHz, 2=3MHz, ...
`define POW2CLOCKDIV 1

module c3demo (
	input CLK12MHZ,
	output reg DEBUG0, DEBUG1, LED1, LED2, LED3,

	// 32x32 LED Panel
	output PANEL_R0, PANEL_G0, PANEL_B0, PANEL_R1, PANEL_G1, PANEL_B1,
	output PANEL_A, PANEL_B, PANEL_C, PANEL_D, PANEL_CLK, PANEL_STB, PANEL_OE,

	// RasPi Interface: 9 Data Lines (cmds have MSB set)
	inout RASPI_11, RASPI_12, RASPI_15, RASPI_16, RASPI_19, RASPI_21, RASPI_24, RASPI_35, RASPI_36,

	// RasPi Interface: Control Lines
	input RASPI_38, RASPI_40
);
	// 2048 32bit words = 8k bytes memory
	// 128 32bit words = 512 bytes memory
	parameter MEM_SIZE = 2048;

	// wire dgb0, dbg1;
	// always @* DEBUG0 = dbg0;
	// always @* DEBUG1 = dbg1;


	// -------------------------------
	// PLL

	wire clk;
	wire resetn;

	c3demo_clkgen clkgen (
		.CLK12MHZ(CLK12MHZ),
		.clk(clk),
		.resetn(resetn)
	);


	// -------------------------------
	// RasPi Interface

	wire recv_sync;

	// recv ep0: transmission test
	wire recv_ep0_valid;
	wire recv_ep0_ready;
	wire [7:0] recv_ep0_data;

	// recv ep1: firmware upload
	wire recv_ep1_valid;
	wire recv_ep1_ready = 1;
	wire [7:0] recv_ep1_data = recv_ep0_data;

	// recv ep2: unused
	wire recv_ep2_valid;
	wire recv_ep2_ready = 1;
	wire [7:0] recv_ep2_data = recv_ep0_data;

	// recv ep3: unused
	wire recv_ep3_valid;
	wire recv_ep3_ready = 1;
	wire [7:0] recv_ep3_data = recv_ep0_data;

	// send ep0: transmission test
	wire send_ep0_valid;
	wire send_ep0_ready;
	wire [7:0] send_ep0_data;

	// send ep1: debugger
	wire send_ep1_valid;
	wire send_ep1_ready;
	wire [7:0] send_ep1_data;

	// send ep2: unused
	wire send_ep2_valid = 0;
	wire send_ep2_ready;
	wire [7:0] send_ep2_data;

	// send ep3: unused
	wire send_ep3_valid = 0;
	wire send_ep3_ready;
	wire [7:0] send_ep3_data;

	// trigger lines
	wire trigger_0;  // debugger
	wire trigger_1;  // unused
	wire trigger_2;  // unused
	wire trigger_3;  // unused

	c3demo_raspi_interface #(
		.NUM_RECV_EP(4),
		.NUM_SEND_EP(4),
		.NUM_TRIGGERS(4)
	) raspi_interface (
		.clk(clk),
		.sync(recv_sync),

		.recv_valid({
			recv_ep3_valid,
			recv_ep2_valid,
			recv_ep1_valid,
			recv_ep0_valid
		}),
		.recv_ready({
			recv_ep3_ready,
			recv_ep2_ready,
			recv_ep1_ready,
			recv_ep0_ready
		}),
		.recv_tdata(
			recv_ep0_data
		),

		.send_valid({
			send_ep3_valid,
			send_ep2_valid,
			send_ep1_valid,
			send_ep0_valid
		}),
		.send_ready({
			send_ep3_ready,
			send_ep2_ready,
			send_ep1_ready,
			send_ep0_ready
		}),
		.send_tdata(
			(send_ep3_data & {8{send_ep3_valid && send_ep3_ready}}) |
			(send_ep2_data & {8{send_ep2_valid && send_ep2_ready}}) |
			(send_ep1_data & {8{send_ep1_valid && send_ep1_ready}}) |
			(send_ep0_data & {8{send_ep0_valid && send_ep0_ready}})
		),

		.trigger({
			trigger_3,
			trigger_2,
			trigger_1,
			trigger_0
		}),

		.RASPI_11(RASPI_11),
		.RASPI_12(RASPI_12),
		.RASPI_15(RASPI_15),
		.RASPI_16(RASPI_16),
		.RASPI_19(RASPI_19),
		.RASPI_21(RASPI_21),
		.RASPI_24(RASPI_24),
		.RASPI_35(RASPI_35),
		.RASPI_36(RASPI_36),
		.RASPI_38(RASPI_38),
		.RASPI_40(RASPI_40)
	);


	// -------------------------------
	// Transmission test (recv ep0, send ep0) 

	assign send_ep0_data = ((recv_ep0_data << 5) + recv_ep0_data) ^ 7;
	assign send_ep0_valid = recv_ep0_valid;
	assign recv_ep0_ready = send_ep0_ready;
	

	// -------------------------------
	// Firmware upload (recv ep1)

	reg [15:0] prog_mem_addr;
	reg [31:0] prog_mem_data;
	reg [1:0] prog_mem_state;
	reg prog_mem_active = 0;
	reg prog_mem_reset = 0;

	always @(posedge clk) begin
		if (recv_sync) begin
			prog_mem_addr <= ~0;
			prog_mem_data <= 0;
			prog_mem_state <= 0;
			prog_mem_active <= 0;
			prog_mem_reset <= 0;
		end else
		if (recv_ep1_valid) begin
			prog_mem_addr <= prog_mem_addr + &prog_mem_state;
			prog_mem_data <= {recv_ep1_data, prog_mem_data[31:8]};
			prog_mem_state <= prog_mem_state + 1;
			prog_mem_active <= &prog_mem_state;
			prog_mem_reset <= 1;
		end
	end


	// -------------------------------
	// On-chip logic analyzer (send ep1, trig1)

	(* keep *) wire debug_trigger;
	(* keep *) wire [15:0] debug_data;

	c3demo_debugger #(
		.WIDTH(16),
		.DEPTH(200),
		.TRIGAT(50)
	) debugger (
		.clk(clk),
		.resetn(resetn),

		.trigger(debug_trigger),
		.data(debug_data),

		.dump_en(trigger_1),
		.dump_valid(send_ep1_valid),
		.dump_ready(send_ep1_ready),
		.dump_data(send_ep1_data)
	);

	assign debug_trigger = PANEL_STB;
	assign debug_data = {
		PANEL_R0,  // debug_12 -> PANEL_R0
		PANEL_G0,  // debug_11 -> PANEL_G0
		PANEL_B0,  // debug_10 -> PANEL_B0
		PANEL_R1,  // debug_9  -> PANEL_R1
		PANEL_G1,  // debug_8  -> PANEL_G1
		PANEL_B1,  // debug_7  -> PANEL_B1
		PANEL_A,   // debug_6  -> PANEL_A
		PANEL_B,   // debug_5  -> PANEL_B
		PANEL_C,   // debug_4  -> PANEL_C
		PANEL_D,   // debug_3  -> PANEL_D
		PANEL_CLK, // debug_2  -> PANEL_CLK
		PANEL_STB, // debug_1  -> PANEL_STB
		PANEL_OE   // debug_0  -> PANEL_OE
	};


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

	wire resetn_picorv32 = resetn && !prog_mem_reset;

	picorv32 cpu (
		.clk       (clk            ),
		.resetn    (resetn_picorv32),
		.mem_valid (mem_valid      ),
		.mem_ready (mem_ready      ),
		.mem_addr  (mem_addr       ),
		.mem_wdata (mem_wdata      ),
		.mem_wstrb (mem_wstrb      ),
		.mem_rdata (mem_rdata      )
	);


	// -------------------------------
	// Memory/IO Interface

	reg [31:0] memory [0:MEM_SIZE-1];
	initial $readmemh("firmware.hex", memory);

	always @(posedge clk) begin
		mem_ready <= 0;
		led_wr_enable <= 0;
		if (!resetn_picorv32) begin
			LED1 <= 0;
			LED2 <= 0;
			LED3 <= 0;
			DEBUG0 <= 0;
			DEBUG1 <= 0;

			if (prog_mem_active) begin
				memory[prog_mem_addr] <= prog_mem_data;
			end
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

// ======================================================================

module c3demo_clkgen (
	input CLK12MHZ,
	output clk,
	output resetn
);
	// PLLs are not working on alpha board 
	// -----------------------------------
	//
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

	reg [`POW2CLOCKDIV:0] divided_clock = 0;
	always @* divided_clock[0] = CLK12MHZ;

	genvar i;
	generate for (i = 1; i <= `POW2CLOCKDIV; i = i+1) begin
		always @(posedge divided_clock[i-1])
			divided_clock[i] <= !divided_clock[i];
	end endgenerate

	SB_GB clock_buffer (
		.USER_SIGNAL_TO_GLOBAL_BUFFER(divided_clock[`POW2CLOCKDIV]),
		.GLOBAL_BUFFER_OUTPUT(clk)
	);

	// -------------------------------
	// Reset Generator

	reg [7:0] resetn_counter = 0;
	assign resetn = &resetn_counter;

	always @(posedge clk) begin
		if (!resetn)
			resetn_counter <= resetn_counter + 1;
	end
endmodule

// ======================================================================

module c3demo_crossclkfifo #(
	parameter WIDTH = 8,
	parameter DEPTH = 16
) (
	input                  in_clk,
	input                  in_shift,
	input      [WIDTH-1:0] in_data,
	output reg             in_full,
	output reg             in_nempty,

	input                  out_clk,
	input                  out_pop,
	output     [WIDTH-1:0] out_data,
	output reg             out_nempty
);
	localparam integer ABITS = $clog2(DEPTH);

	initial begin
		in_full = 0;
		in_nempty = 0;
		out_nempty = 0;
	end

	function [ABITS-1:0] bin2gray(input [ABITS-1:0] in);
		integer i;
		reg [ABITS:0] temp;
		begin
			temp = in;
			for (i=0; i<ABITS; i=i+1)
				bin2gray[i] = ^temp[i +: 2];
		end
	endfunction

	function [ABITS-1:0] gray2bin(input [ABITS-1:0] in);
		integer i;
		begin
			for (i=0; i<ABITS; i=i+1)
				gray2bin[i] = ^(in >> i);
		end
	endfunction

	reg [ABITS-1:0] in_ipos = 0, in_opos = 0;
	reg [ABITS-1:0] out_opos = 0, out_ipos = 0;


`ifdef BEHAVIORAL_FIFO_MODEL

	// Behavioral model for the clock domain crossing fifo

	reg [WIDTH-1:0] memory [0:DEPTH-1];

	// input side of fifo

	wire [ABITS-1:0] next_ipos = in_ipos == DEPTH-1 ? 0 : in_ipos + 1;
	wire [ABITS-1:0] next_next_ipos = next_ipos == DEPTH-1 ? 0 : next_ipos + 1;

	always @(posedge in_clk) begin
		if (in_shift && !in_full) begin
			memory[in_ipos] <= in_data;
			in_full <= next_next_ipos == in_opos;
			in_nempty <= 1;
			in_ipos <= next_ipos;
		end else begin
			in_full <= next_ipos == in_opos;
			in_nempty <= in_ipos != in_opos;
		end
	end

	// output side of fifo

	wire [ABITS-1:0] next_opos = out_opos == DEPTH-1 ? 0 : out_opos + 1;
	reg [WIDTH-1:0] out_data_d = 0;

	always @(posedge out_clk) begin
		if (out_pop && out_nempty) begin
			out_data_d <= memory[next_opos];
			out_nempty <= next_opos != out_ipos;
			out_opos <= next_opos;
		end else begin
			out_data_d <= memory[out_opos];
			out_nempty <= out_opos != out_ipos;
		end
	end

	assign out_data = out_nempty ? out_data_d : 0;

`else /* BEHAVIORAL_FIFO_MODEL */

	// Structural model for the clock domain crossing fifo

	wire        memory_wclk  = in_clk;
	wire        memory_wclke = 1;
	wire        memory_we;
	wire [10:0] memory_waddr;
	wire [15:0] memory_mask  = 16'h 0000;
	wire [15:0] memory_wdata;

	wire [15:0] memory_rdata;
	wire        memory_rclk  = out_clk;
	wire        memory_rclke = 1;
	wire        memory_re    = 1;
	wire [10:0] memory_raddr;

	SB_RAM40_4K #(
		.WRITE_MODE(0),
		.READ_MODE(0)
	) memory (
		.WCLK (memory_wclk ),
		.WCLKE(memory_wclke),
		.WE   (memory_we   ),
		.WADDR(memory_waddr),
		.MASK (memory_mask ),
		.WDATA(memory_wdata),

		.RDATA(memory_rdata),
		.RCLK (memory_rclk ),
		.RCLKE(memory_rclke),
		.RE   (memory_re   ),
		.RADDR(memory_raddr)
	);

	initial begin
		if (WIDTH > 16 || DEPTH > 256) begin
			$display("Fifo with width %d and depth %d does not fit into a SB_RAM40_4K!", WIDTH, DEPTH);
			$finish;
		end
	end

	// input side of fifo

	wire [ABITS-1:0] next_ipos = in_ipos == DEPTH-1 ? 0 : in_ipos + 1;
	wire [ABITS-1:0] next_next_ipos = next_ipos == DEPTH-1 ? 0 : next_ipos + 1;

	always @(posedge in_clk) begin
		if (in_shift && !in_full) begin
			in_full <= next_next_ipos == in_opos;
			in_nempty <= 1;
			in_ipos <= next_ipos;
		end else begin
			in_full <= next_ipos == in_opos;
			in_nempty <= in_ipos != in_opos;
		end
	end

	assign memory_we = in_shift && !in_full;
	assign memory_waddr = in_ipos;
	assign memory_wdata = in_data;

	// output side of fifo

	wire [ABITS-1:0] next_opos = out_opos == DEPTH-1 ? 0 : out_opos + 1;
	wire [WIDTH-1:0] out_data_d = memory_rdata;

	always @(posedge out_clk) begin
		if (out_pop && out_nempty) begin
			out_nempty <= next_opos != out_ipos;
			out_opos <= next_opos;
		end else begin
			out_nempty <= out_opos != out_ipos;
		end
	end

	assign memory_raddr = (out_pop && out_nempty) ? next_opos : out_opos;
	assign out_data = out_nempty ? out_data_d : 0;

`endif /* BEHAVIORAL_FIFO_MODEL */


	// clock domain crossing of ipos

	reg [ABITS-1:0] in_ipos_gray = 0;
	reg [ABITS-1:0] out_ipos_gray_2 = 0;
	reg [ABITS-1:0] out_ipos_gray_1 = 0;
	reg [ABITS-1:0] out_ipos_gray_0 = 0;

	always @(posedge in_clk) begin
		in_ipos_gray <= bin2gray(in_ipos);
	end

	always @(posedge out_clk) begin
		out_ipos_gray_2 <= in_ipos_gray;
		out_ipos_gray_1 <= out_ipos_gray_2;
		out_ipos_gray_0 <= out_ipos_gray_1;
		out_ipos <= gray2bin(out_ipos_gray_0);
	end


	// clock domain crossing of opos

	reg [ABITS-1:0] out_opos_gray = 0;
	reg [ABITS-1:0] in_opos_gray_2 = 0;
	reg [ABITS-1:0] in_opos_gray_1 = 0;
	reg [ABITS-1:0] in_opos_gray_0 = 0;

	always @(posedge out_clk) begin
		out_opos_gray <= bin2gray(out_opos);
	end

	always @(posedge in_clk) begin
		in_opos_gray_2 <= out_opos_gray;
		in_opos_gray_1 <= in_opos_gray_2;
		in_opos_gray_0 <= in_opos_gray_1;
		in_opos <= gray2bin(in_opos_gray_0);
	end
endmodule

// ======================================================================

module c3demo_raspi_interface #(
	// number of communication endpoints
	parameter NUM_RECV_EP = 4,
	parameter NUM_SEND_EP = 4,
	parameter NUM_TRIGGERS = 4
) (
	input clk,
	output sync,

	output [NUM_RECV_EP-1:0] recv_valid,
	input  [NUM_RECV_EP-1:0] recv_ready,
	output [       7:0] recv_tdata,

	input  [NUM_SEND_EP-1:0] send_valid,
	output [NUM_SEND_EP-1:0] send_ready,
	input  [       7:0] send_tdata,

	output [NUM_TRIGGERS-1:0] trigger,

	// RasPi Interface: 9 Data Lines (cmds have MSB set)
	inout RASPI_11, RASPI_12, RASPI_15, RASPI_16, RASPI_19, RASPI_21, RASPI_24, RASPI_35, RASPI_36,

	// RasPi Interface: Control Lines
	input RASPI_38, RASPI_40
);
	// All signals with "raspi_" prefix are in the "raspi_clk" clock domain.
	// All other signals are in the "clk" clock domain.

	wire [8:0] raspi_din;
	reg [8:0] raspi_dout;

	wire raspi_dir = RASPI_38;
	wire raspi_clk;

	SB_GB raspi_clock_buffer (
		.USER_SIGNAL_TO_GLOBAL_BUFFER(RASPI_40),
		.GLOBAL_BUFFER_OUTPUT(raspi_clk)
	);

	SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) raspi_io [8:0] (
		.PACKAGE_PIN({RASPI_11, RASPI_12, RASPI_15, RASPI_16, RASPI_19, RASPI_21, RASPI_24, RASPI_35, RASPI_36}),
		.OUTPUT_ENABLE(!raspi_dir),
		.D_OUT_0(raspi_dout),
		.D_IN_0(raspi_din)
	);


	// system clock side

	function [NUM_SEND_EP-1:0] highest_send_bit;
		input [NUM_SEND_EP-1:0] bits;
		integer i;
		begin
			highest_send_bit = 0;
			for (i = 0; i < NUM_SEND_EP; i = i+1)
				if (bits[i]) highest_send_bit = 1 << i;
		end
	endfunction

	function [7:0] highest_send_bit_index;
		input [NUM_SEND_EP-1:0] bits;
		integer i;
		begin
			highest_send_bit_index = 0;
			for (i = 0; i < NUM_SEND_EP; i = i+1)
				if (bits[i]) highest_send_bit_index = i;
		end
	endfunction

	wire [7:0] recv_epnum, send_epnum;
	wire recv_nempty, send_full;

	assign recv_valid = recv_nempty ? 1 << recv_epnum : 0;
	assign send_ready = highest_send_bit(send_valid) & {NUM_SEND_EP{!send_full}};
	assign send_epnum = highest_send_bit_index(send_valid);

	assign sync = &recv_epnum && &recv_tdata && recv_nempty;
	assign trigger = &recv_epnum && recv_nempty ? 1 << recv_tdata : 0;


	// raspi side

	reg [7:0] raspi_din_ep;
	reg [7:0] raspi_dout_ep = 0;
	wire raspi_recv_nempty;

	wire [15:0] raspi_send_data;
	wire raspi_send_nempty;

	always @* begin
		raspi_dout = raspi_recv_nempty ? 9'h 1fe : 9'h 1ff;
		if (raspi_send_nempty) begin
			if (raspi_dout_ep != raspi_send_data[15:8])
				raspi_dout = {1'b1, raspi_send_data[15:8]};
			else
				raspi_dout = {1'b0, raspi_send_data[ 7:0]};
		end
	end

	always @(posedge raspi_clk) begin
		if (raspi_din[8] && raspi_dir)
			raspi_din_ep <= raspi_din[7:0];
		if (!raspi_dir)
			raspi_dout_ep <= raspi_send_nempty ? raspi_send_data[15:8] : raspi_dout;
	end


	// fifos

	c3demo_crossclkfifo #(
		.WIDTH(16),
		.DEPTH(256)
	) fifo_recv (
		.in_clk(raspi_clk),
		.in_shift(raspi_dir && !raspi_din[8]),
		.in_data({raspi_din_ep, raspi_din[7:0]}),
		.in_nempty(raspi_recv_nempty),

		.out_clk(clk),
		.out_pop(|(recv_valid & recv_ready) || (recv_epnum >= NUM_RECV_EP)),
		.out_data({recv_epnum, recv_tdata}),
		.out_nempty(recv_nempty)
	), fifo_send (
		.in_clk(clk),
		.in_shift(|(send_valid & send_ready)),
		.in_data({send_epnum, send_tdata}),
		.in_full(send_full),

		.out_clk(raspi_clk),
		.out_pop((raspi_dout_ep == raspi_send_data[15:8]) && !raspi_dir),
		.out_data(raspi_send_data),
		.out_nempty(raspi_send_nempty)
	);
endmodule

// ======================================================================

module c3demo_debugger #(
	parameter WIDTH = 32,
	parameter DEPTH = 256,
	parameter TRIGAT = 64
) (
	input clk,
	input resetn,

	input             trigger,
	input [WIDTH-1:0] data,

	input            dump_en,
	output reg       dump_valid,
	input            dump_ready,
	output reg [7:0] dump_data
);
	localparam DEPTH_BITS = $clog2(DEPTH);

	localparam BYTES = (WIDTH + 7) / 8;
	localparam BYTES_BITS = $clog2(BYTES);

	reg [WIDTH-1:0] memory [0:DEPTH-1];
	reg [DEPTH_BITS-1:0] mem_pointer, stop_counter;
	reg [BYTES_BITS-1:0] bytes_counter;

	reg [1:0] state;
	localparam state_running   = 0;
	localparam state_triggered = 1;
	localparam state_waitdump  = 2;
	localparam state_dump      = 3;

	always @(posedge clk)
		dump_data <= memory[mem_pointer] >> (8*bytes_counter);

	always @(posedge clk) begin
		dump_valid <= 0;
		if (!resetn) begin
			mem_pointer <= 0;
			state <= state_running;
		end else
		case (state)
			state_running: begin
				memory[mem_pointer] <= data;
				mem_pointer <= mem_pointer == DEPTH-1 ? 0 : mem_pointer+1;
				stop_counter <= DEPTH - TRIGAT - 2;
				if (trigger) begin
					state <= state_triggered;
				end
			end
			state_triggered: begin
				memory[mem_pointer] <= data;
				mem_pointer <= mem_pointer == DEPTH-1 ? 0 : mem_pointer+1;
				stop_counter <= stop_counter - 1;
				if (!stop_counter) begin
					state <= state_waitdump;
				end
			end
			state_waitdump: begin
				if (dump_en)
					state <= state_dump;
				stop_counter <= DEPTH-1;
				bytes_counter <= 0;
			end
			state_dump: begin
				if (dump_valid && dump_ready) begin
					if (bytes_counter == BYTES-1) begin
						if (!stop_counter)
							state <= state_running;
						bytes_counter <= 0;
						stop_counter <= stop_counter - 1;
						mem_pointer <= mem_pointer == DEPTH-1 ? 0 : mem_pointer+1;
					end else begin
						bytes_counter <= bytes_counter + 1;
					end
				end else begin
					dump_valid <= 1;
				end
			end
		endcase
	end
endmodule

