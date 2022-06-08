// Create Date:    2018.10.15
// Module Name:    ALU 
// Project Name:   CSE141L
//
// Revision 2022.04.30
// Additional Comments: 
//   combinational (unclocked) ALU
import definitions::*;			         // includes package "definitions"
module ALU_enum #(parameter W=8)(
  input        [W-1:0] InputA,           // data inputs
                       InputB,
  input        [  2:0] OP,		         // ALU opcode, part of microcode
  input                SC_in,            // shift or carry in
  output logic         SC_out,           // shift or carry out
  output logic [W-1:0] Out,		         // or:  output reg [7:0] OUT,
  output logic         PF,               // reduction parity
  output logic         Zero              // output = zero flag
           // you may provide additional status flags, if desired
    );								    
  op_mne op;
//  logic[2:0] op = `op_mne;	 
  always_comb begin
// list default (no op) values of all outputs
    Out = 'b0; 
    SC_out = 1'b0;                       
    case(op)
      ADD : {SC_out,Out} = {1'b0,InputA} + InputB;      // add 
      LSH : {SC_out,Out} = {InputA[7:0],SC_in};  // shift left, fill in with SC_in 
// for logical left shift, tie SC_in = 0
 	  BSH : Out = {InputA[W-2:0],InputA[W-1]};  // barrel shift left
 	  XOR : Out = InputA ^ InputB;      // exclusive OR
      AND : Out = InputA & InputB;      // bitwise AND
    endcase
  end

  always_comb							  // assign Zero = !Out;
    case(Out)
      'b0     : Zero = 1'b1;
	  default : Zero = 1'b0;
    endcase

  always_comb
    PF = ^Out;  // Out[7]^Out[6]^...^Out[0]           // reduction XOR 

endmodule

