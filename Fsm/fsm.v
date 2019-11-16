// Assembly commands we must support
`define RTYPE_OP 6'b000000

`define ADDI_OP 6'b001000
`define XORI_OP 6'b001110

`define LW_OP 6'b100011
`define SW_OP 6'b101011

`define BEQ_OP 6'b000100 // I-type instructions
`define BNE_OP 6'b000101 

`define J_OP 6'b000010 // J-type instructions
`define JAL_OP 6'b000011

`define JR_FUNCT   6'h8
`define ADD_FUNCT  6'h20
`define SUB_FUNCT  6'h22
`define XOR_FUNCT  6'h26
`define SLT_FUNCT  6'h2A
`define AND_FUNCT  6'h24
`define NOR_FUNCT  6'h27
`define OR_FUNCT   6'h25

// ALU commands
`define ADD_  3'd0
`define SUB_  3'd1
`define XOR_  3'd2
`define SLT_  3'd3
`define AND_  3'd4
`define NOR_  3'd6
`define OR_   3'd7

// Control signal definitions

`define REG_DEST_RT 2'b0
`define REG_DEST_RD 2'b1
`define REG_DEST_LINK 2'b10

`define ALU_SRC_RT 1'b0
`define ALU_SRC_IMM 1'b1

`define MEM_TO_REG_FROM_ALU 2'b0
`define MEM_TO_REG_FROM_MEM 2'b1
`define MEM_TO_REG_FROM_PC 2'b10
/*
* Register write:
* RegDst: Determines if the destination register is Rd or Rt
* RegWrite: Enables a write to a register
* MemtoReg: Determines if the value comes from an ALU result or from memory
*
* Memory access:
* MemRead: Enables memory read (load instructions)
* MemWrite: Enables memory write (store instructions)
*
* ALU operation:
* ALUOp: Specifies either specific ALU operation or that the ALU behavior should be chosen from funct
*
* Source operation fetch:
* ALUSrc: Selects the second source operation for the ALU (either rt or imm)
*
* PC update:
* Branch: Enables loading branch target address into PC, contingent on binary control signal (from ALU)
* InvBranchCond: Whether or not to invert the binary control signal
* Jump: Load jump target address into PC
* Link: Write current PC+4 to $ra
*/


/*
    |-----------+-------------+----------------------+----------+--------------+-------+----------+---------+-------------------+--------+---------------+------+------|
    | Operation | Instruction | RegDst (2-bit)       | RegWrite | ALUSrc       | ALUOp | MemWrite | MemRead | MemToReg  (2-bit) | Branch | InvBranchCond | Jump | Link |
    |-----------+-------------+----------------------+----------+--------------+-------+----------+---------+-------------------+--------+---------------+------+------|
    | 000000    | R-Type      | dest given by Rd (1) | 1        | from Rt (0)  | Funct | 0        | 0       | from ALU (0)      | 0      |               | 0    | 0    |
    | 001000    | addi        | dest given by Rt (0) | 1        | from imm (1) | ADD   | 0        | 0       | from ALU (0)      | 0      |               | 0    | 0    |
    | 001000    | xori        | dest given by Rt (0) | 1        | from imm (1) | XOR   | 0        | 0       | from ALU (0)      | 0      |               | 0    | 0    |
    | 100011    | lw          | dest given by Rt (0) | 1        | from imm (1) | ADD   | 0        | 1       | from mem (1)      | 0      |               | 0    | 0    |
    | 101011    | sw          |                      | 0        | from imm (1) | ADD   | 1        | 0       |                   | 0      |               | 0    | 0    |
    | 000100    | beq         |                      | 0        | from Rt (0)  | SUB   | 0        | 0       |                   | 1      | 0             | 0    | 0    |
    | 000100    | bne         |                      | 0        | from Rt (0)  | SUB   | 0        | 0       |                   | 1      | 1             | 0    | 0    |
    | 000010    | j           |                      | 0        |              |       | 0        | 0       |                   | 0      |               | 1    | 0    |
    | 000000    | jr          |                      | 0        | from imm (1) | ADD   | 0        | 0       |                   | 0      |               | 1    | 0    |
    | 000011    | jal         | link (2)             | 1        |              |       | 0        | 0       | from pc (2)       | 0      |               | 1    | 1    |
    |-----------+-------------+----------------------+----------+--------------+-------+----------+---------+-------------------+--------+---------------+------+------|
*/

