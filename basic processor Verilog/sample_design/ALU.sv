// Module Name:    ALU
// Project Name:   CSE141L
//
// Additional Comments:
//   combinational (unclocked) ALU

// includes package "Definitions"
import Definitions::*;

module ALU #(parameter W=8, Ops=4)(
  input        [W-1:0]   InputA,       // data inputs
                         InputB,
  input        [Ops-1:0] OP,           // ALU opcode, part of microcode
  input                  SC_in,        // shift or carry in
  input        [  2: 0]  imm,
  output logic [W-1:0]   Out,          // data output
  output logic           Zero,         // output = zero flag    !(Out)
                         OutBit,       // outparity flag        ^(Out)
                         Parity
                         // you may provide additional status flags, if desired
);

// type enum: used for convenient waveform viewing
op_mne op_mnemonic;

always_comb begin
  // No Op = default
  Out = 0;
  OutBit = 'bx;

  case(OP)
    ADD : Out = InputA + InputB;        // add
    LSH : Out = {InputA[6:0],SC_in};    // shift left, fill in with SC_in
    // for logical left shift, tie SC_in = 0
    AND : Out = InputA & InputB;        // bitwise AND
    FLIP: begin
            Out = InputA;
            Out[imm] = !Out[imm];         //but InputA[imm] = !InputA[imm]
          end
    CPY : Out = InputB;
    GETB: OutBit = InputA[imm];
    BXOR: begin Out = InputA ^ InputB; end
    SETB: begin
          Out = InputA;
          Out[imm] = SC_in;
          end
    default : begin Out = 8'bxxxx_xxxx; end      // Quickly flag illegal ALU
  endcase

end

assign Zero   = ~|Out;                  // reduction NOR
assign Parity = ^InputA;                   // reduction XOR
assign reset = 0;

// Toolchain guard: icarus verilog doesn't support this debug feature.
`ifndef __ICARUS__
always_comb
  op_mnemonic = op_mne'(OP);            // displays operation name in waveform viewer
`endif

endmodule
