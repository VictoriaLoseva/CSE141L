// Design Name:    CSE141L
// Module Name:    MUX

// Selectors

import Definitions::*;

module MUX #(W=8)(
  input        [  1:0] Select,
  input  logic [W-1:0] Value1,
  input  logic [W-1:0] Value2,
  input  logic [W-1:0] Value3,
  output logic [W-1:0] ValueOut
);

always_comb begin

  case(Select)
    2'b00: ValueOut = Value1;
    2'b01: ValueOut = Value2;
    2'b10: ValueOut = Value3;
    default: ValueOut = W'(0);

  endcase
end

endmodule