// For some input op code, set the control signals
// as output. The control signals should be chosen and
// input into the LUT. NOTE: Every control signal which is not
// X should be set in each case statement. 
module fsm
    (
        output reg  RegWrite, ALUSrc, 
        output reg [1:0] RegDest, MemToReg,
        output reg [2:0] ALUOp, 
        output reg MemWrite, MemRead, Branch, InvBranchCond, Jump, Link,
        input [5:0] OP, 
        input [5:0] funct
    );

    // In each begin/end block, set the control signals
    // for each op code.
    always @(OP, funct) begin
        // Zero everything
        RegDest = `REG_DEST_RT;
        RegWrite = 1'b0;
        ALUSrc = `ALU_SRC_RT;
        ALUOp = `ADD_;
        MemWrite = 1'b0;
        MemRead = 1'b0;
        MemToReg = `MEM_TO_REG_FROM_ALU;
        Branch = 1'b0;
        InvBranchCond = 1'b0;
        Jump = 1'b0;
        Link = 1'b0;
        case (OP)
            `RTYPE_OP:	begin 
                RegDest = `REG_DEST_RD;
                RegWrite = 1'b1;
                ALUSrc = `ALU_SRC_RT; 
                MemToReg = `MEM_TO_REG_FROM_ALU;
                case (funct)
                    `ADD_FUNCT: begin
                        ALUOp = `ADD_;
                    end
                    `SUB_FUNCT: begin
                        ALUOp = `SUB_;
                    end
                    `SLT_FUNCT: begin
                        ALUOp = `SLT_;
                    end
                    `AND_FUNCT: begin
                        ALUOp = `AND_;
                    end
                    `OR_FUNCT: begin
                        ALUOp = `OR_;
                    end
                    `NOR_FUNCT: begin
                        ALUOp = `NOR_;
                    end
                    `XOR_FUNCT: begin
                        ALUOp = `XOR_;
                    end
                    `JR_FUNCT: begin
                        RegWrite = 1'b0;
                        Jump = 1'b1;
                        ALUSrc = `ALU_SRC_RT;
                        ALUOp = `ADD_;
                    end
                endcase
            end
            `ADDI_OP: begin
                RegDest = `REG_DEST_RT;
                RegWrite = 1'b1;
                ALUSrc = `ALU_SRC_IMM;
                ALUOp = `ADD_;
                MemToReg = `MEM_TO_REG_FROM_ALU;
            end
            `XORI_OP: begin
                RegDest = `REG_DEST_RT;
                RegWrite = 1'b1;
                ALUSrc = `ALU_SRC_IMM;
                ALUOp = `XOR_;
                MemToReg = `MEM_TO_REG_FROM_ALU;
            end
            `LW_OP: begin
                RegDest = `REG_DEST_RT;
                RegWrite = 1'b1;
                ALUSrc = `ALU_SRC_IMM;
                ALUOp = `ADD_;
                MemRead = 1'b1;
                MemToReg = `MEM_TO_REG_FROM_MEM;
            end
            `SW_OP: begin
                ALUSrc = `ALU_SRC_IMM;
                ALUOp = `ADD_;
                MemWrite = 1'b1;
            end
            `BEQ_OP: begin
                ALUSrc = `ALU_SRC_RT;
                ALUOp = `SUB_;
                Branch = 1'b1;
            end
            `BNE_OP: begin
                ALUSrc = `ALU_SRC_RT;
                ALUOp = `SUB_;
                Branch = 1'b1;
                InvBranchCond = 1'b1;
            end
            `J_OP: begin
                Jump = 1'b1;
                ALUSrc = `ALU_SRC_IMM;
            end
            `JAL_OP: begin
                Jump = 1'b1;
                Link = 1'b1;
                RegWrite = 1'b1;
                MemToReg = `MEM_TO_REG_FROM_PC;
                RegDest = `REG_DEST_LINK;
                ALUSrc = `ALU_SRC_IMM;
            end
        endcase
    end
endmodule
