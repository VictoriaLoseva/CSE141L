// Design Name:    CSE141L
// Module Name:    COUNTER
//
// Additional Comments: 					  $clog2

module COUNTER (
  input                Clk,
  input                Reset,
  input                WriteEn,
  input                ValIn,
  input  logic  [2:0]  Offset;
  output logic  [7:0]  ValOut
);

logic [7:0] CtrValue;


// combinational reads
always_comb begin
  case(Offset)
    2'b01: ValOut = CtrValue + 30;
    2'b10: ValOut = CtrValue + 60;
    default: Valout = CtrValue;
end

// sequential (clocked) writes
always_ff @ (posedge Clk) begin
  if (Reset) CtrValue <= '0;
  else if (WriteEn) begin
    CtrValue <= ValIn;
  end
end


endmodule
