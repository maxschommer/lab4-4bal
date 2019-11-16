`include "decoder.v"


`define ASSERT_EQ(val, exp, msg) \
  if (val !== exp) $display("[FAIL] %s (got:0b%b expected:0b%b)", msg, val, exp);

module test_decoder();

    wire [5:0] op;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0] imm;
    wire [25:0] jaddr;
    reg [31:0] code;

    decoder dec(op, rs, rt, rd, shamt, funct, imm, jaddr, code);

	initial begin

        // lw $t0, 32($s3)
        // op 35, rs 19, rt 8, imm 32
        code = 32'b10001110011010000000000000100000;
        #10;
        `ASSERT_EQ(op, 35, "OP");
        `ASSERT_EQ(rs, 19, "RS");
        `ASSERT_EQ(rt, 8, "RT");
        `ASSERT_EQ(imm, 32, "IMM");

        // add $s0, $s1, $s2
        // op 0, rs 17, rt 18, rd 16, shamt 0, funct 32
        code = 32'b00000010001100101000000000100000;
        #10;
        `ASSERT_EQ(op, 0, "OP");
        `ASSERT_EQ(rs, 17, "RS");
        `ASSERT_EQ(rt, 18, "RT");
        `ASSERT_EQ(rd, 16, "RD");
        `ASSERT_EQ(shamt, 0, "SHAMT");
        `ASSERT_EQ(funct, 32, "FUNCT");

        // j 257
        // op 2, addr 257
        code = 32'b00001000000000000000000100000001;
        #10;
        `ASSERT_EQ(op, 2, "OP");
        `ASSERT_EQ(jaddr, 257, "JADDR");


	end

endmodule
