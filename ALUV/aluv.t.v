`include "aluv.v"


// Uncomment the `define below to enable dumping waveform traces for debugging
//`define DUMP_WAVEFORM

`define ASSERT_EQ(val, exp, msg) \
  if (val !== exp) $display("[FAIL] %s (got:0b%b expected:0b%b)", msg, val, exp);


module alu_test ();

	wire [127:0] result;
	wire iszero;

	reg [127:0] operandA;
	reg [127:0] operandB;
	reg [2:0] command;
	reg [2:0] dtype;

    reg [127:0] target_result;


	aluv DUT(.result(result),  
			.iszero(iszero), 
			.operandA(operandA), 
			.operandB(operandB), 
			.command(command),
            .dtype(dtype));
	

	 initial begin
	 	    // Optionally dump waveform traces for debugging
	    `ifdef DUMP_WAVEFORM
	      $dumpfile("alu.vcd");
	      $dumpvars();
	    `endif

        dtype = `WORD_;
        operandA = {32'd17,32'd18};
        operandB = {32'd3,32'd2};
        target_result = {32'd17+32'd3, 32'd18+32'd2};

	   	command = `ADD_;
        #10;
	    `ASSERT_EQ(result, target_result, "Test ADD with different numbers.")

        dtype = `BYTE_;
        operandA = {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1};
        operandB = {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1};
        target_result = {8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0,8'd0};
	   	command = `SUB_;
        #10;
	    `ASSERT_EQ(result, target_result, "Test ADD with different numbers.")
	    
	 end

endmodule
