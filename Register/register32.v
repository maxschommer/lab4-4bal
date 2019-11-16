module register32
#(parameter WIDTH=32)
(
output reg  [WIDTH-1:0] q,
input       [WIDTH-1:0] d,
input       wrenable,
input       clk
);
    genvar i;
    generate
        for (i=0; i<WIDTH; i=i+1)
        begin:genblock
    	    always @(posedge clk) begin
		        if(wrenable) begin
		            q[i] <= d[i];
		        end
		    end
        end
    endgenerate


endmodule