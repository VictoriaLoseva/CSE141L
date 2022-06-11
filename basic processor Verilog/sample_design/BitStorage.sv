// Design Name:    CSE141L
// Module Name:    BitStorage
//
// Additional Comments: 					  $clog2

module BitStorage (
  input                Clk,
  input                Reset,
  input                WriteEn,
  input                BitValIn,
  output logic         BitOut
);

logic BitStorage;


// combinational reads

always_comb begin
    BitOut = BitStorage;
end

// sequential (clocked) writes
//
// Works just like data_memory writes
always_ff @ (posedge Clk) begin
  if (Reset) BitStorage <= '0;
  else if (WriteEn) begin
    BitStorage <= BitValIn;
  end
end


endmodule
