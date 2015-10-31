module testbench;
	reg clk = 0;

	initial begin
		#5; forever #5 clk = !clk;
	end

	c3demo uut (.clk(clk));

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		repeat (10000) @(posedge clk);
		$finish;
	end
endmodule
