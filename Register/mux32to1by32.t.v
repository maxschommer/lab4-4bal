`include "mux32to1by32.v"

module testMux32to1by32();
	localparam WIDTH = 32;

	reg [4:0] address;
	reg [WIDTH-1:0] inputs;
	wire [WIDTH-1:0] out;


	mux32to1by32 DUT(.out(out), .address(address), .input5 (inputs));

	initial begin
		inputs[WIDTH-1:0] = 0;
		address = 5'b0; inputs = 23; 
		$display("Addr    Input                             |   Out");
		while (address < WIDTH-1) begin
			// inputs[WIDTH-1:0] = 18;
			$display("%b  %b   |   %b", address, inputs, out);
			// inputs[address] = 22;
			$display("%b  %b   |   %b", address, inputs, out);

			address = address + 1;
		end
	end
endmodule