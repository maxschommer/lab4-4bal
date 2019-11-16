// ALU commands
`define ADD_  3'd0
`define SUB_  3'd1
`define XOR_  3'd2
`define SLT_  3'd3
`define AND_  3'd4
`define NAND_ 3'd5
`define NOR_  3'd6
`define OR_   3'd7

module alu
    (
        output[31:0]  result,
        output        	iszero,
        output        	overflow,
        input[31:0]   operandA,
        input[31:0]   operandB,
        input[2:0]    	command
    );

    reg[31:0] result_prelim; // 33 bits, 1 to check overflow
    reg ovf;

    assign result = result_prelim;
    assign iszero = result_prelim == 32'b0;

    // MIPS defined overflow is for signed ADD and ADDI instructions, so we don't need
    // to deal with other subtraction. 
    assign overflow = ((operandA[31] == operandB[31]) && (operandA[31] != result_prelim[31])) && ((command == `ADD_));

    always @* begin
        case (command) 
            `ADD_:  begin result_prelim <= operandA + operandB; end
            `SUB_:  begin result_prelim <= operandA - operandB; end
            `XOR_:  begin result_prelim <= operandA ^ operandB; end
            `AND_:  begin result_prelim <= operandA & operandB; end
            `NAND_:  begin result_prelim <= ~(operandA & operandB); end
            `NOR_:  begin result_prelim <= ~(operandA | operandB); end
            `OR_:  begin result_prelim <= operandA | operandB; end
            `SLT_: begin result_prelim <= (operandA < operandB) ? 1'b1  : 1'b0; end
            default : /* default */;
        endcase
    end
endmodule
