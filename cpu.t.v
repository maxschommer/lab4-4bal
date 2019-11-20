`include "cpu.v"

// Uncomment the `define below to enable dumping waveform traces for debugging
//`define DUMP_WAVEFORM

`define ASSERT_EQ(val, exp, msg) \
  if (val !== exp) $display("[FAIL] %s (got:0b%b expected:0b%b)", msg, val, exp);


module cpu_test ();
	reg clk;
	wire [31:0] D_a_inspect, D_b_inspect;
	wire [5:0] op_inspect;
	reg [31:0] prog_instruction;
	reg [31:0] inst_addr;
	reg prog_en;
	reg debug, debug_v;
	reg load_mem = 1'b0;

	cpu DUT(.clk(clk),
			.D_a_inspect(D_a_inspect),
			.D_b_inspect(D_b_inspect),
			.op_inspect(op_inspect),
			.prog_instruction(prog_instruction),
			.inst_addr       (inst_addr),
			.prog_en         (prog_en),
			.debug           (debug),
			.debug_v 		 (debug_v),
			.load_mem        (load_mem));

	// Generate (infinite) clock
	initial clk=0;
	always #10 clk = !clk;


	reg [4:0] s, t, d; // Variables to use for instructions
	reg [15:0] i;
	reg [9:0] i10;

    reg [7:0] itr;

	initial begin
        itr = 7'b0;
		// Optionally dump waveform traces for debugging
		`ifdef DUMP_WAVEFORM
		  $dumpfile("cpu.vcd");
		  $dumpvars();
		`endif
		debug = 1'b0;
		debug_v = 1'b1;

		// Add 10, 20, 30, and 40 into registers 8, 9, 10, and 11.

		// addi $t, $s, imm 
		// $t = $s + imm
		// 0010 00ss ssst tttt iiii iiii iiii iiii
		t = 5'd8; s = 5'd0; i = 16'd10;
		prog_en = 1'b1; inst_addr = 32'b0; prog_instruction = {`ADDI_OP, s, t,  i};
		@(posedge clk); #1 // Load an instruction

		t = 5'd9; s = 5'd0; i = 16'd20;
		prog_en = 1'b1; inst_addr = 32'd4; prog_instruction = {`ADDI_OP, s, t,  i};
		@(posedge clk); #1 // Load an instruction

		t = 5'd10; s = 5'd0; i = 16'd30;
		prog_en = 1'b1; inst_addr = 32'd8; prog_instruction = {`ADDI_OP, s, t,  i};
		@(posedge clk); #1 // Load an instruction

		t = 5'd11; s = 5'd0; i = 16'd40;
		prog_en = 1'b1; inst_addr = 32'd12; prog_instruction = {`ADDI_OP, s, t,  i};
		@(posedge clk); #1 // Load an instruction

		// Now load the first vector with the elements in the registers.
		// 000111 ddddd sssss 00000 0000000000
		// $d = {$s, $s+1, $s+2, $s+3}
		d = 5'd1; s = 5'd8;
		prog_en = 1'b1; inst_addr = 32'd16; prog_instruction = {`VTYPE_OP, d, s, 5'd0, 5'd0, `LDV_W};
		$display("prog_instruction, %b", prog_instruction);
		@(posedge clk); #1 // Load an instruction



		// Store the first vector in the general purpose registers.
		// 000111 ddddd sssss 00000 0000000000
		// $d, $d+1, $d+2, $d+3 = $s
		d = 5'd16; s = 5'd1;
		prog_en = 1'b1; inst_addr = 32'd20; prog_instruction = {`VTYPE_OP, d, s, 5'd0, 5'd0, `STV_W};
		$display("prog_instruction, %b", prog_instruction);
		@(posedge clk); #1 // Load an instruction

		// Add 1 to the vector in register 0 and place in register 2
		// 000111 ddddd sssss iiiiiiiiii 010100[+ Op-Code Value]
		// $d = $s + imm
		d = 5'd2; s = 5'd0; i10 = 10'd1;
		prog_en = 1'b1; inst_addr = 32'd24; prog_instruction = {`VTYPE_OP, d, s, i10, `ADDIV_B};
		$display("prog_instruction, %b", prog_instruction);
		@(posedge clk); #1 // Load an instruction

		// Add 1 to the vector in register 0 and place in register 3
		// 000111 ddddd sssss iiiiiiiiii 010100[+ Op-Code Value]
		// $d = $s + imm
		d = 5'd3; s = 5'd0; i10 = 10'd2;
		prog_en = 1'b1; inst_addr = 32'd28; prog_instruction = {`VTYPE_OP, d, s, i10, `ADDIV_B};
		$display("prog_instruction, %b", prog_instruction);
		@(posedge clk); #1 // Load an instruction


		// Add the vector in register 2 to the vector in register 3 and place in register 4
		// 000111 ddddd aaaaa bbbbb 00000 001010[+ Op-Code Value]
		// $d = $a + $b
		d = 5'd4; s = 5'd2; t = 5'd3;
		prog_en = 1'b1; inst_addr = 32'd32; prog_instruction = {`VTYPE_OP, d, s, t, 5'b0, `ADDV_B};
		$display("prog_instruction, %b", prog_instruction);
		@(posedge clk); #1 // Load an instruction



		// prog_en = 1'b1; inst_addr = 32'd4; prog_instruction = {`ADDI_OP, 5'b00000, 5'd2,  16'd12};
		// @(posedge clk); #1 // Load an instruction

		// prog_en = 1'b1; inst_addr = 32'd8; prog_instruction = {`ADDI_OP, 5'b00000, 5'd3,  16'd30};
		// @(posedge clk); #1 // Load an instruction

		// //  $t = $s + imm
		// // 0010 00ss ssst tttt iiii iiii iiii iiii
		// prog_en = 1'b1; inst_addr = 32'd12; prog_instruction = {`ADDI_OP, 5'd31, 5'd31,  16'd0};
		// @(posedge clk); #1 // Load an instruction

		// Jump back to 0
		// 0000 10ii iiii iiii iiii iiii iiii iiii
		// prog_en = 1'b1; inst_addr = 32'd12; prog_instruction = {6'b000010, 26'd1};
		// @(posedge clk); #1 // Load an instruction
		
		// Jump to address at register 2
		// prog_en = 1'b1; inst_addr = 32'd12; prog_instruction = {6'b000000, 5'd2, 21'b000000000000000001000};
		// @(posedge clk); #1 // Load an instruction
		

		// // Jump and Link
		// // 0000 11ii iiii iiii iiii iiii iiii iiii
		// prog_en = 1'b1; inst_addr = 32'd16; prog_instruction = {`JAL_OP,  26'd2};
		// @(posedge clk); #1 // Load an instruction


		// Branch if Equal
		// beq $s, $t, offset 
		// 0001 00ss ssst tttt iiii iiii iiii iiii 
		// s = 5'd1; t = 5'd2; i = 16'd5; // Should incremente program counter 
		// prog_en = 1'b1; inst_addr = 32'd16; prog_instruction = {`BNE_OP,  s, t, i};
		// $display("Prog Instruction %b", prog_instruction);
		// @(posedge clk); #1 // Load an instruction



		prog_en = 1'b0;

		// Run three instructions
		repeat(30)
		@(posedge clk); #1

		// // Add the 0 register and immediate to the register 1
		// // $t = $s + imm
		// // 0010 00ss ssst tttt iiii iiii iiii iiii 
		// Instruction = {6'b001000, 5'b00000, 5'b00001,  16'd42};
		// @(posedge clk); #1

		// // Reg[1] = 42;
		// // Add the 1 register and immediate to the register 2. This should give 66.
		// // $t = $s + imm
		// Instruction = {6'b001000, 5'b00001, 5'b00010,  16'd24};
		// @(posedge clk); #1

		// // Reg[1] = 42; Reg[2] = 66;
		// // Add the 1 register and register 2 to register 3. This should give 108.
		// // $d = $s + $t
		// // 0000 00ss ssst tttt dddd d000 0010 0000
		// Instruction = {6'b000000, 5'b00001, 5'b00010, 5'b00011, 11'b00000100000};
		// @(posedge clk); #1

		// // Reg[1] = 42; Reg[2] = 66; Reg[3] = 108; MEM[0] = 108
		// // Store the 3 register into memory at location 0. This should give 108.
		// // MEM[$s + offset] = $t
		// // 1010 11ss ssst tttt iiii iiii iiii iiii
		// Instruction = {6'b101011, 5'b00000, 5'b00011, 16'b0};
		// @(posedge clk); #1

		// // Reg[1] = 42; Reg[2] = 66; Reg[3] = 108; Reg[4] = 108; MEM[0] = 108
		// // Load memory at address 0 into register 4. This should give 108.
		// // $t = MEM[$s + offset]
		// // 1000 11ss ssst tttt iiii iiii iiii iiii
		// Instruction = {6'b100011, 5'b00000, 5'b00100, 16'b0};
		// @(posedge clk); #1


		// // Add the 4 register and immediate to the register 4
		// // $t = $s + imm
		// // 0010 00ss ssst tttt iiii iiii iiii iiii 
		// Instruction = {6'b001000, 5'b00100, 5'b00100,  16'd0};
		// @(posedge clk); #1
        
        $display("General Purpose Reg  $0: %d", DUT.REG.genblock[0].regOut);
        $display("General Purpose Reg  $1: %d", DUT.REG.genblock[1].regOut);
        $display("General Purpose Reg  $2: %d", DUT.REG.genblock[2].regOut);
        $display("General Purpose Reg  $3: %d", DUT.REG.genblock[3].regOut);
        $display("General Purpose Reg  $4: %d", DUT.REG.genblock[4].regOut);
        $display("General Purpose Reg  $5: %d", DUT.REG.genblock[5].regOut);
        $display("General Purpose Reg  $6: %d", DUT.REG.genblock[6].regOut);
        $display("General Purpose Reg  $7: %d", DUT.REG.genblock[7].regOut);
        $display("General Purpose Reg  $8: %d", DUT.REG.genblock[8].regOut);
        $display("General Purpose Reg  $9: %d", DUT.REG.genblock[9].regOut);
        $display("General Purpose Reg $10: %d", DUT.REG.genblock[10].regOut);
        $display("General Purpose Reg $11: %d", DUT.REG.genblock[11].regOut);
        $display("General Purpose Reg $12: %d", DUT.REG.genblock[12].regOut);
        $display("General Purpose Reg $13: %d", DUT.REG.genblock[13].regOut);
        $display("General Purpose Reg $14: %d", DUT.REG.genblock[14].regOut);
        $display("General Purpose Reg $15: %d", DUT.REG.genblock[15].regOut);
        $display("General Purpose Reg $16: %d", DUT.REG.genblock[16].regOut);
        $display("General Purpose Reg $17: %d", DUT.REG.genblock[17].regOut);
        $display("General Purpose Reg $18: %d", DUT.REG.genblock[18].regOut);
        $display("General Purpose Reg $19: %d", DUT.REG.genblock[19].regOut);
        $display("General Purpose Reg $20: %d", DUT.REG.genblock[20].regOut);
        $display("General Purpose Reg $21: %d", DUT.REG.genblock[21].regOut);
        $display("General Purpose Reg $22: %d", DUT.REG.genblock[22].regOut);
        $display("General Purpose Reg $23: %d", DUT.REG.genblock[23].regOut);
        $display("General Purpose Reg $24: %d", DUT.REG.genblock[24].regOut);
        $display("General Purpose Reg $25: %d", DUT.REG.genblock[25].regOut);
        $display("General Purpose Reg $26: %d", DUT.REG.genblock[26].regOut);
        $display("General Purpose Reg $27: %d", DUT.REG.genblock[27].regOut);
        $display("General Purpose Reg $28: %d", DUT.REG.genblock[28].regOut);
        $display("General Purpose Reg $29: %d", DUT.REG.genblock[29].regOut);
        $display("General Purpose Reg $30: %d", DUT.REG.genblock[30].regOut);
        $display("General Purpose Reg $31: %d", DUT.REG.genblock[31].regOut);

        $display("Vector Reg  $0: %b", DUT.VREG.genblock[0].regOut);
        $display("Vector Reg  $1: %b", DUT.VREG.genblock[1].regOut);
        $display("Vector Reg  $2: %b", DUT.VREG.genblock[2].regOut);
        $display("Vector Reg  $3: %b", DUT.VREG.genblock[3].regOut);
        $display("Vector Reg  $4: %b", DUT.VREG.genblock[4].regOut);
        $display("Vector Reg  $5: %b", DUT.VREG.genblock[5].regOut);
        $display("Vector Reg  $6: %b", DUT.VREG.genblock[6].regOut);
        $display("Vector Reg  $7: %b", DUT.VREG.genblock[7].regOut);
        $display("Vector Reg  $8: %b", DUT.VREG.genblock[8].regOut);
        $display("Vector Reg  $9: %b", DUT.VREG.genblock[9].regOut);
        $display("Vector Reg $10: %b", DUT.VREG.genblock[10].regOut);
        $display("Vector Reg $11: %b", DUT.VREG.genblock[11].regOut);
        $display("Vector Reg $12: %b", DUT.VREG.genblock[12].regOut);
        $display("Vector Reg $13: %b", DUT.VREG.genblock[13].regOut);
        $display("Vector Reg $14: %b", DUT.VREG.genblock[14].regOut);
        $display("Vector Reg $15: %b", DUT.VREG.genblock[15].regOut);
        $display("Vector Reg $16: %b", DUT.VREG.genblock[16].regOut);
        $display("Vector Reg $17: %b", DUT.VREG.genblock[17].regOut);
        $display("Vector Reg $18: %b", DUT.VREG.genblock[18].regOut);
        $display("Vector Reg $19: %b", DUT.VREG.genblock[19].regOut);
        $display("Vector Reg $20: %b", DUT.VREG.genblock[20].regOut);
        $display("Vector Reg $21: %b", DUT.VREG.genblock[21].regOut);
        $display("Vector Reg $22: %b", DUT.VREG.genblock[22].regOut);
        $display("Vector Reg $23: %b", DUT.VREG.genblock[23].regOut);
        $display("Vector Reg $24: %b", DUT.VREG.genblock[24].regOut);
        $display("Vector Reg $25: %b", DUT.VREG.genblock[25].regOut);
        $display("Vector Reg $26: %b", DUT.VREG.genblock[26].regOut);
        $display("Vector Reg $27: %b", DUT.VREG.genblock[27].regOut);
        $display("Vector Reg $28: %b", DUT.VREG.genblock[28].regOut);
        $display("Vector Reg $29: %b", DUT.VREG.genblock[29].regOut);
        $display("Vector Reg $30: %b", DUT.VREG.genblock[30].regOut);
        $display("Vector Reg $31: %b", DUT.VREG.genblock[31].regOut);

        //for (itr = 7'b0; itr < 7'd32; itr=itr+1'b1) begin
        //    //$display("Register $%d: %d", itr, DUT.REG.genblock[itr].regOut);
        //    $display("Register $%d", itr);
        //end
        //$display("%d", DUT.D_w);
		
		// `ASSERT_EQ(out, 32'b1101, "Sign extending positive value.")
		#1 $finish();
	end
endmodule
