// Design Name:      CSE141L
// Module Name:      TopLevel

// you will have the same 3 ports
module TopLevel(
  input        Reset,      // init/reset, active high
               Start,      // start next program
               Clk,        // clock -- posedge used inside design
  output logic [7:0] ALUDebug,
  output logic Ack         // done flag from DUT
);


// Declare all the connections between modules.
//
// Generally, naming signals to match where they came from works
// well, i.e. MODULEINSTANCE_SIGNAL_out. This is because there is
// generally only one driver of a connection (enforced by the
// `logic` keyword), but it may fan out to multiple uses.
//
// Note that signals are named after the *instance* of the module
// not the type of the module (because you might instantiate
// multiple copies of certain modules).
//
// It's useful to have all of the connections declared at the top,
// because sometimes wires will 'loop back' (i.e. be needed as an
// input to a module but driven by a module that hasn't been
// declared yet).
//
// Stylistically, try to keep these declarations in the same order
// as the modules below. This will make your life easier.


// InstROM outputs
wire  [ 8:0] IR1_InstOut_out;  // the 9-bit opcode
logic [ 8:0] Active_InstOut;   // the actual Inst being executed

// ProgCtr outputs
wire [ 9:0] PC1_ProgCtr_out;  // the program counter

// LUT outputs
// n.b. "LUT" is a pretty generic name, a nice example
// of how to do a LUT, but your core should call this
// something more informative probably...
wire [ 7:0] VLUT_Value_out;  // LUT value out
wire [ 9:0] ALUT_Target_out; // Label addresses, jump/branch targets

// Control block outputs
logic       Ctrl1_Jump_out;      // to program counter: jump
logic       Ctrl1_BranchEn_out;  // to program counter: branch enable

logic       Ctrl1_MemWrEn_out;   // data_memory write enable

logic       Ctrl1_LoadInst_out;  // TODO: Why both of these?
logic       Ctrl1_Ack_out;       // Done with program?

logic [1:0] Ctrl1_TargSel_out;   // one trick to help with target range
logic       Ctrl1_GotoEn;
logic       Ctrl1_JumpEn;

logic [2:0] ALUT_Row_in;         // LUT row number
logic [4:0] VLUT_Row_in;         // VLUT row number

logic [1:0] Ctrl1_ALUA_Select; // Selects correct Input A
logic [1:0] Ctrl1_ALUB_Select; // Selects correct Input B
logic       Ctrl1_ALUBitValIn_Select;
logic       Ctrl1_RegWriteEn;    // Write to reg enable
logic [2:0] Ctrl1_RFDAtaIn_Select; //Select correct DataIn

logic       Ctrl1_CtrUnitWrite_en;  //Writing to Ctr

logic       Ctrl1_BitWriteEn;       // Write to bit enable
logic [2:0] Ctrl1_BitValIn_Select;  //Select value to write into bit

logic [3:0] Ctrl1_ALUOp;


// Register file outputs
logic [7:0] RF_DataOutA_out; // Contents of first selected register
logic [7:0] RF_DataOutB_out; // Contents of second selected register
logic       RF_Bit_out;      // Contents of bit storage

// ALU outputs
logic [7:0] ALU1_Out_out;
logic       ALU1_Zero_out;
logic       ALU1_Parity_out;
logic       ALU1_Out_bit;

// Data Memory outputs
logic [7:0] DM1_DataOut_out;  // data out from data_memory

logic [ 7:0] ExMem_RegValue_out; // data in to reg file



//Counter/addr unit output
logic [ 7:0] Ctr_Output;

//Bit storage output
logic    BitStore_out;


// Extras
//
// These are not really part of your processor per se, but can be
// useful for diagnostics or performance

logic[15:0] CycleCount; // Count the total number of clock cycles.


////////////////////////////////////////////////////////////////////////////////
// Fetch = Program Counter + Instruction ROM


