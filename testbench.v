module testbench;
	reg clk = 0;
	integer i, k;

	wire [8:0] raspi_dat;
	reg [8:0] raspi_dout = 9'bz;
	reg raspi_dir = 0, raspi_clk = 0;
	assign raspi_dat = raspi_dout;

	initial begin
		#5; forever #5 clk = !clk;
	end

	c3demo #(
		.USE_PLL(0)
	) uut (
		.CLK12MHZ(clk),
		.RASPI_11(raspi_dat[8]),
		.RASPI_12(raspi_dat[7]),
		.RASPI_15(raspi_dat[6]),
		.RASPI_16(raspi_dat[5]),
		.RASPI_19(raspi_dat[4]),
		.RASPI_21(raspi_dat[3]),
		.RASPI_24(raspi_dat[2]),
		.RASPI_35(raspi_dat[1]),
		.RASPI_36(raspi_dat[0]),
		.RASPI_38(raspi_dir),
		.RASPI_40(raspi_clk)
	);

	integer f;
	reg [31:0] fw;

	task raspi_send;
		input [8:0] word;
		begin
			raspi_dir <= 1;
			raspi_dout <= word;
			#50 raspi_clk <= 1;
			#50 raspi_clk <= 0;
		end
	endtask

	initial begin
		repeat (1000)
			@(posedge clk);

		f = $fopen("firmware.hex", "r");
		raspi_send(9'h 101);

		while ($fscanf(f, "%x", fw) == 1) begin
			raspi_send(fw[ 7: 0]);
			raspi_send(fw[15: 8]);
			raspi_send(fw[23:16]);
			raspi_send(fw[31:24]);
		end

		raspi_send(9'h 100);
		$fclose(f);
	end

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
