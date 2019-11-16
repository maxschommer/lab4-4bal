`include "mux32to1by1.v"

module testMux32to1by1();
	localparam WIDTH = 32;

	reg [4:0] address;
	reg [WIDTH-1:0] inputs;
	wire out;


	mux32to1by1 mux_test(.out(out), .address(address), .inputs (inputs));

	initial begin
		inputs[WIDTH-1:0] = 0;
		address = 5'b0; inputs[0] = 1; 
		$display("Addr    Input                             |   Out");
		while (address < WIDTH-1) begin
			inputs[WIDTH-1:0] = 0;
			$display("%b  %b   |   %b", address, inputs, out);
			inputs[address] = 1;
			$display("%b  %b   |   %b", address, inputs, out);

			address = address + 1;
		end
	end
endmodule