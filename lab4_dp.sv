module lab4_dp #(parameter DW=8, AW=4, lfsr_bitwidth=5) (
// TODO: Declare your ports for your datapath
// TODO: for example							 
// TODO: output logic [7:0] encryptByte, // encrypted byte output
// TODO: ... 
// TODO: input logic 	      clk, // clock signal 
// TODO: input logic 	      rst           // reset

   output logic [7:0]   encryptByte;   // encrypted byte output

   input logic [7:0] plainByte;        // input for fifo from lab4.sv
   input logic validIn;                // input for fifo from lab4.sv

   input logic          clk;           // clock signal
   input logic          rst;           // reset

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



   logic [AW-1:0] 	       raddr;    // memory read address
   
   // TODO: control the raddr
   // TODO: there are many ways you can do this.
   // TODO: one way is to have a counter here to count 0, 1, 2 and control this coutner
   // TODO: from your state machine
   // TODO: another is to have raddr be the output of mux where you control the mux from your
   // TODO: state machine and the mux selects 0, 1 or 2.
   // TODO: or you can drive raddr from your state machine directly since its only 2 bits it
   // TODO: isn't alot of wires

   //
   // FIFO
   // This fifo takes data from the outside (testbench) and captures it
   // Your logic reads from this fifo.
   //
   logic [7:0] 		       fInPlainByte;  // data from the input fifo
 		       
   fifo fm (
	    .rdDat(fInPlainByte),              // data from the FIFO                        --- output
	    .valid(fInValid),                  // there is valid data from the FIFO         --- output
	    .wrDat(plainByte),                 // data into the FIFO                        --- input from lab4.sv
	    .push(validIn),                    // data into the fifo is valid               --- input from lab4.sv
	    .pop(getNext),                     // read the next entry from the fifo         --- ???
	    .clk(clk), .rst(rst));             //                                           --- clk / rst signals
   
   // TODO: detect preambleDone
   
   // TODO: detect packet end (i.e. 32 bytes have been processed)


   // instantiate the ROM
   dat_mem dm1(.raddr, .data_out);

   // instantiate the lfsr
   lfsr5 l5(.clk(clk), 
            .en(lfsr_en),          // advance LFSR on rising clk                       --- starter
            .init(load_LFSR),	   // initialize LFSR                                    --- starter
            .taps, 		   // tap pattern                                              --- no idea -> .data_out ? 
            .start, 		   // starting state for LFSR                                  --- no idea
            .state(LFSR));	   // LFSR state = LFSR output                              --- starter
   
   
   // TODO: write an expression for encryptByte
   // TODO: for example:
   // TODO: assign encryptByte = {         };

   always_ff @(posedge clk) begin
      
      // TODO: capture preamble length, taps, and seed that you read from the ROM

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

