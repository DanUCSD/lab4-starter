module seqsm 
   (
// TODO: define your outputs and inputs
   output [3:0] raddr;
   output lfsr_en;
   output incByteCount;

   input taps_en;
   input preambleDone;

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
   // TODO:  6: ProcessPreamble (encrypt preamble until byteCount is the same as preamble length) ->
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

   typedef enum {
                 Idle, LoadPreamble, LoadTaps, LoadSeed, InitLFSR,
                 ProcessPreamble, Encrypt, Done } state_t;
   
   state_t curState;
   state_t nxtState;

   always_ff @(posedge clk)
     begin
       if (rst)
         curState <= Idle;
       else
         curState <= nxtState;
     end 

   always_comb begin
      /*

      some default values 

      */

      raddr = 4'b000;
      lfsr_en = 0;

      unique case (curState) 

         Idle: begin
            nxtState = LoadPreamble;
         end

         LoadPreamble: begin
            nxtState = taps_en ? LoadTaps : curState;
         end

         LoadTaps: begin

         end

         LoadSeed: begin
         
         end

         InitLFSR: begin
            lfsr_en = 1;
         end

         ProcessPreamble: begin
            incByteCount = 1;
         end

         Encrypt: begin

         end

         Done: begin

         end

      endcase
   end



endmodule // seqsm
