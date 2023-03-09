module lab4_dp #(parameter DW=8, AW=4, lfsr_bitwidth=5) (
// TODO: Declare your ports for your datapath
// TODO: for example							 
// TODO: output logic [7:0] encryptByte, // encrypted byte output
// TODO: ... 
// TODO: input logic 	      clk,     // clock signal 
// TODO: input logic 	      rst      // reset

   output logic [7:0]   encryptByte,   // encrypted byte output
   output logic         preambleDone,  // guess
   output logic         byteCount,
   output logic         fInValid,
   output logic         messageDone,

   input logic          seed_en,       // guess
   input logic          taps_en,       // suggested in lab4.sv
   input logic          prelenen,      // output from seqsm.sv
   input logic [7:0]    plainByte,     // input for fifo from lab4.sv
   input logic          validIn,       // input for fifo from lab4.sv
   input logic [AW-1:0] raddr,         // controlling raddr diretly in seqsm.sv
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


   // 
   // TODO: declare signals that conect to lfsr5
   // TODO: for example:   
   // TODO: logic [lfsr_bitwidth-1:0] taps;       // LFSR feedback pattern temp register
   // TODO: logic [lfsr_bitwidth-1:0] LFSR;            // LFSR current value            
   //

   logic [lfsr_bitwidth-1:0] taps;       // LFSR feedback pattern temp register
   logic [lfsr_bitwidth-1:0] LFSR;            // LFSR current value    
   logic [3:0] preambleLength;
   logic [4:0] start_LFSR;
   logic seed;
   logic preambleDone;
   logic messageDone;

   logic [AW-1:0] 	       raddr;    // memory read address
   
   // TODO: control the raddr
   // TODO: there are many ways you can do this.
   // TODO: one way is to have a counter here to count 0, 1, 2 and control this counter
   // TODO: from your state machine
   // TODO: another is to have raddr be the output of mux where you control the mux from your
   // TODO: state machine and the mux selects 0, 1 or 2.
   // TODO: or you can drive raddr from your state machine directly since its only 2 bits it
   // TODO: isn't alot of wires

   assign raddr = incadd ? raddr + 1 : raddr;

   //
   // FIFO
   // This fifo takes data from the outside (testbench) and captures it
   // Your logic reads from this fifo.
   //
   logic [7:0] 		       fInPlainByte;  // data from the input fifo
   assign fInPlainByte[7] = preambleDone ? (messageDone ? fInPlainByte[7] : 1) : 0;
 		       
   fifo fm (
	    .rdDat(fInPlainByte),              // data from the FIFO                        --- output
	    .valid(fInValid),                  // there is valid data from the FIFO         --- output
	    .wrDat(plainByte),                 // data into the FIFO                        --- input from lab4.sv
	    .push(validIn),                    // data into the fifo is valid               --- input from lab4.sv
	    .pop(getNext),                     // read the next entry from the fifo         --- enabler for inc add seqsm
	    .clk(clk), .rst(rst));             //                                           --- clk / rst signals
   
   // TODO: detect preambleDone
   assign preambleDone = preambleLength >= byteCount;

   // TODO: detect packet end (i.e. 32 bytes have been processed)
   assign messageDone = byteCount == 32;

   // instantiate the ROM
   dat_mem dm1(.raddr(raddr), .data_out(data_out));

   // instantiate the lfsr
   lfsr5 l5(.clk(clk), 
            .en(lfsr_en),          // advance LFSR on rising clk                       --- starter
            .init(load_LFSR),	   // initialize LFSR                                    --- starter
            .taps(taps), 		   // tap pattern                                        --- data_out when raddr = 1
            .start(start_LFSR), 		   // starting state for LFSR                      --- data_out when raddr = 2
            .state(LFSR));	   // LFSR state = LFSR output                              --- starter
   
   
   // TODO: write an expression for encryptByte
   // TODO: for example:
   // TODO: assign encryptByte = {         };
   assign encryptByte = {fInPlainByte[7:5], fInPlainByte[4:0] ^ LFSR};

   always_ff @(posedge clk) begin
      
      // TODO: capture preamble length, taps, and seed that you read from the ROM

      case (raddr)
         0: preambleLength = data_out;
         1: taps = data_out;
         2: seed = data_out;
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

