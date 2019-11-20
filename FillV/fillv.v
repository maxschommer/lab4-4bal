`define BYTE_       3'd0
`define HALFWORD_   3'd1
`define WORD_       3'd2
`define DOUBLEWORD_ 3'd3
`define VECTOR_     3'd4

module fillv
    (
        output[127:0]  result,
        input[127:0]   imm128,
        input[2:0]      dtype
    );

    reg[127:0] result_prelim; // 33 bits, 1 to check overflow

    assign result = result_prelim;

    always @* begin
        case (dtype)
                `BYTE_: begin result_prelim <=  {16{imm128[7:0]}}; end
                `HALFWORD_: begin result_prelim <= {8{imm128[15:0]}}; end
                `WORD_: begin result_prelim <= {4{imm128[31:0]}}; end
                `DOUBLEWORD_: begin result_prelim <= {imm128[63:0], imm128[63:0]}; end
                `VECTOR_: begin result_prelim <=    imm128; end
        endcase
    end
endmodule
