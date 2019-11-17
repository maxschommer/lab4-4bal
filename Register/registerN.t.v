`include "registerN.v"

// Test a 4 bit version of the register (it's extensible with parameters)
module testRegisterN();
	localparam WIDTH = 4;
	// localparam PULSED = 0;
	reg clkpulsed; 	// Variable for signaling if the clock has 
					// has been pulsed.
 
	reg enable;
	reg clk;
	reg [WIDTH-1:0] inputs;
	wire [WIDTH-1:0] outputs;

	registerN #(.WIDTH(WIDTH)) regN_test (.q(outputs), .d(inputs), .wrenable(enable), .clk(clk));

	initial begin
		inputs[WIDTH-1:0] = 0;
		clk = 0;
		enable = 0;

		$display("Input  Enable  Clk Pulsed? | Register");
		$display("%b     %b         %b       |    %b", inputs, enable, clkpulsed, outputs);

		clk = 1; clkpulsed = 1; #10 // Pulse clock

		$display("%b     %b         %b       |    %b", inputs, enable, clkpulsed, outputs);
		clk=0; clkpulsed = 0; // Clock is low, and not pulsed
		enable = 1;
		$display("%b     %b         %b       |    %b", inputs, enable, clkpulsed, outputs);
		clk = 1; clkpulsed = 1; #10 // Pulse clock with enable, should result in register 0
		$display("%b     %b         %b       |    %b", inputs, enable, clkpulsed, outputs);
		clkpulsed = 0;
		inputs = 12; // Should result in no change
		$display("%b     %b         %b       |    %b", inputs, enable, clkpulsed, outputs);
		clk = 0; #10 clk = 1; #10 clkpulsed = 1;  // Should now change register
		$display("%b     %b         %b       |    %b", inputs, enable, clkpulsed, outputs);
		inputs = 6; 
		clk = 0; #10 clk = 1; #10  clkpulsed = 1;
		$display("%b     %b         %b       |    %b", inputs, enable, clkpulsed, outputs);
	end
endmodule