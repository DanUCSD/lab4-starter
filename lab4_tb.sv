// CSE140L  Winter 2023
// Lab4_tb
// full testbench for programmable message encryption
// the 6 possible maximal-length feedback tap patterns from which to choose
  /* the 6 possible maximal-length feedback tap patterns from which to choose
  assign LFSR_ptrn[0] = 5'h1E;          
  assign LFSR_ptrn[1] = 5'h1D;
  assign LFSR_ptrn[2] = 5'h1B;
  assign LFSR_ptrn[3] = 5'h17;
  assign LFSR_ptrn[4] = 5'h14;
  assign LFSR_ptrn[5] = 5'h12;
  */
module lab4_tb  #(parameter lfsr_bitwidth=5, test_vector_len=32)               ;
   bit        clk;	 
   wire       done;             // done flag returned by DUT
   bit [7:0]  message[52];	// original message, in binary
   bit [7:0]  msg_padded[test_vector_len];  // original message, plus pre- and post-padding
   bit [7:0]  msg_crypto[test_vector_len];  // encrypted message to test against DUT
   bit [7:0]  dutCapture[test_vector_len];  // capture output from the DUT
   bit [7:0]  pre_length;       // encrypted space bytes before first character in message
   bit [lfsr_bitwidth-1:0] lfsr_ptrn;   // one of 6 maximal length 5-tap shift reg. ptrns
   bit [lfsr_bitwidth-1:0] lfsr_state;  // iniital state (seed) of encrypting LFSR         
   bit [lfsr_bitwidth-1:0] LFSR;        // linear feedback shift register, makes PN code

   //
   // ***** select your original message string to be encrypted *****
   //
   // string 		  str  = "mr_watson_come_here_i_want_to_see_you";
   string  str = "Hello_there_xor_is_^_";
   int str_len;		 // length of string (character count)


   // this assumes the top level module of your design is called lab4

   logic [7:0] encryptByte;
   logic       validOut;
   logic       validIn;
   logic [7:0] plainByte;
   logic       encRqst;
   logic       rst;
       
   integer     cycleCount = 0;
   logic [7:0] dutCaptAddr = 0;
   
   //
   // clock generation
   //
   always begin
      clk <=0;
      #10;
      clk <=1;
      cycleCount <= cycleCount + 1;
      #10;
   end

   //
   // reset generation
   //
   initial begin
      rst <= 0;
      wait(cycleCount == 3);
      rst <= 1;
      wait(cycleCount == 5);
      rst <= 0;
   end
      

   lab4 dut (
	     .encryptByte,
	     .validOut,
	     .validIn,
	     .plainByte,
	     .clk,
	     .encRqst,
	     .done,
	     .rst);
   


   // ***** choose one of the 6 feedback TAP patterns *****
   int i = 2;   // choose the LFSR_ptrn; legal values = 0 to 5; 

   logic [lfsr_bitwidth-1:0] LFSR_ptrn[6]; // testbench will apply whichever is chosen
   assign LFSR_ptrn[0] = 5'h1E;            //  and check for correct results from your DUT
   assign LFSR_ptrn[1] = 5'h1D;
   assign LFSR_ptrn[2] = 5'h1B;
   assign LFSR_ptrn[3] = 5'h17;
   assign LFSR_ptrn[4] = 5'h14;
   assign LFSR_ptrn[5] = 5'h12;
   


   // ***** select your desired preamble length *****  
   int j = 7;   // preamble length

   bit tbInit = 0;  //start the test bench tests after tbInit
   initial begin
      // 
      // TODO: to use gtkwave or edaplayground (uncomment)
      // TODO: the $dumpfile and $dumpvars
      //
      // $dumpfile("dump.vcd");
      // $dumpvars;

      // sanity check on premable length
      if(j<7)  j  =  7;  // minimum preamble length
      if(j>12) j  = 12;  // maximum preamble length
      @(posedge clk);
      pre_length  = j;   // set preamble length
      if(i>5) begin 
	 i = 5;          // restricts to legal
	 $display("illegal tap pattern chosen, force to 6'h12");        
      end else begin
 	 $display("tap pattern selected = %d",LFSR_ptrn[i]);
      end

      lfsr_ptrn = LFSR_ptrn[i];  // selects one of 6 permitted
  
      // ***** choose any nonzero 6-bit starting state for the LFSR ******
      lfsr_state  = 5'h01;    // any nonzero value will do; something simple facilitates debug
      if(!lfsr_state) begin
	 lfsr_state = 5'h10;  // prevents nonzero lfsr_state by substituting 5'b1_0000
      end
      LFSR = lfsr_state;      // initalize test bench's LFSR
      $display("initial LFSR_state = %h", lfsr_state);
      $display("%s", str);         // print original message in transcript window
      for(int j=0; j<test_vector_len; j++) // pre-fill message_padded with ASCII ~ characters
	msg_padded[j] = 8'h7E;         	   // as placeholders: see next line  
      
      //
      // truncate string if needed
      // string must end in a newline
      //
      str_len = str.len;

      for(int l=0; l<str_len; l++)   // overwrite these ASCII ~ w/ message itself
	msg_padded[pre_length+l] = str[l]; // leaves pre_length ASCII ~ in 
                                           // front of the message itself
      
