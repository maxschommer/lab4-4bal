
module signextendv (
	output [127:0] se,
	input [9:0] imm
);
	reg [127:0] res;

	assign se = res;
    always @* begin
    	if (imm[9] == 0) begin
    		res[127:10] <= 118'b0;
    	end
    	else begin
    		res[127:10] <= {118{1'b1}}; // This should be checked with a test bench
    	end
    	res[9:0] <= imm;
    end

endmodule
