module testbench;
	reg clk = 1;
	always #5 clk = !clk;
	c3demo uut (.clk(clk));

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		repeat (1000000) @(posedge clk);
		$finish;
	end
endmodule
