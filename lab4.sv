// Lab 4
// CSE140L
// for use by registered cse140L students and staff only.
// All rights reserved.
module lab4 #(parameter DW=8, AW=8, byte_count=2**AW, lfsr_bitwidth=5)(
    output logic [7:0] encryptByte,   // encrypted byte
    output logic       validOut,      // encrypted byte is valid
    input logic        validIn,   // plainByte is valid                          --- high when plainByte represents a byte from input strean.
    input logic [7:0]  plainByte, // byte to be encrypted
    input logic	       clk, 
		       encRqst,   // incoming encryption request
    output logic       done,      // encryption is complete
    input logic        rst);
   

   // TODO: declare the wires that are *outputs* of the control and datapath that are not
   // TODO: primary outputs module lab4.

   // TODO: you can use the "logic" type or "wire" type
   // TODO: for example, if your datapath has an output taps_en.
   // TODO: wire taps_en;  // load the taps

   logic taps_en;
   logic lfsr_en;
   logic [3:0] raddr;
   
   //
   // datapath
   // This instantiates your datapath block. the .* says that all the ports on your block connect to wires
   // at this level with the same name. For example, if you block as an input called taps_en,
   // that port will connect to a wire called taps_en.  This is the same thing as saying
   // .taps_en(taps_en)  but a lot more concise.
   // 
   lab4_dp dp (.*                       //--- first few, still need to figure out more
   );
   
   //
   // control
   // Instantiated your statemachine (control logic).
   seqsm sm (.*);
   
/* **************************************************
Here is what you need to think about

 0) read the parameters from the ROM. You will read
   - preamble length from address 0
   - the LFSR taps from address 1 
   - the starting LFSR value from address 2
     you may want some sort of counter to count the read address
      0, 1, 2  or just set the readaddress thru some muxes or 
      provide the address from your state machine directly.

  For each of these you want capture the value into some register so that
  the needed values are available w/o having to read the ROM again.

 1) Load/initalize the LFSR
  
 2) for pre_len cycles, bitwise XOR ASCII _ = 0x7E with current
    LFSR state; prepend LFSR state with 3'b00 to pad to 8 bits
    send each successive result to the output
    advance LFSR to next state while writing result  

 3) after pre_len operations, 
    bitwise XOR each value w/ current LFLSR state
    OR a 1 into bit-7
    send each successive result to the output
    advance LFSR to next state while writing each result

   ------------------
  - Your logic should go in seqsm.sv or lab4_dp.sv.  This top level module just connects
  things together.
  - You might want to see how the testbench - lab4_tb.sv - generates the encrypted output which
  it uses to test against your design.

****************************************************** */
   
endmodule