//      for(int n=0; n<test_vector_len; n++)
//	dut.dp.dm1.core[n] = 8'h7E;  // prefill data mem w/ |
      
      $display("preamble_length = %d",pre_length);
      dut.dp.dm1.core[0] = pre_length;   // number of bytes in preamble
      dut.dp.dm1.core[1] = lfsr_ptrn;	 // LFSR feedback tap positions (8 possible ptrns)
      dut.dp.dm1.core[2] = lfsr_state;	 // LFSR starting state (nonzero)
      tbInit = 1;
   end // initial begin

   //
   // capture the DUT output
   // whenver the DUT  asserts validOut, capture encryptByte.
   //
   initial begin
      forever begin
	 @(posedge clk);
	 if (validOut) begin
	    dutCapture[dutCaptAddr] <= encryptByte;
	    dutCaptAddr <= dutCaptAddr + 1;
	 end
      end
   end

   initial begin
      wait (tbInit);
      validIn <= 0;
      encRqst <= 0;
      wait(cycleCount == 10); 
      encRqst <= 1;  
      wait(cycleCount == 11); 
      encRqst <= 0;
      @(posedge clk);

      // send clear text to the DUT
      // precalculate the expeced encrypted packet
      for(int ij=0; ij<pre_length; ij++) begin
	 msg_crypto[ij]  <= msg_padded[ij] ^ {3'b0,LFSR}; // encrypt 5 lsbs

         // roll the rolling code
	 LFSR                 <= (LFSR<<1)+(^(LFSR&lfsr_ptrn));//{LFSR[4:0],feedback};
	 plainByte <= msg_padded[ij];
	 validIn <= 1;
	 @(posedge clk);
      end

      for(int ij=pre_length; ij<test_vector_len; ij++) begin
	 msg_crypto[ij]        <= msg_padded[ij] ^ {3'b100,LFSR}; // encrypt 5 lsbs
         // roll the rolling code
	 LFSR                 <= (LFSR<<1)+(^(LFSR&lfsr_ptrn));//{LFSR[4:0],feedback};
	 plainByte <= msg_padded[ij];
	 validIn <= 1;
	 @(posedge clk);
      end

      //
      // wait until done or until cycleCount 200
      //

      wait(done|| (cycleCount > 200));                // wait for DUT's done flag to go high
      
      // check the result starting 
      for(int n=0; n<test_vector_len; n++) begin
	 $write("%d bench msg: %s %h %h %s dut msg: %h",
		n, msg_padded[n], msg_padded[n], msg_crypto[n],
		8'h7f & msg_crypto[n],
		dutCapture[n]);   
	 if(msg_crypto[n]==dutCapture[n]) 
           $display("    very nice!");
	 else 
           $display("      oops!");
      end
      $display("original message  = %s",string'(msg_padded));
      $write  ("encrypted message = ");
      for(int kk=0; kk<test_vector_len; kk++)
	$write("%s",string'(8'h7f & msg_crypto[kk]));//msg_crypto);
      $display(); 
      $stop;
   end
endmodule
