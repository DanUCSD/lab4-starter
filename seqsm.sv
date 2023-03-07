module seqsm 
   (
// TODO: define your outputs and inputs
//   output [3:0] raddr;
   output logic incadd,
   output logic lfsr_en,
   output logic incByteCount,
   output logic prelenen,
   output logic taps_en,
   output logic seed_en,
   output logic load_LFSR,
   output logic getNext,

   input logic byteCount,
   input logic fInValid,
   input logic preambleDone,
   input logic encRqst,

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
   // TODO:  1: Idle -> encrypt request input. 
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

      unique case (curState) 

         Idle: begin
            if (encRqst) begin
               nxtState  = LoadPreamble;
            end else begin
               nxtState = Idle;
            end
         end

         LoadPreamble: begin
            prelenen = 1;
            incadd = 1;
            nxtState = LoadTaps;
         end

         LoadTaps: begin
            incadd = 1;
            taps_en = 1;
            nxtState = LoadSeed;
         end

         LoadSeed: begin
            seed_en = 1;
            nxtState = InitLFSR;
         end

         InitLFSR: begin
            load_LFSR = 1;
            nxtState = ProcessPreamble;
         end

         ProcessPreamble: begin
            incByteCount = 1;
            getNext = 1;
            if (fInValid) begin          
               // do something turn on enable  signals
                           lfsr_en = 1;
               // 3 more signals, similar in encrypt.
            end 
            if (preambleDone) begin
               nxtState = Encrypt;       // if preambledone
            end else begin
               nxtState = ProcessPreamble;          // else stay in state
            end
         end

         Encrypt: begin // same thing as above but  different signals -> preambleDone (messageDone)
            getNext =  1;
            lfsr_en = 1;
         end

         Done: begin
            
         end

      endcase
   end



endmodule // seqsm
