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

	c3demo uut (
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
	reg [8:0] a, b, c;
	reg [31:0] fw;

	task raspi_send;
		input [8:0] word;
		begin
			raspi_dir <= 1;
			raspi_dout <= word;
			#20;
			raspi_clk <= 1;
			#20;
			raspi_clk <= 0;
		end
	endtask

	task raspi_recv;
		output [8:0] word;
		begin
			raspi_dir <= 0;
			raspi_dout <= 'bz;
			#20;
			word <= raspi_dat;
			raspi_clk <= 1;
			#20;
			raspi_clk <= 0;
		end
	endtask

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);

		repeat (100)
			@(posedge clk);

		raspi_send(9'h 1ff);
		raspi_send(9'h 0ff);

		b = 0;
		while (b != 9'h 1ff)
			raspi_recv(b);

		raspi_send(9'h 100);

		for (a = 64; a < 128; a = a+1)
			raspi_send(a);

		c = 9'h 100;
		raspi_recv(b);
		$display("Link test: BEGIN  %x (expected: %x, %0s)", b, c, b === c ? "ok" : "ERROR");
		if (b !== c) $finish;

		for (a = 64; a < 128; a = a+1) begin
			raspi_recv(b);
			c =  (((a << 5) + a) ^ 7) & 255;
			$display("Link test: %x -> %x (expected: %x, %0s)", a, b, c, b === c ? "ok" : "ERROR");
			if (b !== c) $finish;
		end

		c = 9'h 1ff;
		raspi_recv(b);
		$display("Link test: END    %x (expected: %x, %0s)", b, c, b === c ? "ok" : "ERROR");
		if (b !== c) $finish;

		repeat (1000)
			@(posedge clk);

		$display("Uploading firmware..");

		raspi_send(9'h 1ff);
		raspi_send(9'h 0ff);

		f = $fopen("firmware.hex", "r");
		raspi_send(9'h 101);

		while ($fscanf(f, "%x", fw) == 1) begin
			raspi_send(fw[ 7: 0]);
			raspi_send(fw[15: 8]);
			raspi_send(fw[23:16]);
			raspi_send(fw[31:24]);
		end

		$fclose(f);

		raspi_send(9'h 1ff);
		raspi_send(9'h 0ff);

		b = 0;
		while (b != 9'h 1ff)
			raspi_recv(b);

		$display("Reading debugger..");

		raspi_send(9'h 1ff);
		raspi_send(9'h 000);

		repeat (100)
			raspi_recv(b);
		while (b != 9'h 1ff)
			raspi_recv(b);

		$display("Running the system..");

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
