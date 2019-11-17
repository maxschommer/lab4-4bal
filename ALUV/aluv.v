// ALU commands
`define ADD_  3'd0
`define SUB_  3'd1
`define XOR_  3'd2
`define SLT_  3'd3
`define AND_  3'd4
`define NAND_ 3'd5
`define NOR_  3'd6
`define OR_   3'd7

`define BYTE_       3'd0
`define HALFWORD_   3'd1
`define WORD_       3'd2
`define DOUBLEWORD_ 3'd3
`define VECTOR_     3'd4

module aluv
    (
        output[127:0]  result,
        output        	iszero,
        input[127:0]   operandA,
        input[127:0]   operandB,
        input[2:0]    	command
        input[2:0]      dtype
    );

    reg[127:0] result_prelim; // 33 bits, 1 to check overflow

    assign result = result_prelim;

    always @* begin
        case (command) 
            `ADD_:  begin case (dtype)
                            `BYTE_: begin result_prelim <=  {   operandA[127:120] + operandB[127:120], operandA[119:112] + operandB[119:112], 
                                                                operandA[111:104] + operandB[111:104], operandA[103:96] + operandB[103:96],
                                                                operandA[95:88] + operandB[95:88], operandA[87:80] + operandB[87:80], 
                                                                operandA[79:72] + operandB[79:72], operandA[71:64] + operandB[71:64],
                                                                operandA[63:56] + operandB[63:56], operandA[55:48] + operandB[55:48], 
                                                                operandA[47:40] + operandB[47:40], operandA[39:32] + operandB[39:32],
                                                                operandA[31:24] + operandB[31:24], operandA[23:16] + operandB[23:16], 
                                                                operandA[15:8] + operandB[15:8], operandA[7:0] + operandB[7:0]} end
                            `HALFWORD_: begin result_prelim <= {operandA[127:112] + operandB[127:112], operandA[111:96] + operandB[111:96], 
                                                                operandA[95:80] + operandB[95:80], operandA[79:64] + operandB[79:64],
                                                                operandA[63:48] + operandB[63:48], operandA[47:32] + operandB[47:32], 
                                                                operandA[31:16] + operandB[31:16], operandA[15:0] + operandB[15:0]} end
                            `WORD_: begin result_prelim <= {operandA[127:96] + operandB[127:96], operandA[95:64] + operandB[95:64], 
                                                            operandA[63:32] + operandB[63:32], operandA[31:0] + operandB[31:0]} end
                            `DOUBLEWORD_: begin result_prelim <= {operandA[127:64] + operandB[127:64], operandA[63:0] + operandB[63:0]} end
                            `VECTOR: begin result_prelim <= operandA + operandB; end
                        endcase
                    end
            `SUB_:  begin case (dtype)
                            `BYTE_: begin result_prelim <=  {   operandA[127:120] - operandB[127:120], operandA[119:112] - operandB[119:112], 
                                                                operandA[111:104] - operandB[111:104], operandA[103:96] - operandB[103:96],
                                                                operandA[95:88] - operandB[95:88], operandA[87:80] - operandB[87:80], 
                                                                operandA[79:72] - operandB[79:72], operandA[71:64] - operandB[71:64],
                                                                operandA[63:56] - operandB[63:56], operandA[55:48] - operandB[55:48], 
                                                                operandA[47:40] - operandB[47:40], operandA[39:32] - operandB[39:32],
                                                                operandA[31:24] - operandB[31:24], operandA[23:16] - operandB[23:16], 
                                                                operandA[15:8] - operandB[15:8], operandA[7:0] - operandB[7:0]} end
                            `HALFWORD_: begin result_prelim <= {operandA[127:112] - operandB[127:112], operandA[111:96] - operandB[111:96], 
                                                                operandA[95:80] - operandB[95:80], operandA[79:64] - operandB[79:64],
                                                                operandA[63:48] - operandB[63:48], operandA[47:32] - operandB[47:32], 
                                                                operandA[31:16] - operandB[31:16], operandA[15:0] - operandB[15:0]} end
                            `WORD_: begin result_prelim <= {operandA[127:96] - operandB[127:96], operandA[95:64] - operandB[95:64], 
                                                            operandA[63:32] - operandB[63:32], operandA[31:0] - operandB[31:0]} end
                            `DOUBLEWORD_: begin result_prelim <= {operandA[127:64] - operandB[127:64], operandA[63:0] - operandB[63:0]} end
                            `VECTOR: begin result_prelim <= operandA - operandB; end
                        endcase
                    end
            `XOR_:  begin case (dtype)
                            `BYTE_: begin result_prelim <=  {   operandA[127:120] ^ operandB[127:120], operandA[119:112] ^ operandB[119:112], 
                                                                operandA[111:104] ^ operandB[111:104], operandA[103:96] ^ operandB[103:96],
                                                                operandA[95:88] ^ operandB[95:88], operandA[87:80] ^ operandB[87:80], 
                                                                operandA[79:72] ^ operandB[79:72], operandA[71:64] ^ operandB[71:64],
                                                                operandA[63:56] ^ operandB[63:56], operandA[55:48] ^ operandB[55:48], 
                                                                operandA[47:40] ^ operandB[47:40], operandA[39:32] ^ operandB[39:32],
                                                                operandA[31:24] ^ operandB[31:24], operandA[23:16] ^ operandB[23:16], 
                                                                operandA[15:8] ^ operandB[15:8], operandA[7:0] ^ operandB[7:0]} end
                            `HALFWORD_: begin result_prelim <= {operandA[127:112] ^ operandB[127:112], operandA[111:96] ^ operandB[111:96], 
                                                                operandA[95:80] ^ operandB[95:80], operandA[79:64] ^ operandB[79:64],
                                                                operandA[63:48] ^ operandB[63:48], operandA[47:32] ^ operandB[47:32], 
                                                                operandA[31:16] ^ operandB[31:16], operandA[15:0] ^ operandB[15:0]} end
                            `WORD_: begin result_prelim <= {operandA[127:96] ^ operandB[127:96], operandA[95:64] ^ operandB[95:64], 
                                                            operandA[63:32] ^ operandB[63:32], operandA[31:0] ^ operandB[31:0]} end
                            `DOUBLEWORD_: begin result_prelim <= {operandA[127:64] ^ operandB[127:64], operandA[63:0] ^ operandB[63:0]} end
                            `VECTOR: begin result_prelim <= operandA ^ operandB; end
                        endcase
                    end
            `AND_:  begin case (dtype)
                            `BYTE_: begin result_prelim <=  {   operandA[127:120] & operandB[127:120], operandA[119:112] & operandB[119:112], 
                                                                operandA[111:104] & operandB[111:104], operandA[103:96] & operandB[103:96],
                                                                operandA[95:88] & operandB[95:88], operandA[87:80] & operandB[87:80], 
                                                                operandA[79:72] & operandB[79:72], operandA[71:64] & operandB[71:64],
                                                                operandA[63:56] & operandB[63:56], operandA[55:48] & operandB[55:48], 
                                                                operandA[47:40] & operandB[47:40], operandA[39:32] & operandB[39:32],
                                                                operandA[31:24] & operandB[31:24], operandA[23:16] & operandB[23:16], 
                                                                operandA[15:8] & operandB[15:8], operandA[7:0] & operandB[7:0]} end
                            `HALFWORD_: begin result_prelim <= {operandA[127:112] & operandB[127:112], operandA[111:96] & operandB[111:96], 
                                                                operandA[95:80] & operandB[95:80], operandA[79:64] & operandB[79:64],
                                                                operandA[63:48] & operandB[63:48], operandA[47:32] & operandB[47:32], 
                                                                operandA[31:16] & operandB[31:16], operandA[15:0] & operandB[15:0]} end
                            `WORD_: begin result_prelim <= {operandA[127:96] & operandB[127:96], operandA[95:64] & operandB[95:64], 
                                                            operandA[63:32] & operandB[63:32], operandA[31:0] & operandB[31:0]} end
                            `DOUBLEWORD_: begin result_prelim <= {operandA[127:64] & operandB[127:64], operandA[63:0] & operandB[63:0]} end
                            `VECTOR: begin result_prelim <= operandA & operandB; end
                        endcase
                    end
            `NAND_:  begin case (dtype)
                            `BYTE_: begin result_prelim <=  {     ~(operandA[127:120] & operandB[127:120]), ~(operandA[119:112] & operandB[119:112]), 
                                                                  ~(operandA[111:104] & operandB[111:104]), ~(operandA[103:96] &   operandB[103:96]),
                                                                  ~(operandA[95:88] &     operandB[95:88]), ~(operandA[87:80] &     operandB[87:80]), 
                                                                  ~(operandA[79:72] &     operandB[79:72]), ~(operandA[71:64] &     operandB[71:64]),
                                                                  ~(operandA[63:56] &     operandB[63:56]), ~(operandA[55:48] &     operandB[55:48]), 
                                                                  ~(operandA[47:40] &     operandB[47:40]), ~(operandA[39:32] &     operandB[39:32]),
                                                                  ~(operandA[31:24] &     operandB[31:24]), ~(operandA[23:16] &     operandB[23:16]), 
                                                                  ~(operandA[15:8] &       operandB[15:8]), ~(operandA[7:0] &         operandB[7:0])} end
                            `HALFWORD_: begin result_prelim <= {  ~(operandA[127:112] & operandB[127:112]), ~(operandA[111:96] &   operandB[111:96]), 
                                                                  ~(operandA[95:80] &     operandB[95:80]), ~(operandA[79:64] &     operandB[79:64]),
                                                                  ~(operandA[63:48] &     operandB[63:48]), ~(operandA[47:32] &     operandB[47:32]), 
                                                                  ~(operandA[31:16] &     operandB[31:16]), ~(operandA[15:0] &       operandB[15:0])} end
                            `WORD_: begin result_prelim <= {      ~(operandA[127:96] &   operandB[127:96]), ~(operandA[95:64] &     operandB[95:64]), 
                                                                  ~(operandA[63:32] &     operandB[63:32]), ~(operandA[31:0] &       operandB[31:0])} end
                            `DOUBLEWORD_: begin result_prelim <= {~(operandA[127:64] &   operandB[127:64]), ~(operandA[63:0] &       operandB[63:0])} end
                            `VECTOR: begin result_prelim <=       ~(operandA & operandB); end
                        endcase
                    end
            `NOR_:  begin case (dtype)
                            `BYTE_: begin result_prelim <=  {     ~(operandA[127:120] | operandB[127:120]), ~(operandA[119:112] | operandB[119:112]), 
                                                                  ~(operandA[111:104] | operandB[111:104]), ~(operandA[103:96] |   operandB[103:96]),
                                                                  ~(operandA[95:88] |     operandB[95:88]), ~(operandA[87:80] |     operandB[87:80]), 
                                                                  ~(operandA[79:72] |     operandB[79:72]), ~(operandA[71:64] |     operandB[71:64]),
                                                                  ~(operandA[63:56] |     operandB[63:56]), ~(operandA[55:48] |     operandB[55:48]), 
                                                                  ~(operandA[47:40] |     operandB[47:40]), ~(operandA[39:32] |     operandB[39:32]),
                                                                  ~(operandA[31:24] |     operandB[31:24]), ~(operandA[23:16] |     operandB[23:16]), 
                                                                  ~(operandA[15:8] |       operandB[15:8]), ~(operandA[7:0] |         operandB[7:0])} end
                            `HALFWORD_: begin result_prelim <= {  ~(operandA[127:112] | operandB[127:112]), ~(operandA[111:96] |   operandB[111:96]), 
                                                                  ~(operandA[95:80] |     operandB[95:80]), ~(operandA[79:64] |     operandB[79:64]),
                                                                  ~(operandA[63:48] |     operandB[63:48]), ~(operandA[47:32] |     operandB[47:32]), 
                                                                  ~(operandA[31:16] |     operandB[31:16]), ~(operandA[15:0] |       operandB[15:0])} end
                            `WORD_: begin result_prelim <= {      ~(operandA[127:96] |   operandB[127:96]), ~(operandA[95:64] |     operandB[95:64]), 
                                                                  ~(operandA[63:32] |     operandB[63:32]), ~(operandA[31:0] |       operandB[31:0])} end
                            `DOUBLEWORD_: begin result_prelim <= {~(operandA[127:64] |   operandB[127:64]), ~(operandA[63:0] |       operandB[63:0])} end
                            `VECTOR: begin result_prelim <=       ~(operandA | operandB); end
                        endcase
                    end
            `OR_:  begin case (dtype)
                            `BYTE_: begin result_prelim <=  {   operandA[127:120] | operandB[127:120], operandA[119:112] | operandB[119:112], 
                                                                operandA[111:104] | operandB[111:104], operandA[103:96] | operandB[103:96],
                                                                operandA[95:88] | operandB[95:88], operandA[87:80] | operandB[87:80], 
                                                                operandA[79:72] | operandB[79:72], operandA[71:64] | operandB[71:64],
                                                                operandA[63:56] | operandB[63:56], operandA[55:48] | operandB[55:48], 
                                                                operandA[47:40] | operandB[47:40], operandA[39:32] | operandB[39:32],
                                                                operandA[31:24] | operandB[31:24], operandA[23:16] | operandB[23:16], 
                                                                operandA[15:8] | operandB[15:8], operandA[7:0] | operandB[7:0]} end
                            `HALFWORD_: begin result_prelim <= {operandA[127:112] | operandB[127:112], operandA[111:96] | operandB[111:96], 
                                                                operandA[95:80] | operandB[95:80], operandA[79:64] | operandB[79:64],
                                                                operandA[63:48] | operandB[63:48], operandA[47:32] | operandB[47:32], 
                                                                operandA[31:16] | operandB[31:16], operandA[15:0] | operandB[15:0]} end
                            `WORD_: begin result_prelim <= {operandA[127:96] | operandB[127:96], operandA[95:64] | operandB[95:64], 
                                                            operandA[63:32] | operandB[63:32], operandA[31:0] | operandB[31:0]} end
                            `DOUBLEWORD_: begin result_prelim <= {operandA[127:64] | operandB[127:64], operandA[63:0] | operandB[63:0]} end
                            `VECTOR: begin result_prelim <= operandA | operandB; end
                        endcase
                    end
            `SLT_: begin case (dtype)
                            `BYTE_: begin result_prelim <=  {     (operandA[127:120] | operandB[127:120]) ? 1'b1 : 1'b0, (operandA[119:112] | operandB[119:112]) ? 1'b1 : 1'b0, 
                                                                  (operandA[111:104] | operandB[111:104]) ? 1'b1 : 1'b0, (operandA[103:96] |   operandB[103:96]) ? 1'b1 : 1'b0,
                                                                  (operandA[95:88] |     operandB[95:88]) ? 1'b1 : 1'b0, (operandA[87:80] |     operandB[87:80]) ? 1'b1 : 1'b0, 
                                                                  (operandA[79:72] |     operandB[79:72]) ? 1'b1 : 1'b0, (operandA[71:64] |     operandB[71:64]) ? 1'b1 : 1'b0,
                                                                  (operandA[63:56] |     operandB[63:56]) ? 1'b1 : 1'b0, (operandA[55:48] |     operandB[55:48]) ? 1'b1 : 1'b0, 
                                                                  (operandA[47:40] |     operandB[47:40]) ? 1'b1 : 1'b0, (operandA[39:32] |     operandB[39:32]) ? 1'b1 : 1'b0,
                                                                  (operandA[31:24] |     operandB[31:24]) ? 1'b1 : 1'b0, (operandA[23:16] |     operandB[23:16]) ? 1'b1 : 1'b0, 
                                                                  (operandA[15:8] |       operandB[15:8]) ? 1'b1 : 1'b0, (operandA[7:0] |         operandB[7:0]) ? 1'b1 : 1'b0} end
                            `HALFWORD_: begin result_prelim <= {  (operandA[127:112] | operandB[127:112]) ? 1'b1 : 1'b0, (operandA[111:96] |   operandB[111:96]) ? 1'b1 : 1'b0, 
                                                                  (operandA[95:80] |     operandB[95:80]) ? 1'b1 : 1'b0, (operandA[79:64] |     operandB[79:64]) ? 1'b1 : 1'b0,
                                                                  (operandA[63:48] |     operandB[63:48]) ? 1'b1 : 1'b0, (operandA[47:32] |     operandB[47:32]) ? 1'b1 : 1'b0, 
                                                                  (operandA[31:16] |     operandB[31:16]) ? 1'b1 : 1'b0, (operandA[15:0] |       operandB[15:0]) ? 1'b1 : 1'b0} end
                            `WORD_: begin result_prelim <= {      (operandA[127:96] |   operandB[127:96]) ? 1'b1 : 1'b0, (operandA[95:64] |     operandB[95:64]) ? 1'b1 : 1'b0, 
                                                                  (operandA[63:32] |     operandB[63:32]) ? 1'b1 : 1'b0, (operandA[31:0] |       operandB[31:0]) ? 1'b1 : 1'b0} end
                            `DOUBLEWORD_: begin result_prelim <= {(operandA[127:64] |   operandB[127:64]) ? 1'b1 : 1'b0, (operandA[63:0] |       operandB[63:0]) ? 1'b1 : 1'b0} end
                            `VECTOR: begin result_prelim <=       (operandA | operandB); end
                        endcase
                    end
            default : /* default */;
        endcase
    end
endmodule
