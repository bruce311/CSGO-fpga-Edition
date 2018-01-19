
module enemyenable(clock, start, enable); //Behavioural code for clock divider 
	input clock; 
	//input CLOCK_50; //50MHz clock; 
	input start;   
	output enable; 
	
	wire [26:0] count; //Stores the count value
	
	twentySevenBitCounter counter27bit(clock, start, enable, count);
	
	assign enable = (count == 27'd100000000)?1'b1:1'b0; //counter rate: 0.5Hz --> 2s 

endmodule 

module twentySevenBitCounter(clock, start, reset_synch, count); //Behavioral code for 25bit counter with active high synch reset
	input clock; //50MHz clock;//Clock signal
	input start; 
	input reset_synch; //Active high synch reset
	output reg [26:0] count = 27'd0; //Stored number initialized to 0
	
	/*
	reg gameon; 
	always @(posedge clock) begin 
		if (start)
			gameon <= 1'b1; 
	end 
	*/
	
	always @(posedge clock)
		begin
			if (reset_synch)
				count <= 27'd0;
			else if (start)
				count <= count + 1'b1; 
		end 
endmodule 




/*
module enemyenable(clock, reset, start, enable); //Behavioural code for clock divider 
	input clock; //50MHz clock; 
	input start; 
	input reset;  
	output enable; 
	
	wire [26:0] count; //Stores the count value
	
	twentySevenBitCounter counter27bit(clock, start, reset, enable, count);
	
	assign enable = (count == 27'd100000000)?1'b1:1'b0; //counter rate: 0.5Hz --> 2s 

endmodule 

module twentySevenBitCounter(clock, start, reset, reset_synch, count); //Behavioral code for 25bit counter with active high synch reset
	input clock; //50MHz clock;//Clock signal
	input start, reset; 
	input reset_synch; //Active high synch reset
	output reg [26:0] count = 27'd0; //Stored number initialized to 0
	
	
//	reg gameon; 
//	always @(posedge clock) begin 
//		if (start)
//			gameon <= 1'b1; 
//	end 
	
	
	
	always @(posedge clock)
		begin
			if (reset_synch)
				count <= 27'd0;
			else if (start)
			//else 
				count <= count + 1'b1;
			else if (!reset)
				count <= 27'd0; 
		end 
endmodule 
*/