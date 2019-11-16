`include "memory.v"

// Uncomment the `define below to enable dumping waveform traces for debugging
//`define DUMP_WAVEFORM

`define ASSERT_EQ(val, exp, msg) \
  if (val !== exp) $display("[FAIL] %s (got:0b%b expected:0b%b)", msg, val, exp);

module memory_test ();

	reg [31:0] PC;
	wire [31:0] instruction;

	wire [31:0] data_out;
	reg [31:0] data_in;
	reg [31:0] data_addr;

	reg clk;
	reg wr_en;

	memory DUT(	.PC(PC),
				.instruction(instruction),
				.data_out   (data_out),
				.data_in    (data_in),
				.data_addr  (data_addr),
				.clk        (clk),
				.wr_en      (wr_en));

	// Generate (infinite) clock
	initial clk=0;
	always #10 clk = !clk;


	initial begin
		// Optionally dump waveform traces for debugging
		`ifdef DUMP_WAVEFORM
		  $dumpfile("signextend.vcd");
		  $dumpvars();
		`endif

		@(negedge clk);  
		wr_en= 1'b1; PC = 32'd0; data_in = 32'd0; data_addr = 32'd0;
		@(posedge clk); #1
		`ASSERT_EQ(instruction, 32'd0, "Reading instruction at register 0.")
		`ASSERT_EQ(data_out, 32'd0, "Writing data 0 to register 0.")

		@(negedge clk);  
		wr_en= 1'b1; PC = 32'd464; data_in = 32'd42; data_addr = 32'd464;
		@(posedge clk); #1
		`ASSERT_EQ(instruction, 32'd42, "Reading instruction at register 464.")
		`ASSERT_EQ(data_out, 32'd42, "Wriging data 42 at register 464.")

		@(negedge clk);  
		wr_en= 1'b0; PC = 32'd464; data_in = 32'd48; data_addr = 32'd464;
		@(posedge clk); #1
		`ASSERT_EQ(instruction, 32'd42, "Reading instruction at register 464.")
		`ASSERT_EQ(data_out, 32'd42, "Wriging data 48 at register 464 with write enable off.")

		#1 $finish(); 
	end
endmodule