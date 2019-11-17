`define RTYPE_OP 6'b000000

`define VTYPE_OP 6'b000111

`define ADDI_OP 6'b001000
`define XORI_OP 6'b001110

`define LW_OP 6'b100011
`define SW_OP 6'b101011

// I-type instructions
`define BEQ_OP 6'b000100    
`define BNE_OP 6'b000101 

// J-type instructions
`define J_OP 6'b000010      
`define JAL_OP 6'b000011

// R-type instructions
`define JR_FUNCT   6'h8     
`define ADD_FUNCT  6'h20
`define SUB_FUNCT  6'h22
`define XOR_FUNCT  6'h26
`define SLT_FUNCT  6'h2A
`define AND_FUNCT  6'h24
`define NOR_FUNCT  6'h27
`define OR_FUNCT   6'h25


// V-type instructions
`define LDV_B       6'd0    // Unsupported
`define LDV_H       6'd1    // Unsupported
`define LDV_W       6'd2
`define LDV_D       6'd3    // Unsupported
`define LDV_V       6'd4    // Unsupported

`define STV_B       6'd5    // Unsupported
`define STV_H       6'd6    // Unsupported
`define STV_W       6'd7
`define STV_D       6'd8    // Unsupported
`define STV_V       6'd9    // Unsupported

`define ADDV_B      6'd10
`define ADDV_H      6'd11 
`define ADDV_W      6'd12
`define ADDV_D      6'd13
`define ADDV_V      6'd14

`define SUBV_B      6'd15
`define SUBV_H      6'd16 
`define SUBV_W      6'd17
`define SUBV_D      6'd18
`define SUBV_V      6'd19

`define ADDIV_B     6'd20
`define ADDIV_H     6'd21 
`define ADDIV_W     6'd22
`define ADDIV_D     6'd23
`define ADDIV_V     6'd24

`define XORV        6'd25

`define ANDV        6'd26


// ALU commands
`define ADD_  3'd0
`define SUB_  3'd1
`define XOR_  3'd2
`define SLT_  3'd3
`define AND_  3'd4
`define NOR_  3'd6
`define OR_   3'd7

// Vector ALU Data Size
`define BYTE_       3'd0
`define HALFWORD_   3'd1
`define WORD_       3'd2
`define DOUBLEWORD_ 3'd3
`define VECTOR_     3'd4

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
        output reg [2:0] ALUOp, ALUVOp, ALUVDtype,
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
        ALUVOp = `ADD_;
        ALUVDtype = `BYTE_;
        MemWrite = 1'b0;
        MemRead = 1'b0;
        MemToReg = `MEM_TO_REG_FROM_ALU;
        Branch = 1'b0;
        InvBranchCond = 1'b0;
        Jump = 1'b0;
        Link = 1'b0;
        case (OP)
            `VTYPE_OP: begin
                case(funct)
                    `LDV_W: begin
                    end
                    `STV_W: begin
                    end
                    `ADDV_B: begin
                        ALUVOp = `ADD_;
                        ALUVDtype = `BYTE_;
                    end
                    // The rest of ADDV
                    `SUBV_B: begin
                        ALUVOp = `SUB_;
                        ALUVDtype = `BYTE_;
                    end
                    // The rest of SUBV
                    `ADDIV_B: begin
                        ALUVOp = `ADD_;
                        ALUVDtype = `BYTE_;
                    end
                    // The rest of ADDIV
                    `XORV: begin
                        ALUVOp = `XOR_;
                        ALUVDtype = `BYTE_;
                    end
                    `ANDV: begin
                        ALUVOp = `AND_;
                        ALUVDtype = `BYTE_;
                    end
                endcase
            end
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
