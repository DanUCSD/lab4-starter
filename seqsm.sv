module seqsm 
   (
// TODO: define your outputs and inputs
    input logic clk,
    input logic rst
    );


   // TODO: define your states
   // TODO: here is one suggestion, but you can implmenet any number of states
   // TODO: you like
   // TODO: typedef enum {
   // TODO:		 Idle, LoadPreamble, LoadTaps, LoadSeed, InitLFSR, 
   // TODO:		 ProcessPreamble, Encrypt, Done
   // TODO:		 } states_t;
   // TODO: for example
   // TODO:  1: Idle -> 
   // TODO:  2: LoadPreamble (read the preamble from the ROM and capture it in some registers) ->
   // TODO:  3: LoadTaps (read the taps from the ROM and capture it in some registers) ->
   // TODO:  4: LoadSeed (read the seed from the ROM and capture it in some registers) ->
   // TODO:  5: InitLFSR (load the LFSR with the taps and seed) ->
   // TODO:  6: ProcessPremble (encrypt preamble until byteCount is the same as preamble length) ->
   // TODO:  7: Encrypt rest of packet until byteCount == 32 (max packet length)
   // TODO:  8: Done
   // TODO:
   // TODO: implement your state machine
   // TODO:
   // TODO: sequential part
   // TODO: always_ff @(posedge clk) begin 
   // TODO:     . . .
   // TODO: end
   // TODO:
   // TODO: always_comb begin
   // TODO:     . . .
   // TODO: end
endmodule // seqsm
