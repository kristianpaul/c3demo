module c3demo (
	input clk,
	output LED1, LED2, LED3,
	output P1_1, P1_2, P1_3, P1_4, P1_7, P1_8, P1_9, P1_10,
	output P2_1, P2_2, P2_3, P2_4, P2_7, P2_8, P2_9, P2_10
);
	reg PANEL_R0, PANEL_G0, PANEL_B0, PANEL_R1, PANEL_G1, PANEL_B1;
	reg PANEL_A, PANEL_B, PANEL_C, PANEL_D, PANEL_CLK, PANEL_STB, PANEL_OE;

	initial begin
	end

	reg [9:0] counter = 0;
	always @(posedge clk) begin
		counter <= counter + 1;

		PANEL_STB <= counter[9];
		PANEL_CLK <= counter[0];

		// select address 0
		PANEL_A <= 0;
		PANEL_B <= 0;
		PANEL_C <= 0;
		PANEL_D <= 0;

		// select red
		{PANEL_R1, PANEL_R0} <= 3;
		{PANEL_G1, PANEL_G0} <= 0;
		{PANEL_B1, PANEL_B0} <= 0;

		// enable output
		PANEL_OE = 1;
	end
	
	assign P1_1  = PANEL_R0;
	assign P1_2  = PANEL_B0;
	assign P1_3  = PANEL_R1;
	assign P1_4  = PANEL_B1;
	assign P1_7  = PANEL_A;
	assign P1_8  = PANEL_C;
	assign P1_9  = PANEL_CLK;
	assign P1_10 = PANEL_OE;

	assign P2_1  = PANEL_G0;
	assign P2_2  = PANEL_G1;
	assign P2_3  = PANEL_B;
	assign P2_4  = PANEL_D;
	assign P2_7  = PANEL_STB;
	assign P2_8  = 0;
	assign P2_9  = 0;
	assign P2_10 = 0;
endmodule
