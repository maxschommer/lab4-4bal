
module signextend (
	output [31:0] se,
	input [15:0] imm
);
	reg [31:0] res;

	assign se = res;
    always @* begin
    	if (imm[15] == 0) begin
    		res[31:16] <= 16'b0;
    	end
    	else begin
    		res[31:16] <= 16'b1111111111111111; // This should be checked with a test bench
    	end
    	res[15:0] <= imm;
    end

endmodule
