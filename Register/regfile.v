// WARNING: THIS FILE WAS GENERATED. DO NOT MODIFY

//------------------------------------------------------------------------------
// MIPS register file
//   width: 32 bits
//   depth: 32 words (reg[0] is static zero register)
//   2 asynchronous read ports
//   1 synchronous, positive edge triggered write port
//------------------------------------------------------------------------------
`include "decoder1to32.v"
`include "registerN.v"
`include "registerNzero.v"
`include "muxNto1by32.v"

module regfile
#(parameter WIDTH=32)
(
output[WIDTH-1:0]   ReadData1,  // Contents of first register read
output[WIDTH-1:0]   ReadData2,  // Contents of second register read
input[WIDTH-1:0]    WriteData,  // Contents to write to register
input[4:0]  ReadRegister1,  // Address of first register to read
input[4:0]  ReadRegister2,  // Address of second register to read
input[4:0]  WriteRegister,  // Address of register to write
input       RegWrite,   // Enable writing of register when High
input       Clk,        // Clock (Positive Edge Triggered)
    input[31:0] link_addr
);

    
    wire [31:0] decoded;
    decoder1to32 dec(.out(decoded), .enable (RegWrite), .address(WriteRegister));

    genvar i;
    generate
        for (i=0; i<WIDTH; i=i+1)
        begin:genblock
            wire [WIDTH-1:0] regOut;
            if (i == 0) 
                registerNzero  #(.WIDTH(WIDTH)) regs(.q(regOut), .d(WriteData), .wrenable(decoded[i]), .clk(Clk));
            else
                registerN  #(.WIDTH(WIDTH)) regs(.q(regOut), .d(WriteData), .wrenable(decoded[i]), .clk(Clk));
        end
    endgenerate

    muxNto1by32 #(.WIDTH(WIDTH)) endMux1(.out(ReadData1), .address(ReadRegister1), .input0 (genblock[0].regOut), .input1 (genblock[1].regOut), .input2 (genblock[2].regOut), .input3 (genblock[3].regOut), .input4 (genblock[4].regOut), .input5 (genblock[5].regOut), .input6 (genblock[6].regOut), .input7 (genblock[7].regOut), .input8 (genblock[8].regOut), .input9 (genblock[9].regOut), .input10 (genblock[10].regOut), .input11 (genblock[11].regOut), .input12 (genblock[12].regOut), .input13 (genblock[13].regOut), .input14 (genblock[14].regOut), .input15 (genblock[15].regOut), .input16 (genblock[16].regOut), .input17 (genblock[17].regOut), .input18 (genblock[18].regOut), .input19 (genblock[19].regOut), .input20 (genblock[20].regOut), .input21 (genblock[21].regOut), .input22 (genblock[22].regOut), .input23 (genblock[23].regOut), .input24 (genblock[24].regOut), .input25 (genblock[25].regOut), .input26 (genblock[26].regOut), .input27 (genblock[27].regOut), .input28 (genblock[28].regOut), .input29 (genblock[29].regOut), .input30 (genblock[30].regOut), .input31 (genblock[31].regOut));
    muxNto1by32 #(.WIDTH(WIDTH)) endMux2(.out(ReadData2), .address(ReadRegister2), .input0 (genblock[0].regOut), .input1 (genblock[1].regOut), .input2 (genblock[2].regOut), .input3 (genblock[3].regOut), .input4 (genblock[4].regOut), .input5 (genblock[5].regOut), .input6 (genblock[6].regOut), .input7 (genblock[7].regOut), .input8 (genblock[8].regOut), .input9 (genblock[9].regOut), .input10 (genblock[10].regOut), .input11 (genblock[11].regOut), .input12 (genblock[12].regOut), .input13 (genblock[13].regOut), .input14 (genblock[14].regOut), .input15 (genblock[15].regOut), .input16 (genblock[16].regOut), .input17 (genblock[17].regOut), .input18 (genblock[18].regOut), .input19 (genblock[19].regOut), .input20 (genblock[20].regOut), .input21 (genblock[21].regOut), .input22 (genblock[22].regOut), .input23 (genblock[23].regOut), .input24 (genblock[24].regOut), .input25 (genblock[25].regOut), .input26 (genblock[26].regOut), .input27 (genblock[27].regOut), .input28 (genblock[28].regOut), .input29 (genblock[29].regOut), .input30 (genblock[30].regOut), .input31 (genblock[31].regOut));

    //always @(link_addr) begin

    //end
endmodule
