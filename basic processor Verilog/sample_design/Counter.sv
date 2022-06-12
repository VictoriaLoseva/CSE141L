// Design Name:    CSE141L
// Module Name:    COUNTER
//
// Additional Comments: 					  $clog2

module COUNTER (
  input                Clk,
  input                Reset,
  input                WriteEn,
  input         [7:0]  ValIn,
  input  logic  [1:0]  Offset,
  output logic  [7:0]  ValOut
);

logic [7:0] CtrValue;


// combinational reads
always_comb begin
  if(!WriteEn) begin
    case(Offset)
      2'b01: ValOut = CtrValue + 30;
      2'b10: ValOut = CtrValue + 60;
      default: ValOut = CtrValue;
    endcase
  end
  else
    ValOut = CtrValue;
end

// sequential (clocked) writes
always_ff @ (posedge Clk) begin
  if (Reset) CtrValue <= '0;
  else if (WriteEn) begin
    CtrValue <= ValIn;
  end
end


endmodule
