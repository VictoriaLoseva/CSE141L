// Project Name:   CSE141L
// Module Name:    Ctrl
// Create Date:    ?
// Last Update:    2022.01.13

// control decoder (combinational, not clocked)
// inputs from ... [instrROM, ALU flags, ?]
// outputs to ...  [program_counter (fetch unit), ?]

import Definitions::*;

// n.b. This is an example / starter block
//      Your processor **will be different**!
module Ctrl (
  input  [8:0] Instruction,    // machine code
                               // some designs use ALU inputs here
  output logic       MemWrEn,
                     Ack,      // "done with program"
                     RegWrEn,
                     CtrUnitWriteEn,
                     BitWriteEn,
                     GotoEn,
                     Jump2En,
                     ALUBitValIn_Select,
  output logic [1:0] ALUA_Select,
                     ALUB_Select,
                     BitValIn_Select,
                     RFDAtaIn_Select,
  output logic [3:0] ALUOp

);

always_comb begin
  //First let's set some default values, like turning all writing off
  MemWrEn= 1'b0;
  RegWrEn = 1'b0;
  CtrUnitWriteEn = 1'b0;
  BitWriteEn = 1'b0;
  GotoEn = 1'b0;
  Jump2En = 1'b0;
  Ack = 1'b0;

  ALUA_Select = 2'b00;
  ALUB_Select = 2'b00;
  ALUBitValIn_Select = 0;
  RFDAtaIn_Select = 3'b00;
  BitValIn_Select = 3'b000;
  ALUOp = 4'b000;

  if(&Instruction) Ack = 1'b1;

  //Next, go Instruction by instruction to assign actual values

  case(Instruction[8:5])
    4'b0000: begin                        //Load word
        RegWrEn = 1'b1;
        RFDAtaIn_Select = 2'b01;

      end
    4'b0001: begin                        //Inc
        CtrUnitWriteEn = 1'b1;
        ALUOp = ADD;
        ALUA_Select = 2'b01;
        ALUB_Select = 2'b10;
      end
    4'b0010: begin                        //luv
        RegWrEn = 1'b1;
        RFDAtaIn_Select = 2'b00;
        ALUOp = CPY;
        ALUA_Select = 2'b10;
      end
    4'b0011: begin                        //and
       RegWrEn = 1'b1;
       RFDAtaIn_Select = 2'b00;
       ALUOp = AND;
       ALUA_Select = 2'b00;
       ALUB_Select = 2'b00;
      end
    4'b0100: begin                        //cpy
        RegWrEn = 1'b1;
        RFDAtaIn_Select = 2'b00;
        ALUOp = CPY;
        ALUB_Select = 2'b00;
      end
    4'b0101: begin                        //sb
        RegWrEn = 1'b1;
        RFDAtaIn_Select = 2'b00;
        ALUOp = SETB;
        ALUA_Select = 2'b00;
        ALUBitValIn_Select = 1'b1;
      end
    4'b0110: begin                        //gb
        BitWriteEn = 1'b1;
        BitValIn_Select = 2'b10;
        ALUOp = GETB;
        ALUA_Select = 2'b00;
        ALUB_Select = 2'b01;
      end
    4'b0111: begin                        //flip
        RegWrEn = 1'b1;
        RFDAtaIn_Select = 2'b00;
        ALUOp = FLIP;
        ALUA_Select = 2'b00;
        ALUB_Select = 2'b01;
      end
    4'b1000: begin                        //xor
        BitWriteEn = 1'b1;
        BitValIn_Select = 2'b10;
        ALUOp = XOR;
        ALUA_Select = 2'b00;
        ALUB_Select = 2'b01;
        ALUBitValIn_Select = 1'b1;
      end
    4'b1001: begin                        //loop
        ALUA_Select = 2'b01;
        ALUB_Select = 2'b10;
        ALUOp = BXOR;
        Jump2En = 1'b1;
      end
    4'b1010: begin                        //lsh
       ALUOp = LSH;
       ALUA_Select = 2'b00;
       ALUBitValIn_Select = 1'b0;
       RegWrEn = 1'b1;
       RFDAtaIn_Select = 2'b00;
      end
    4'b1011: begin                        //goto
       GotoEn = 1;
      end
    4'b1100: begin                        //beq
        ALUOp = BXOR;
        ALUA_Select = 2'b00;
        ALUB_Select = 2'b00;
        Jump2En = 1'b1;
      end
    4'b1101: begin                        //rb
        BitWriteEn = 1;
        BitValIn_Select = 2'b00;
      end
    4'b1110: begin                        //sw
        MemWrEn = 1'b1;
      end
    endcase
  end
endmodule
