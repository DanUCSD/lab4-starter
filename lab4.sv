// Lab 4
// CSE140L
// for use by registered cse140L students and staff only.
// All rights reserved.
module lab4 #(parameter DW=8, AW=8, byte_count=2**AW, lfsr_bitwidth=5)(
    output logic [7:0] encryptByte,
    output logic       validOut,
    input logic        validIn,
    input logic [7:0]  plainByte,
    input logic	       clk, 
		       encRqst,
    output logic       done,
    input logic        rst);
   
   logic taps_en;
   logic lfsr_en;
   logic preambleDone;
   logic incByteCount;
   logic prelenen;
   logic getNext;
   logic seed_en;
   logic incadd;
   logic load_LFSR;
   logic fInValid;
   logic messageDone;

   lab4_dp dp (.*);
   
   seqsm sm (.*);

   
endmodule
