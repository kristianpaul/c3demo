module c3demo (
	input clk,
	output led1, led2, led3,
	output P1_1, P1_2, P1_3, P1_4, P1_7, P1_8, P1_9, P1_10
	// output P2_1, P2_2, P2_3, P2_4, P2_7, P2_8, P2_9, P2_10
);
	reg [15:0] counter = 0;
	reg [7:0] sweep = 0;

	always @(posedge clk) begin
		if (counter == 0) begin
			if (sweep[14:0] == 0)
				sweep <= 1;
			else
				sweep <= sweep << 1;
		end
		counter <= counter + 1;
	end

	assign {P1_1, P1_2, P1_3, P1_4, P1_7, P1_8, P1_9, P1_10} = sweep;
	// assign {P2_1, P2_2, P2_3, P2_4, P2_7, P2_8, P2_9, P2_10} = sweep;
	assign {led1, led2, led3} = sweep;
endmodule
