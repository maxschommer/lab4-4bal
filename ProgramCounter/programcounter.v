// Program counter modes. Currently there
// is increment and set. If increment, then program
// counter is incremented by 4. If set, then the program
// counter is set to the set_val
`define INC  1'b0
`define SET  1'b1


module programcounter (
    output [31:0] next_address_out,
    input [31:0] addr_in,
    input clk    // Clock
);

    reg[31:0] addr_next = 16'd0;
    assign next_address_out = addr_next;

    always @(posedge clk) begin
        addr_next = addr_in;
    end 

endmodule
