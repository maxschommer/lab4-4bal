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
	reg debug;
	
	cpu DUT(.clk(clk),
			.D_a_inspect(D_a_inspect),
			.D_b_inspect(D_b_inspect),
			.op_inspect(op_inspect),
			.prog_instruction(prog_instruction),
			.inst_addr       (inst_addr),
			.prog_en         (prog_en),
			.debug           (debug));

	// Generate (infinite) clock
	initial clk=0;
	always #10 clk = !clk;


	reg [4:0] s, t;
	reg [15:0] i;

    reg [7:0] itr;

	initial begin
        itr = 7'b0;
		// Optionally dump waveform traces for debugging
		`ifdef DUMP_WAVEFORM
		  $dumpfile("cpu.vcd");
		  $dumpvars();
		`endif
		debug = 1'b0;
		// prog_en = 1'b1; inst_addr = 32'b0; prog_instruction = {`ADDI_OP, 5'b00000, 5'd1,  16'd10};
		// @(posedge clk); #1 // Load an instruction

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
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
		@(posedge clk); #1
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
        
        $display("Reg $0: %d", DUT.REG.genblock[0].regOut);
        $display("Reg $1: %d", DUT.REG.genblock[1].regOut);
        $display("Reg $2: %d", DUT.REG.genblock[2].regOut);
        $display("Reg $3: %d", DUT.REG.genblock[3].regOut);
        $display("Reg $4: %d", DUT.REG.genblock[4].regOut);
        $display("Reg $5: %d", DUT.REG.genblock[5].regOut);
        $display("Reg $6: %d", DUT.REG.genblock[6].regOut);
        $display("Reg $7: %d", DUT.REG.genblock[7].regOut);
        $display("Reg $8: %d", DUT.REG.genblock[8].regOut);
        $display("Reg $9: %d", DUT.REG.genblock[9].regOut);
        $display("Reg $10: %d", DUT.REG.genblock[10].regOut);
        $display("Reg $11: %d", DUT.REG.genblock[11].regOut);
        $display("Reg $12: %d", DUT.REG.genblock[12].regOut);
        $display("Reg $13: %d", DUT.REG.genblock[13].regOut);
        $display("Reg $14: %d", DUT.REG.genblock[14].regOut);
        $display("Reg $15: %d", DUT.REG.genblock[15].regOut);
        $display("Reg $16: %d", DUT.REG.genblock[16].regOut);
        $display("Reg $17: %d", DUT.REG.genblock[17].regOut);
        $display("Reg $18: %d", DUT.REG.genblock[18].regOut);
        $display("Reg $19: %d", DUT.REG.genblock[19].regOut);
        $display("Reg $20: %d", DUT.REG.genblock[20].regOut);
        $display("Reg $21: %d", DUT.REG.genblock[21].regOut);
        $display("Reg $22: %d", DUT.REG.genblock[22].regOut);
        $display("Reg $23: %d", DUT.REG.genblock[23].regOut);
        $display("Reg $24: %d", DUT.REG.genblock[24].regOut);
        $display("Reg $25: %d", DUT.REG.genblock[25].regOut);
        $display("Reg $26: %d", DUT.REG.genblock[26].regOut);
        $display("Reg $27: %d", DUT.REG.genblock[27].regOut);
        $display("Reg $28: %d", DUT.REG.genblock[28].regOut);
        $display("Reg $29: %d", DUT.REG.genblock[29].regOut);
        $display("Reg $30: %d", DUT.REG.genblock[30].regOut);
        $display("Reg $31: %d", DUT.REG.genblock[31].regOut);



        //for (itr = 7'b0; itr < 7'd32; itr=itr+1'b1) begin
        //    //$display("Register $%d: %d", itr, DUT.REG.genblock[itr].regOut);
        //    $display("Register $%d", itr);
        //end
        //$display("%d", DUT.D_w);
		
		// `ASSERT_EQ(out, 32'b1101, "Sign extending positive value.")
		#1 $finish();
	end
endmodule
