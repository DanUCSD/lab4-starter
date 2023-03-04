// Create Date:    2022.05.05
// Module Name:    dat_mem 
//
// ROM
// $clog2(N) = ceiling (log2(N)) -- use to determine pointer width needed
// two-dimensional array
// default size = 8 bits wide x 16 words deep, 
//   where each word is one byte wide, in this case 
// writes are clocked/sequential; reads are combinational
module dat_mem #(parameter W=8, byte_count=16)(
  input  [$clog2(byte_count)-1:0] raddr,     // read pointer
  output  [ W-1:0]                data_out
    );

// W bits wide [W-1:0] and byte_count registers deep 	 
logic [W-1:0] core[byte_count];	 

// also memory write address pointer (how many bits?),
//	read address pointer,
//  8-bit-wide data out,
// memory core contents
//   operands test bench provides to you
// [0]     = preamble length   (max 12 characters)
// [1]     = feedback taps in bits [4:0]   
// [2]     = LFSR starting state in bits [4:0]

// combinational reads 
assign data_out = core[raddr] ;	 

endmodule
