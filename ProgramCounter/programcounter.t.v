`include "programcounter.v"

// Uncomment the `define below to enable dumping waveform traces for debugging
//`define DUMP_WAVEFORM

`define ASSERT_EQ(val, exp, msg) \
  if (val !== exp) $display("[FAIL] %s (got:0b%b expected:0b%b)", msg, val, exp);


module programcounter_test ();
	wire [31:0] next_address_out;
	reg clk;
	reg [31:0] addr_in;

	initial clk=0;
    always #10 clk = !clk;


	programcounter DUT(	.next_address_out(next_address_out),
						.addr_in(addr_in),
						.clk    (clk));

	initial begin
			// Optionally dump waveform traces for debugging
		`ifdef DUMP_WAVEFORM
		  $dumpfile("programcounter.vcd");
		  $dumpvars();
		`endif

		@(negedge clk); 
	    addr_in = 32'b0; // Set the initial program counter val.
	    @(posedge clk); #1   
		`ASSERT_EQ(next_address_out, 32'b0, "Setting the program counter to 0.")

		@(negedge clk); 
	    addr_in = next_address_out + 4; 
	    @(posedge clk); #1   
		`ASSERT_EQ(next_address_out, 32'b100, "Incrementing the program counter.")
		
		@(negedge clk); 
	    addr_in = 32'b11100101100; // Set the initial program counter val.
	    @(posedge clk); #1   
		`ASSERT_EQ(next_address_out, 32'b11100101100, "Setting the program counter to an arbitrary location.")

		@(negedge clk); 
	    addr_in = next_address_out + 4;  // Set the initial program counter val.
	    @(posedge clk); #1   
		`ASSERT_EQ(next_address_out, 32'b11100110000, "Incrementing the program counter.")
		
		#1 $finish(); 
	end
endmodule