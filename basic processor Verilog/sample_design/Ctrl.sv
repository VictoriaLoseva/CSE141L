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
  output logic       Jump,
                     BranchEn,
                     MemWrEn,
                     LoadInst,
                     Ack,      // "done with program"
                     RegWrEn,
                     CtrUnitWriteEn,
                     BitWriteEn,
                     GotoEn,
                     Jump2En,
                     ALUBitValIn_Select;
  output logic [1:0] ALUA_Select,
                     ALUB_Select,
                     BitValIn_Select,
  output logic [2:0] ALUT_Row_in,
                     RFDAtaIn_Select,
                     CtrOffset,
  output logic [3:0] ALUOp,
  output logic [4:0] VLUT_Row_in
);

always_comb begin
  //First let's set some default values, like turning all writing off
  Jump = 1'b0;
  BranchEn = 1'b0;
  MemWrEn= 1'b0;
  LoadInst = 1'b0;
  Ack = 1'b0;
  RegWrEn = 1'b0;
  CtrUnitWriteEn = 1'b0;
  BitWriteEn = 1'b0;
  GotoEn = 1'b0;
  Jump2En = 1'b0;

  ALUA_Select = 2'b00;
  ALUB_Select = 2'b00;
  ALUT_Row_in = 3'b000;
  RFDAtaIn_Select = 3'b00;
  BitValIn_Select = 3'b000;
  CtrOffset = 3'b000;
  ALUOp = 4'b000;
  VLUT_Row_in = 5'b00000;


  //Next, go Instruction by instruction to assign actual values

  case(Instruction[8:6])
    4'b0000: begin                        //Load word
        RegWrEn = 1'b1;
        CtrOffset = Insruction[2:1];
      end
    4'b0001: begin                        //Inc
        CtrUnitWriteEn = 1'b1;
        ALUOp = ADD;
        ALUA_Select = 2'b01;
        ALUB_Select = 2'b10;
        VLUT_Row_in = ONE;
      end
    4'b0010: begin                        //luv
        RegWrEn = 1'b1;
        RFDAtaIn_Select = 2'b00;
        ALUOp = CPY;
        RFDAta_In_Select = 2'b10;
      end
    4'b0011: begin                        //and
       RegWrEn = 1'b1;
       RFDAta_In_Select = 2'b00;
       ALUOp = AND;
       ALUA_Select = 2'b00;
       ALUB_Select = 2'b00;
      end
    4'b0100: begin                        //cpy
        RegWrEn = 1'b1;
        RFDAta_In_Select = 2'b00;
        ALUOp = CPY;
        ALUA_Select = 2'b00;
      end
    4'b0101: begin                        //sb
        RegWrEn = 1'b1;
        RFDAta_In_Select = 2'b00;
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
        RFDAta_In_Select = 2'b00;
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
        ALUB_Select = 2'10;
        ALUOp = BXOR;
        Jump2En = 1'b1;
        //TODO: add Jump2En && Zero in TopLevel
      end
    4'b1010: begin                        //shr
       ALUOp = SHR;
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
        CtrOffset = Insruction[2:1];
      end

end














// instruction = 9'b110??????;
assign MemWrEn = Instruction[8:6] == 3'b110;

assign RegWrEn = Instruction[8:7] != 2'b11;
assign LoadInst = Instruction[8:6] == 3'b011;



// jump on right shift that generates a zero
// equiv to simply: assign Jump = Instruction[2:0] == RSH;
always_comb begin
/*  if(Instruction[2:0] == RSH) begin
    Jump = 1;
  end else begin
    Jump = 0;
  end */
end

// branch every time instruction = 9'b?????1111;
assign BranchEn = &Instruction[3:0];

// Maybe define specific types of branches?
assign TargSel  = Instruction[3:2];

endmodule
