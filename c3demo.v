module c3demo (
	input clk,
	output LED1, LED2, LED3,
	output reg PANEL_R0, PANEL_G0, PANEL_B0, PANEL_R1, PANEL_G1, PANEL_B1,
	output reg PANEL_A, PANEL_B, PANEL_C, PANEL_D, PANEL_CLK, PANEL_STB, PANEL_OE
);
	reg [5:0] cnt_x = 0;
	reg [3:0] cnt_y = 0;
	reg state = 0;

	always @(posedge clk) begin
		if (state == 0) begin
			if (cnt_x >= 32) begin
				cnt_x <= 0;
				cnt_y <= cnt_y + 1;
			end else begin
				cnt_x <= cnt_x + 1;
				PANEL_STB <= 0;
			end
			PANEL_CLK <= 0;
			PANEL_STB <= 0;
		end else begin
			PANEL_CLK <= !cnt_x[5];
			PANEL_STB <= cnt_x[5];
		end
		PANEL_OE <= 0;
		state <= !state;
	end

	always @* begin
		{PANEL_R1, PANEL_R0} = {2{!cnt_y[0]}};
		{PANEL_G1, PANEL_G0} = {2{!cnt_y[1]}};
		{PANEL_B1, PANEL_B0} = {2{!cnt_y[2]}};
		{PANEL_A, PANEL_B, PANEL_C, PANEL_D} = cnt_y;
	end
endmodule
