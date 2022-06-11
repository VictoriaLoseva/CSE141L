// Design Name:    CSE141L
// Module Name:   VLUT

// possible lookup table for PC Value
// leverage a few-bit pointer to a wider number
// Lookup table acts like a function: here Value = f(Addr);
// in general, Output = f(Input)
//
// Lots of potential applications of LUTs!!

import Definitions::*;

// You might consider parameterizing this!
module VLUT(
  input        [ 2:0] Row,
  output logic [ 7:0] Value
);

always_comb begin

  case(Row)
    ZERO  : Value = 8'b00000000;
    ONE   : Value = 8'b00000001;
    THIRTY: Value = 8'b00011110;
    SIXTY : Value = 8'b00111100;
    default: Value = 8'b00000000;

  endcase
end

endmodule
