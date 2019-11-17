
# CompArch Lab 4: Vector Operations on a Single Cycle CPU

The goal of this lab is to support some Single Instruction Multiple Data operations in hardware. We will be very loosely following the [MIPS SIMD whitepaper](https://s3-eu-west-1.amazonaws.com/downloads-mips/documents/MD00926-2B-MSA-WHT-01.03.pdf). 

## SIMD Architecture ##

SIMD adds a new type of instruction, a vector instruction, which operates on a special set of registers. These registers are 128 bits wide, and there are 32 of them. There exists a possibility of using Virtual Processing Elements (VPEs) in which fewer than 32 registers can be implemented, but for the sake of simplicity we will ignore these, and simply build all 32. There is another option to have the 128 bits share 64 bits of an Floating Point Unit, which we will also not implement for simplicity. Vector operations operate on the vector registers, but with the additional constraint of a data-type indication which indicates how the 128 bits should be partitioned. There are 5 types of partitions. 

| Data Format        | Abbreviation  |   Op-Code Value  |
| :----------------: |:-------------:|:----------------:|
| Byte, 8-bit        | b             | 0                |
| Halfword, 16-bit   | h             | 1                |
| Word, 32-bit       | w             | 2                |
| Doubleword, 64-bit | d             | 3                |
| Vector, 32-bit     | v             | 4                |

Vector operations are coded to operate on the 128 bit register with these distinctions in mind. For example, ADDVI can be coded as ADDVI.B, ADDVI.H, ADDVI.W, ADDVI.D, or ADDVI.V to add an immediate to the various sizes of argument. Vecotr operations can operate between vector registers as well. `addv.w   $w5,$w1,$w2` for instance, adds each word in `$w1` to each word in `$w2` and places the result in `$w5`. ADDVI.df represents the ADDVI operation for all supported data formats. For simplicity, we will be implementing load and store operations that act on Words only, and arithmetic operations that work on all data types. Operations exist to load general purpose registers (GPR) to the vector registers in various ways. `fill.w   $w6,$2` loads the 32 bit GPR `$2` into each word in `w6`. All vector registers are temporary, in that they need to be callee-saved by convention. 

The vector instructions will be coded by the 4 MSB's as equal to `0111` which is unused in MIPS. The vector op-code will be given by the next 8 bits `[27:20]`. We will be deviating from the MIPS SIMD for our specific implementation, choosing a set of useful vector operations to implement.

NOTE: For operations that work on multiple data formats, their vector op-code is given by the base op code plus the Op-Code Value given in the table above. 

LDV.W: Load Vector from four adjacent GPRs as words.

 - Format: `$d = {$s, $s+1, $s+2, $s+3}`     
 - `0111 00000010 ddddd sssss 0000000000`    
 - `$d` is the destination Vector register     
 - `$s` is the start source register, where `$s`, `$s+1`, `$s+2`, `$s+3` are all
   loaded.
   
STV.W: Store Vector into a group of four GPRs.  

 - Format: `$d, $d+1, $d+2, $d+3 = $s`
 - `0111 00000111 ddddd sssss 0000000000`
 - `$d` is the destination start GPR, where `$d`, `$d+1`, `$d+2`, `$d+3` are all stored.
 - `$s` is the source Vector register
  
ADDV.df: Add two Vectors togeather, according to data type.

 - Format: `$d = $a + $b`
 - `0111 00001010[+ Op-Code Value]  ddddd aaaaa bbbbb 00000`
 - `$d` is the destination Vector register
 - `$a` is the first source Vector register
 - `$b` is the second source Vector register

SUBV.df: Subtract two vectors, word-wise.

 - Format: `$d = $a - $b`
 - `0111 00001111[+ Op-Code Value] ddddd aaaaa bbbbb 00000`
 - `$d` is the destination Vector register
 - `$a` is the first source Vector register
 - `$b` is the second source Vector register

ADDIV.df: Add an immediate to a vector.

 - Format: `$d = $s + imm`
 - `0111 00010100[+ Op-Code Value] ddddd sssss iiiiiiii`
 - `$d` is the destination Vector register
 - `$s` is the source Vector register
 - `i` is the immediate value

XORV: Bitwise XOR on two vectors.

 - Format: `$d = $a | $b`
 - `0111 00011001 ddddd aaaaa bbbbb 00000`
 - `$d` is the destination Vector register
 - `$a` is the first source Vector register
 - `$b` is the second source Vector register

ANDV: Bitwise AND on two vectors.

 - Format: `$d = $a & $b`
 - `0111 0011010 ddddd aaaaa bbbbb 00000`
 - `$d` is the destination Vector register
 - `$a` is the first source Vector register
 - `$b` is the second source Vector register

