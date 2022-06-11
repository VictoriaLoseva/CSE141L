// Design Name:    CSE141L
// Module Name:    COUNTER
//
// Additional Comments: 					  $clog2

module COUNTER (
  input                Clk,
  input                Reset,
  input                WriteEn,
  input                ValIn,
  output logic  [7:0]  ValOut
);

logic [7:0] CtrValue;


// combinational reads

always_comb begin
    ValOut = ValIn;
end

// sequential (clocked) writes

// Works just like data_memory writes
always_ff @ (posedge Clk) begin
  if (Reset) CtrValue <= '0;
  else if (WriteEn) begin
    CtrValue <= ValIn;
  end
end


endmodule
