`timescale 1ns/ 1ps

// Test bench
// Arithmetic Logic Unit
import Definitions::*;

//
// INPUT: A, B
// op: 000, A ADD B
// op: 100, A_AND B
// ...
// Please refer to definitions.sv for support ops (make changes if necessary)
// OUTPUT A op B
// equal: is A == B?
// even: is the output even?
//

module ALU_tb;

// Define signals to interface with the ALU module
logic [ 7:0] INPUTA;  // data inputs
logic [ 7:0] INPUTB;
logic [ 3:0] op;      // ALU opcode, part of microcode
bit SC_in = 'b0;
logic [ 2:0] imm;
wire[ 7:0] OUT;
wire Zero;
wire OutBit;
wire Parity;

// Define a helper wire for comparison
logic [ 7:0] expected;
logic        expectedParity,
             expectedZero,
             expectedOutBit;


// Instatiate and connect the Unit Under Test
ALU uut(
  .InputA(INPUTA),
  .InputB(INPUTB),
  .OP(op),
  .SC_in(SC_in),
  .imm(imm),
  .Out(OUT),
  .Zero(Zero),
  .OutBit(OutBit),
  .Parity(Parity)
);


// The actual testbench logic
initial begin

  //Test ADD
  INPUTA = 1;
  INPUTB = 1;
  imm = ADD;
  op= 'b00000;    // ADD
  test_alu_func;  // void function call
  #5;

  //Test LSH
  INPUTA = 4;
  INPUTB = 1;
  op= 'b0001;       //LSH
  imm = 'b100;
  test_alu_func;
  #5;

  //Test XOR
  INPUTA = 15;
  INPUTB = 235;
  imm = 'b100;
  op= 'b0010;       //XOR
  test_alu_func;
  #5;

  //Test AND
  INPUTA = 1;
  INPUTB = 1;
  imm = 'b100;
  op= 'b0011;      // AND
  test_alu_func;
  #5;

  //Test FLIP
  INPUTA = 1;
  INPUTB = 1;
  imm = 'b011;
  op= 'b0100;       // FLIP
  test_alu_func;
  #5;

  //Test CPY
  INPUTA = 1;
  INPUTB = 1;
  imm = 'b100;
  op= 'b0101;      // CPY
  test_alu_func;
  #5;

  //Test GETB
  INPUTA = 1;
  INPUTB = 1;
  imm = 'b010;
  op= 'b0110;      // GETB
  test_alu_func;
  #5;

  //Test BXOR
  INPUTA = 189;
  INPUTB = 45;
  imm = 'b100;
  op= 'b0111;      // BXOR
  test_alu_func;
  #5;

  //Test SETB
  INPUTA = 180;
  INPUTB = 45;
  imm = 'b001;
  SC_in = 'b1;
  op= 'b1000;      // SETB
  test_alu_func;
  #5;

end

task test_alu_func;
  case (op)
    ADD : expected = INPUTA + INPUTB;        // add
    LSH : expected = {INPUTA[6:0],SC_in};    // shift left, fill in with SC_in
    // for logical left shift, tie SC_in = 0
    AND : expected = INPUTA & INPUTB;        // bitwise AND
    FLIP: begin
            expected = INPUTA;
            expected[imm] = !expected[imm];         //but INPUTA[imm] = !INPUTA[imm]
          end
    CPY : expected = INPUTA;
    BXOR: expected = INPUTA ^ INPUTB;        // bitwise exclusive O
    SETB: begin
          expected = INPUTA;
          expected[imm] = SC_in;
          end
    default: expected = INPUTA;
  endcase
  #1;


  if( (op == XOR && Parity == ^INPUTA) ||
      (op == GETB && OutBit == INPUTA[imm]) ||
      (OUT  == expected) ) begin
        $display("%t YAY!! inputs = %h %h, opcode = %b, Zero %b",$time, INPUTA,INPUTB,op, Zero);
  end else begin
    $display("%t FAIL! inputs = %h %h, opcode = %b, zero %b",$time, INPUTA,INPUTB,op, Zero);
  end
endtask

initial begin
  $dumpfile("alu.vcd");
  $dumpvars();
  $dumplimit(104857600); // 2**20*100 = 100 MB, plenty.
end

endmodule
