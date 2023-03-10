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
   output logic done,
   output logic validOut,

   input logic fInValid,
   input logic preambleDone,
   input logic encRqst,
   input logic messageDone,

   input logic clk,
   input logic rst
   );

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
    incadd = 0;
	lfsr_en = 0; 
	incByteCount = 0;
	prelenen = 0;
	taps_en = 0;
	seed_en = 0;
	load_LFSR = 0;
	getNext = 0;
	done = 0;
	validOut = 0;

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
            taps_en = 1;
            incadd = 1;
            nxtState = LoadSeed;
         end

         LoadSeed: begin
            seed_en = 1;
            incadd = 1;
            nxtState = InitLFSR;
         end

         InitLFSR: begin
            load_LFSR = 1;
            nxtState = ProcessPreamble;
         end

         ProcessPreamble: begin
            if (fInValid) begin          
               incByteCount = 1;
               getNext = 1;
               lfsr_en = 1;
               validOut = 1;
            end 
            if (preambleDone) begin
               nxtState = Encrypt;  
            end else begin
               nxtState = ProcessPreamble; 
            end
         end

         Encrypt: begin
            if (fInValid) begin          
               incByteCount = 1;
               getNext = 1;
               lfsr_en = 1;
               validOut = 1;
            end 
            if (messageDone) begin
               nxtState = Done;
            end else begin
               nxtState = Encrypt; 
            end
         end

         Done: begin
            done = 1;
           	nxtState = Done;
         end

      endcase
   end



endmodule // seqsm
