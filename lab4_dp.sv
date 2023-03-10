module lab4_dp #(parameter DW=8, AW=4, lfsr_bitwidth=5) (
// TODO: Declare your ports for your datapath
// TODO: for example							 
// TODO: output logic [7:0] encryptByte, // encrypted byte output
// TODO: ... 
// TODO: input logic 	      clk,     // clock signal 
// TODO: input logic 	      rst      // reset

   output logic [7:0]   encryptByte,   // encrypted byte output
   output logic         preambleDone,  // guess
   output logic         fInValid,
   output logic         messageDone,

   input logic          seed_en,       // guess
   input logic          taps_en,       // suggested in lab4.sv
   input logic          prelenen,      // output from seqsm.sv
   input logic [7:0]    plainByte,     // input for fifo from lab4.sv
   input logic          validIn,       // input for fifo from lab4.sv
   input logic          lfsr_en,       // controlling from init_lfsr in seqsm.sv
   input logic          incByteCount,
   input logic          load_LFSR,
   input logic          incadd,
   input logic          getNext,       // input from lab4


   input logic          clk,           // clock signal
   input logic          rst            // reset

   );
   
   //
   // ROM interface wires
   //
   wire [DW-1:0] data_out;        // from dat_mem

   logic [lfsr_bitwidth-1:0] taps;       // LFSR feedback pattern temp register
   logic [lfsr_bitwidth-1:0] LFSR;            // LFSR current value    
   logic [3:0] preambleLength;
   logic [4:0] start_LFSR;
   logic [7:0] byteCount;

   logic [AW-1:0] 	       raddr;    // memory read address

//   assign raddr = incadd ? raddr + 1 : 0;
  
//  assign raddr = rst ? 0 : raddr + 1;
 
   always_comb begin
     if (rst) begin
       raddr = 0;
     end else if (incadd) begin
       raddr = raddr + 1;
     end else begin
       raddr = raddr + 1;
     end
   end

//   assign incByteCount = raddr > 2;
  
   //
   // FIFO
   // This fifo takes data from the outside (testbench) and captures it
   // Your logic reads from this fifo.
   //
   logic [7:0] 		       fInPlainByte;
   logic MSB;
   assign MSB = preambleDone ? 1 : 0;
 		       
   fifo fm (
	    .rdDat(fInPlainByte), 
	    .valid(fInValid), 
	    .wrDat(plainByte), 
	    .push(validIn), 
	    .pop(getNext),
	    .clk(clk), .rst(rst));
   
   // TODO: detect preambleDone
//   assign preambleDone = preambleLength == byteCount;
   assign preambleDone = byteCount >= preambleLength;
  

   // TODO: detect packet end (i.e. 32 bytes have been processed)
   assign messageDone = byteCount == 32;

   // instantiate the ROM
   dat_mem dm1(.raddr(raddr), .data_out(data_out));

   // instantiate the lfsr
   lfsr5 l5(.clk(clk), 
            .en(lfsr_en),
            .init(load_LFSR),
            .taps(taps),
            .start(start_LFSR),
            .state(LFSR));
   
  assign encryptByte = {MSB, fInPlainByte[6:5], fInPlainByte[4:0] ^ LFSR};
//  assign encryptByte = {byteCount};
  

   always_ff @(posedge clk) begin
      
      // TODO: capture preamble length, taps, and seed that you read from the ROM

      case (raddr)
         0: preambleLength = data_out;
         1: taps = data_out;
         2: start_LFSR = data_out;
      endcase

   end
  

   //
   // byte counter - count the number of bytes processed
   //
   always_ff @(posedge clk) begin
      if (rst) begin
	 byteCount <= 0;
      end else begin
	if (incByteCount) begin
	   byteCount <= byteCount + 1;
	end else begin
	   byteCount <= byteCount;
	end
      end
   end // always_ff @ (posedge clk)
	

endmodule // lab4_dp

