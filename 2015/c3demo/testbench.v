module testbench;
	reg clk = 0;
	integer i;

	initial begin
		#5; forever #5 clk = !clk;
	end

	c3demo uut (.clk(clk));

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		for (i = 0; i < 30; i = i+1) begin
			repeat (10000) @(posedge clk);
			$write("%3d", i);
			$fflush;
		end
		$display("");
		$finish;
	end
endmodule
