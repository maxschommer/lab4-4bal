`include "signextend.v"

// Uncomment the `define below to enable dumping waveform traces for debugging
//`define DUMP_WAVEFORM

`define ASSERT_EQ(val, exp, msg) \
  if (val !== exp) $display("[FAIL] %s (got:0b%b expected:0b%b)", msg, val, exp);


module signextend_test ();
	reg [15:0] imm;
	wire [31:0] out;

	signextend DUT(.se (out), .imm(imm));

	initial begin
			// Optionally dump waveform traces for debugging
		`ifdef DUMP_WAVEFORM
		  $dumpfile("signextend.vcd");
		  $dumpvars();
		`endif

		imm = 16'b1000000000000000; #1
		`ASSERT_EQ(out, 32'b11111111111111111000000000000000, "Sign extending negative value.")

		imm = 16'b0000000000001101; #1
		`ASSERT_EQ(out, 32'b1101, "Sign extending positive value.")

	end
endmodule