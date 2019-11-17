`include "alu.v"


// Uncomment the `define below to enable dumping waveform traces for debugging
//`define DUMP_WAVEFORM

`define ASSERT_EQ(val, exp, msg) \
  if (val !== exp) $display("[FAIL] %s (got:0b%b expected:0b%b)", msg, val, exp);


module alu_test ();

	wire [31:0] result;
	wire carryout;
	wire iszero;
	wire overflow;

	reg [31:0] operandA;
	reg [31:0] operandB;
	reg [2:0] command;


	alu DUT(.result(result),  
			.iszero(iszero), 
			.overflow(overflow), 
			.operandA(operandA), 
			.operandB(operandB), 
			.command(command));
	

	 initial begin
	 	    // Optionally dump waveform traces for debugging
	    `ifdef DUMP_WAVEFORM
	      $dumpfile("alu.vcd");
	      $dumpvars();
	    `endif

	    command = `ADD_; operandA = 32'd21; operandB = 32'd21; #1
	    `ASSERT_EQ(result, 32'd42, "Basic addition: 21 + 21")
	    `ASSERT_EQ(overflow, 1'b0, "No overflow on basic addition.")

	    command = `ADD_; operandA = 32'd2147483647; operandB = 32'd2147483647; #1
	    `ASSERT_EQ(overflow, 1'b1, "Overflow on maximum edge case addition.")

	    command = `SUB_; operandA = 32'd57392; operandB = 32'd4488; #1
	    `ASSERT_EQ(result, 32'd52904, "Basic subtraction.")

	    command = `SUB_; operandA = 32'd1111; operandB = 32'd1112; #1
	    `ASSERT_EQ(result, 32'b11111111111111111111111111111111, "Subtraction, checking twos complement.")

	   	command = `XOR_; operandA = 32'b1111; operandB = 32'b1111; #1
	    `ASSERT_EQ(result, 32'd0, "Test XOR with same numbers.")
	   	
	   	command = `XOR_; operandA = 32'b0011; operandB = 32'b1111; #1
	    `ASSERT_EQ(result, 32'b1100, "Test XOR with different numbers.")

	   	command = `AND_; operandA = 32'b0011; operandB = 32'b1111; #1
	    `ASSERT_EQ(result, operandA & operandB, "Test AND with different numbers.")
	    
	   	command = `SLT_; operandA = 32'b0011; operandB = 32'b1111; #1
	    `ASSERT_EQ(result, 32'b1, "Test SLT with different numbers.")

	    // TODO
	   	command = `NAND_; operandA = 32'b0011; operandB = 32'b1111; #1
	    `ASSERT_EQ(result, ~(operandA & operandB), "Test NAND with different numbers.")
	    
	   	command = `NOR_; operandA = 32'b1101010011; operandB = 32'b100011111; #1
	    `ASSERT_EQ(result, ~(operandA | operandB), "Test NOR with different numbers.")

	   	command = `OR_; operandA = 32'b10011011; operandB = 32'b1111; #1
	    `ASSERT_EQ(result, (operandA | operandB), "Test OR with different numbers.")
	    
	 end

endmodule