module testbench;
	reg clk = 0;
	integer i, k;

	initial begin
		#5; forever #5 clk = !clk;
	end

	c3demo #(
		.USE_PLL(0)
	) uut (
		.CLK12MHZ(clk)
	);

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		for (k = 0; k < 10; k = k+1) begin
			$write("%3d:", k);
			for (i = 0; i < 30; i = i+1) begin
				repeat (10000) @(posedge clk);
				$write("%3d", i);
				$fflush;
			end
			$display("");
		end
		$finish;
	end
endmodule
