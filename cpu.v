`include "Fsm/fsm.v"
`include "ALU/alu.v"
`include "ALUV/aluv.v"
`include "Decoder/decoder.v"
`include "Memory/memory.v"
`include "ProgramCounter/programcounter.v"
`include "Register/regfile.v"
`include "SignExtend/signextend.v"

module cpu (
    output wire [31:0] D_a_inspect, D_b_inspect,
    output wire [5:0] op_inspect,

    // Programming mode, optional muxes in order to 
    // program the device. Raise prog_en high to write
    // instructions to memory addresses.
    input [31:0] prog_instruction,
    input [31:0] inst_addr,
    input prog_en,
    input clk,
    input debug,
    input load_mem
);

    // FSM Definitions
    wire [5:0] OP;
    wire RegWrite;
    wire [1:0] RegDest, MemToReg;
    wire [2:0] ALUOp;
    wire ALUSrc; // Mux select

    wire [2:0] ALUVOp;
    wire [2:0] ALUVDtype;
    reg [127:0] WriteDataVec;
    wire VMemWrite;

    reg [31:0] mem_data_addr;
    reg [31:0] mem_data_in;
    reg MemWriteReg;
    wire MemWriteFSM;
    wire MemWrite;

    // ALU Definitions
    wire [31:0] alu_result;
    wire iszero;
    wire overflow;

    wire [31:0] operandA;
    reg [31:0] operandB;

    // Memory Definitions
    reg [31:0] PC;
    wire [31:0] instruction;

    wire [31:0] data_out;
    reg [31:0] data_in;
    reg [31:0] data_addr;

    // Instruction Fetch definitions
    wire [4:0] rs;
    wire [4:0] rt;                    // Connected
    wire [4:0] rd;                     // Connected
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0] imm;
    wire [25:0] jaddr;
    wire [31:0] code;


    // Register Definitions 
    wire [31:0] D_a;                    // Connected
    wire [31:0] D_b;                    // Connected
    wire [31:0] ReadData2b;
    wire [31:0] ReadData2c;
    wire [31:0] ReadData2d;
    reg  [31:0] D_w;                    // Connected
    wire  [4:0] A_a;                    // Connected
    wire  [4:0] A_b;                    // Connected
    reg  [4:0] A_w;                     // Connected


    // Vector Register Definitions
    wire [127:0] ReadData1Vec;
    wire [127:0] ReadData2Vec;


    // General Purpose REG
    regfile #(.WIDTH(32)) REG
    (
        .ReadData1(D_a),            // Connected
        .ReadData2(D_b),            // Connected
        .ReadData2b   (ReadData2b),
        .ReadData2c   (ReadData2c),
        .ReadData2d   (ReadData2d),
        .WriteData(D_w),            // Connected
        .ReadRegister1(rs),            // Connected
        .ReadRegister2(rt),            // Connected
        .WriteRegister(A_w),         // Connected
        .RegWrite(RegWrite),          // Connected From FSM
        .Clk(clk)                    // Connected
    );

    // Vector Register 
    regfile #(.WIDTH(128)) VREG
    (
        .ReadData1    (ReadData1Vec),
        .ReadData2    (ReadData2Vec),
        .WriteData    (WriteDataVec),
        .ReadRegister1(ReadRegister1Vec),
        .ReadRegister2(ReadRegister2Vec),
        .WriteRegister(rs),
        .RegWrite     (VMemWrite),
        .Clk          (clk)
    );

    // Program Counter
    reg [31:0] progrcounter_input_nextaddr;
    wire [31:0] progrcounter_output_addr;

    reg [31:0] jal_linkpoint;

    always @* begin
        if (Jump) begin
            if (ALUSrc == `ALU_SRC_RT) begin // JR instruction - next addr is going to be ALU output
                progrcounter_input_nextaddr = alu_result;
            end else begin // J or JAL instruction
                if (Link) begin
                    jal_linkpoint = progrcounter_output_addr + 32'd8; // JAL is +8
                end
                progrcounter_input_nextaddr = {progrcounter_output_addr[31:28], jaddr<<2};
            end
        end else if (Branch) begin
            if (iszero != InvBranchCond) begin // If the ALU output is zero and we're in BEQ mode or the ALU output is nonzero and we're in BNE mode
                progrcounter_input_nextaddr = progrcounter_output_addr + 4 + (se_out<<2);
            end else begin // J or JAL instruction
                progrcounter_input_nextaddr = progrcounter_output_addr + 32'd4;
            end
        end else if (prog_en) begin // If programming, don't advance program counter
            progrcounter_input_nextaddr = 32'b0;
        end else begin
            progrcounter_input_nextaddr = progrcounter_output_addr + 32'd4;
        end
    end

    programcounter PROGCNT(
        .next_address_out(progrcounter_output_addr),
        .addr_in(progrcounter_input_nextaddr),
        .clk    (clk)
    );

    // Data and Program Counter Memory
    memory MEM( .PC         (progrcounter_output_addr),
                .instruction(instruction), 
                .data_out   (data_out),
                .data_in    (mem_data_in),              // Connected
                .data_addr  (mem_data_addr),            // Connected
                .clk        (clk),                      // Connected
                .wr_en      (MemWrite),
                .load_mem   (load_mem));

    // ALUV
    aluv ALUV(.result(result),
                .iszero  (vIszero),
                .operandA(vOperandA),
                .operandB(vOperandB),
                .command (ALUVOp),
                .dtype   (ALUVDtype));

    // ALU
    alu ALU(.result(alu_result),                        // Connected
            .iszero(iszero), 
            .overflow(overflow), 
            .operandA(D_a),                             // Connected
            .operandB(operandB),                        // Connected
            .command(ALUOp));                           // Connected

    // Instruction Fetch Unit
    decoder dec(OP, rs, rt, rd, shamt, funct, imm, jaddr, instruction); // Assign code to instruction for debugging

    // Sign Extend
    wire [31:0] se_out;
    signextend SE(.se (se_out), .imm(imm));

    // FSM
    fsm FSM(.RegDest(RegDest),
            .RegWrite     (RegWrite),
            .ALUSrc       (ALUSrc),
            .ALUOp        (ALUOp),
            .ALUVOp       (ALUVOp),
            .ALUVDtype    (ALUVDtype),
            .VMemWrite    (VMemWrite),
            .VMemRead     (VMemRead),
            .MemWrite     (MemWriteFSM),
            .MemRead      (MemRead),
            .MemToReg     (MemToReg),
            .Branch       (Branch),
            .InvBranchCond(InvBranchCond),
            .Jump         (Jump),
            .Link         (Link),
            .OP           (OP),
            .funct        (funct));


    ///////////////////////////////////
    //                               //
    //          Wire up cpu          //
    //                               //
    /////////////////////////////////// 

    // Debug
    always @(negedge clk) begin
        if (prog_en) begin
            $display("Programming...");
        end else if (debug) begin
            $display("_________");
            $display("Operand A:", operandA);
            $display("Operand B:", operandB);
            $display("ALUSrc: ", ALUSrc);
            $display("op: ", OP);
            $display("rs: ", rs);
            $display("rt: ", rt);
            $display("rd: ", rd);
            $display("shamt: ", shamt);
            $display("funct: ", funct);
            $display("imm: ", imm);
            $display("D_a: ", D_a);
            $display("D_b: ", D_b);
            $display("SE: ", se_out);
            $display("ALU Result: ", alu_result);
            $display("Program Counter: ", progrcounter_output_addr);
            $display("Current Instruction: %b", instruction);
            $display("Branching: ", Branch);
        end
    end

    // Wire Assignment definitions
    // assign code = Instruction;
    assign MemWrite = MemWriteReg;

    // Signal Multiplexer Definitions

    // ALU Source mux
    always @* begin
        case (ALUSrc)
            `ALU_SRC_IMM: begin 
                        operandB <= se_out;
                    end
            `ALU_SRC_RT: begin
                        operandB <= D_b;
                    end
        endcase
    end

    // Register write mux
    always @* begin
        case (RegDest)
            `REG_DEST_RD: begin 
                    A_w <= rd;
                end
            `REG_DEST_RT: begin
                    A_w <= rt;
                end
            `REG_DEST_LINK: begin
                    A_w <= 5'd31;
                end
        endcase
    end

    // Memory to Register mux
    always @* begin
        case (MemToReg)
            `MEM_TO_REG_FROM_ALU: begin 
                        D_w <= alu_result;
                    end
            `MEM_TO_REG_FROM_MEM: begin
                        D_w <= data_out;
                    end
            `MEM_TO_REG_FROM_PC: begin
                        D_w <= progrcounter_output_addr + 32'd8;
                    end
        endcase
    end

    // Memory to Register mux
    always @* begin
        case (prog_en)
            1'b0: begin 
                        MemWriteReg <= MemWriteFSM;
                        mem_data_addr <= alu_result;
                        mem_data_in <= D_b;
                    end
            1'b1: begin
                        MemWriteReg <= 1'b1;
                        mem_data_addr <= inst_addr;
                        mem_data_in <= prog_instruction;
                    end
        endcase
    end

    // Vector operation mux
    always @* begin
        case (funct)
            `LDV_W: begin
                $display("Writing Vector.");
                $display("Write Vector: %b", VMemWrite);
                WriteDataVec <= {D_b, ReadData2b, ReadData2c, ReadData2d};
                $display("Data Vec: %b", WriteDataVec);
                $display("Write Addr: ", A_w);
                $display("D_b", D_b);
                $display("ReadData2b", ReadData2b);
                $display("ReadData2c", ReadData2c);
                $display("ReadData2d", ReadData2d);

            end
        endcase
    end

endmodule
