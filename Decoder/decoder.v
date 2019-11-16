
module decoder 
    (                               // R type | I type | J type
        output [5:0] op,            //    1   |   1    |   1
        output reg [4:0] rs,        //    1   |   1    |   0
        output reg [4:0] rt,        //    1   |   1    |   0
        output reg [4:0] rd,        //    1   |   0    |   0
        output reg [4:0] shamt,     //    1   |   0    |   0
        output reg [5:0] funct,     //    1   |   0    |   0
        output reg [15:0] imm,      //    0   |   1    |   0
        output reg [25:0] jaddr,    //    0   |   0    |   1
        input [31:0] code
    );

    assign op = code[31:26];

    always @(code) begin
        // R-type (add/sub/and/or/slt)
        if (op == 6'b0) begin
            shamt <= code[10:6];
            rd <= code[15:11];
            rt <= code[20:16];
            rs <= code[25:21];
            funct <= code[5:0];
        end

        // J-type (j/jal)
        else if (op == 6'b10 | op == 6'b11) begin
            jaddr <= code[26:0];
        end

        // I-type (beq/addi/ori/lw/sw)
        else begin
            rt <= code[20:16];
            rs <= code[25:21];
            imm <= code[15:0];
        end
    end
endmodule
