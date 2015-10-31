module c3demo (
	input clk,
	output LED1, LED2, LED3,
	output reg PANEL_R0, PANEL_G0, PANEL_B0, PANEL_R1, PANEL_G1, PANEL_B1,
	output reg PANEL_A, PANEL_B, PANEL_C, PANEL_D, PANEL_CLK, PANEL_STB, PANEL_OE
);
	reg [9:0] counter = 0;
	always @(posedge clk) begin
		counter <= counter + 1;

		// control signals
		PANEL_STB <= counter[9];
		PANEL_CLK <= counter[0];
		PANEL_OE = 0;

		// select address 0
		PANEL_A <= 0;
		PANEL_B <= 0;
		PANEL_C <= 0;
		PANEL_D <= 0;

		// select red
		{PANEL_R1, PANEL_R0} <= 3;
		{PANEL_G1, PANEL_G0} <= 0;
		{PANEL_B1, PANEL_B0} <= 0;
	end
endmodule