// Some examples of what DPI and Verilator might enable
//
// Here, we replace the fixed Inst ROM with runtime programmable memory
`ifdef VERILATOR
import "DPI-C" function int add (input int a, input int b);

initial begin
   $display("Basic DPI: %x + %x = %x", 1, 2, add(1,2));
end

import "DPI-C" function int getInstAtAddr (input int DPI_Addr);
export "DPI-C" task writeInstOut;

// Easier to convert here than in CPP
int DPI_Addr = {22'b0, PC1_ProgCtr_out};

int DPI_Inst;
task writeInstOut;
  DPI_Inst = getInstAtAddr(DPI_Addr);
endtask

assign IR1_InstOut_out = DPI_Inst[8:0];

//export "DPI-C" function getCurrentPC;

//function void getCurrentPC(output int Address)
//  Address = PC1_ProgCtr_out;
//endfunction

`else
// instruction ROM -- holds the machine code pointed to by program counter
InstROM #(.W(9)) IR1(
  .InstAddress (PC1_ProgCtr_out),
  .InstOut     (IR1_InstOut_out)
);
`endif

// this is the program counter module
ProgCtr PC1 (
  .Reset       (Reset),              // reset to 0
  .Start       (Start),              // Your PC will have to do something smart with this
  .Clk         (Clk),                // System CLK
  .BranchAbsEn (Ctrl1_Jump_out),     // jump enable
  .BranchRelEn (Ctrl1_BranchEn_out), // branch enable
  .ALU_flag    (ALU1_Zero_out),      // Maybe your PC will find this useful
  .Target      (ALUT_Target_out),    // "where to?" or "how far?" during a jump or branch
  .ProgCtr     (PC1_ProgCtr_out)     // program count = index to instruction memory
);

P
// this is one way to 'expand' the range of jumps available
VLUT VLUT1(
  .Row         (Active_InstOut[2:0]),
  .Value       (VLUT_Value_out)
);


// Note that it may be simpler to handle Start here; depends on your design!
logic should_run_processor;
logic ever_start;

always_ff @(posedge Clk) begin
  if (Reset)
    ever_start <= '0;
  else if (Start)
    ever_start <= '1;
end

always_comb begin
  should_run_processor = ever_start & ~Start;
  Active_InstOut = (should_run_processor) ? IR1_InstOut_out : 9'b111_111_111;
end
/////////////////////////////////////////////////////////////////////// Fetch //



////////////////////////////////////////////////////////////////////////////////
// Decode = Control Decoder + Reg_file

// Control decoder
Ctrl Ctrl1 (
  .Instruction  (Active_InstOut),     // from instr_ROM
  .Jump         (Ctrl1_Jump_out),     // to PC to handle jump/branch instructions
  .BranchEn     (Ctrl1_BranchEn_out), // to PC
  .RegWrEn      (Ctrl1_RegWriteEn),  // register file write enable
  .MemWrEn      (Ctrl1_MemWrEn_out),  // data memory write enable
  .LoadInst     (Ctrl1_LoadInst_out), // selects memory vs ALU output as data input to reg_file
  .Ack          (Ctrl1_Ack_out),      // "done" flag
  .TargSel      (Ctrl1_TargSel_out)   // index into lookup table
);

Ctrl PC1(
    .Instruction   (Active_InstOut),
    .Jump          (Ctrl1_Jump_out),
    .BranchEn      (Ctrl1_BranchEn),
    .MemWrEn       (Ctrl1_Mem),
    .Ack,          (Ctrl1_Ack_Out),
    .RegWrEn       (Ctrl1_RegWriteEn),
    .CtrUnitWriteEn(Ctrl1_CtrUnitWrite_en),
    .BitWriteEn    (Crl1_BitWriteEn),
    .GotoEn        (Ctrl1_GotoEn),
    .Jump2En       (Ctrl1_Jump2En),
    .ALUBitValIn_Select(Ctrl1_ALUBitValIn_Select),
    .ALUA_Select   (Ctrl1_ALUA_Select),
    .ALUB_Select   (Ctrl1_ALUB_Select),
    .BitValIn_Select(Ctrl1_BitValIn_Select),
    .RFDAtaIn_Select(Ctrl1_RFDAtaIn_Select),
    .ALUOp          (Ctrl1_ALUOp)
);

// Output Mux deciding whether ALU, Memory, or VLUT result is used
// for DataIn
logic [ 7:0] RF_Data_In;

MUX MUXDataIn (
  .Select(Ctrl1_RFDAtaIn_Select),
  .Value1(ALU1_Out_out),
  .Value2(DM1_DataOut_out),
  .Value3(VLUT_Value_out),
  .ValueOut(RF_Data_In)
);

// Register file
// A(3) makes this 2**3=8 elements deep
RegFile #(.W(8),.A(3)) RF1 (
  .Clk       (Clk),
  .Reset     (Reset),
  .WriteEn   (Ctrl1_RegWriteEn),
  .RaddrA    (Active_InstOut[4:3]),      // See example below on how 3 opcode bits
  .RaddrB    (Active_InstOut[2:1]),      // could address 16 registers...
  .Waddr     (Active_InstOut[4:3]),      // mux above
  .DataIn    (RF_Data_In),
  .DataOutA  (RF_DataOutA_out),
  .DataOutB  (RF_DataOutB_out)
);

// Also need to hook up the signal back to the testbench for when we're done.
assign Ack = should_run_processor & Ctrl1_Ack_out;
////////////////////////////////////////////////////////////////////// Decode //




////////////////////////////////////////////////////////////////////////////////
// Execute + Memory = ALU + DataMem
//
// Note: You do not need to structure blocks in the same way as the sample code.
//       Your procesor may wish to do something else (but does not have to).

// You can declare local wires if it makes sense, for instance
// if you need an local mux for the input
logic [ 7:0] InA, InB;      // ALU operand inputs

//Output Mux deciding whether RegOutA or Ctr is used for ALU A
logic [ 7:0]  ALU_A_In;

MUX MUXA (
   .Select(Ctrl1_ALUA_Select),
   .Value1(RF_DataOutA_out),
   .Value2(Ctr_Output),
   .Value3(8'b00000000),
   .ValueOut(ALU_A_In)
);

//Output Mux deciding whether RegOutB, imm, or VLUT is used for ALU B
logic [ 7:0] ALU_B_In;

MUX MUXB (
   .Select(Ctrl1_ALUB_Select),
   .Value1(RF_DataOutB_out),
   .Value2({5'b00000,Active_InstOut[2:0]}),
   .Value3(VLUT_Value_out),
   .ValueOut(ALU_B_In)
);


//MUX for deciding which value to use in ALU: 0 => 0, 1 => BitStorage
logic Bit_Val_in;
assign Bit_Val_in = (!Ctrl1_ALUBitValIn_Select ? 1'b0 : BitStore_Out);


ALU ALU1 (
  .InputA(ALU_A_In),
  .InputB(ALU_B_In),
  .Op(Ctrl1_ALUOp),
  .SC_in(Bit_Val_in),
  .imm(Active_InstOut[2:0]),
  .Out(ALU1_Out_out),
  .Zero(ALU1_Zero_out),
  .OutBit(ALU1_Out_bit),
  .Parity(ALU1_Parity_out)
  );

logic [7:0] Ctr_To_Mem;

COUNTER CTR1(
   .Clk(Clk),
   .Reset(Reset),
   .WriteEn(Ctrl1_CtrUnitWrite_en),
   .Offset(Active_InstOut[2:1]),
   .ValIn(ALU1_Out_out),
   .ValOut(Ctr_To_Mem)
);


//Output Mux deciding whether BitOut, Parity, or Zero are stored
logic        BitStorage_In;

always_comb begin
  case(Ctrl1_BitValIn_Select)
    2'b01:   BitStorage_In = ALU1_Parity_out;  //XOR
    2'b10:   BitStorage_In = ALU1_Out_bit;     //GETB
    default: BitStorage_In = 1'b0;             //reset bit
  endcase
end

BitStorage BITST(
  .Clk(Clk),
  .Reset(Reset),
  .WriteEn(Ctrl1_BitWriteEn),
  .BitValIn(BitStorage_In),
  .BitOut(BitStore_out)
);

DataMem DM1(
  .DataAddress  (Ctr_To_Mem),
  .WriteEn      (Ctrl1_MemWrEn_out),
  .DataIn       (RF_DataOutA_out),
  .DataOut      (DM1_DataOut_out),
  .Clk          (Clk),
  .Reset        (Reset)
);

//////////////////////////////////////////////////////////// Execute + Memory //


////////////////////////////////////////////////////////////////////////////////
// Extras

// count number of cycles executed
// not part of main design, potentially useful for performance measure...
// This one halts when Ack is high
always_ff @(posedge Clk)
  if (Reset)   // if(start) ?
    CycleCount <= 0;
  else if(Ctrl1_Ack_out == 0)   // if(!halt) ?
    CycleCount <= CycleCount + 'b1;
endmodule
