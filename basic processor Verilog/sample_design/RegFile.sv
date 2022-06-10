// Create Date:    2019.01.25
// Last Update:    2022.01.13
// Design Name:    CSE141L
// Module Name:    reg_file
//
// Additional Comments: 					  $clog2

// n.b. parameters are compile time directives this can be an any-width,
// any-depth `reg_file`: just override the params!
//   W = data path width          <-- [WI22 Requirement: max(W)=8]
//   A = address pointer width    <-- [WI22 Requirement: max(A)=4]
module RegFile #(parameter W=8, A=2)(
  input                Clk,
  input                Reset,
  input                WriteEn,
  input                bitValIn,
  input                uppOrLow,
  input        [A-1:0] RaddrA,    // address pointers
  input        [A-1:0] RaddrB,    // address pointers
  input        [A-1:0] Waddr,     // address pointers
  input        [W-1:0] DataIn,    // data for registers
  output logic [W-1:0] DataOutA,
  output logic [W-1:0] DataOutB   // DataOut
);


// W bits wide [W-1:0] and 2**A registers deep
//   When W=8 bit wide registers and A=4 to address 16 registers
//   then this could be written `logic [7:0] registers[16]`
logic [W-1:0] Registers[5];


// combinational reads

// This is MIPS-style registers (i.e. r0 is always read-as-zero)
always_comb begin
  if ((RaddrA == 'b00) || (RaddrA == 'b11)) begin
    DataOutA = Registers[{RaddrA,uppOrLow}];
  end else begin
    DataOutA = Registers[{RaddrA,1'b0}];
  end

  if ((RaddrB == 'b00) || (RaddrA == 'b11)) begin
    DataOutB = Registers[{RaddrA,uppOrLow}];
  end else begin
    DataOutB = Registers[{RaddrB,1'b0}];
  end
end

// FIXME: ^^ Careful! ^^
//   You probably don't want different register output
//   ports to behave differently in your final design!!
//
//   ... or maybe you do, can be a neat trick for more
//   compact encoding to have them behave different...
//   (but almost certainly not exactly like this)


// sequential (clocked) writes
//
// Works just like data_memory writes
always_ff @ (posedge Clk) begin
  integer i;
  if (Reset) begin
    for (i=0; i<5; i=i+1) begin
      Registers[i] <= '0;
    end
  end else if (WriteEn) begin
    if(Waddr == 'b01 || Waddr == 'b10) Registers[{Waddr,1'b0}] <= DataIn;
    else Registers[{Waddr,uppOrLow}] <= DataIn;
  end
end


endmodule
