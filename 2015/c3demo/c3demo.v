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
	output reg PANEL_R0, PANEL_G0, PANEL_B0, PANEL_R1, PANEL_G1, PANEL_B1,
	output reg PANEL_A, PANEL_B, PANEL_C, PANEL_D, PANEL_CLK, PANEL_STB, PANEL_OE
);
	reg [5:0] cnt_x = 0;
	reg [3:0] cnt_y = 0;
	reg state = 0;

	reg [4:0] addr_x, addr_y;
	reg [2:0] data_rgb;

	reg [5:0] cnt_x_q [0:15];
	reg [3:0] cnt_y_q [0:15];
	integer i;

	always @(posedge clk) begin
		cnt_x_q[0] <= cnt_x;
		cnt_y_q[0] <= cnt_y;
		for (i = 1; i < 16; i=i+1) begin
			cnt_x_q[i] <= cnt_x_q[i-1];
			cnt_y_q[i] <= cnt_y_q[i-1];
		end
	end

	always @(posedge clk) begin
		state <= !state;
		if (!state) begin
			if (cnt_x > 32) begin
				cnt_x <= 0;
				cnt_y <= cnt_y + 1;
			end else begin
				cnt_x <= cnt_x + 1;
			end
		end
	end

	always @(posedge clk) begin
		PANEL_OE <= (cnt_x_q[2] < 2) || (30 < cnt_x_q[2]);
		if (state) begin
			PANEL_CLK <= !cnt_x_q[2][5];
			PANEL_STB <= cnt_x_q[2] == 32;
		end else begin
			PANEL_CLK <= 0;
			PANEL_STB <= 0;
		end
	end

	always @(posedge clk) begin
		addr_x <= cnt_x;
		addr_y <= cnt_y + 16*(!state);
	end

	always @(posedge clk) begin
		data_rgb <= 0;
		if (addr_x == addr_y)
			data_rgb[2] <= 1;
		if (addr_x == 31-addr_y)
			data_rgb[1] <= 1;
		if (addr_x == 15 || addr_x == 16)
			data_rgb[0] <= 1;
	end

	reg [2:0] data_rgb_q;

	always @(posedge clk) begin
		data_rgb_q <= data_rgb;
		if (!state) begin
			{PANEL_R1, PANEL_R0} <= {data_rgb[2], data_rgb_q[2]};
			{PANEL_G1, PANEL_G0} <= {data_rgb[1], data_rgb_q[1]};
			{PANEL_B1, PANEL_B0} <= {data_rgb[0], data_rgb_q[0]};
			{PANEL_D, PANEL_C, PANEL_B, PANEL_A} <= cnt_y_q[2] - 1;
		end
	end
endmodule
