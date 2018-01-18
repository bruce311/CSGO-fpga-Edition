module counters(SW, KEY, CLOCK_50, HEX0, HEX1, HEX2, HEX4);
	input [1:0]KEY; 
	input [1:0] SW; //SW[0]->reset; SW[1]->start signal; 
	input CLOCK_50;
	output [6:0] HEX0, HEX1, HEX2, HEX4; 

	wire Enable; 
	wire [3:0] count_1; 
	wire [3:0] count_2;

	wire [3:0] count_life; 
	wire [3:0] count_bullet; 	
	
	ClockDivider dividefortime(.clock(CLOCK_50), 
										.enable(Enable)
										); 
	ClockCounter timecounter(.clock(CLOCK_50),
									 .reset(SW[0]),
									 .enable(Enable), 
									 .count1(count_1),
									 .count2(count_2),
									 .start(SW[1])
									 );
	Hex second1(.inputs(count_1),.display(HEX0)); 
	Hex second2(.inputs(count_2),.display(HEX1)); 

	
	lifeandbulletcounter lifeandbullet(.clock(Enable),
											     .reset(SW[0]),
												  .enable1(KEY[0]), 
												  .enable2(KEY[1]),
												  .countlife(count_life), 
												  .countbullet(count_bullet)
												  );
												 
												 
	Hex life(.inputs(count_life), .display(HEX2));
	Hex bullet(.inputs(count_bullet), .display(HEX4)); 
	
	
	
endmodule 

module lifeandbulletcounter(clock, reset, enable1, enable2, countlife, countbullet);
	input clock; 
	input reset;  
	input enable1, enable2; 
	output reg [3:0] countlife = 4'b1010;
	output reg [3:0] countbullet = 4'b1010; 
	
	always @(posedge clock)
	begin 
		if (reset == 1'b1)
			begin 
			countlife <= 4'b1010; 
			countbullet <= 4'b1010;
			end
			if (enable1 == 1'b0)
				countlife <= countlife - 1'b1; 
			if (enable2 == 1'b0)
				countbullet <= countbullet - 1'b1;
	end
endmodule
	
module ClockCounter(reset, clock, enable, count1, count2, start); //Behavioural code for 4bit counter
	input clock; //50MHz clock
	input reset; 
	input start; 
	input enable; //Enable signal
	output reg [3:0] count1 = 4'b0000; //Storage for the counted number initialized to 0
	output reg [3:0] count2= 4'b0000;
	
	always @(posedge clock)
	
	begin
		if (reset == 1'b1)
			begin
			count1 <= 4'b0000; 
			count2 <= 4'b0000; 
			end
		else if (start) begin
			if (enable == 1'b1)
				count1 <= count1 + 1'b1;
			if (count1 == 4'b1010)
				begin 
				count2 <= count2 + 1'b1; 
				count1 <= 4'b0000; 
				end
			if (count2 == 4'b0110)
				count2 <= 1'b0; 
		
		end	
	end
endmodule	



module ClockDivider(clock, enable); //Behavioural code for clock divider 
	input clock; //Clock signal 
	output enable; //Enable signal for human speed counter, use as active synch reset for fast counter
	
	wire [25:0] count; //Stores the count value
	
	twentySixBitCounter counter26bit(clock, enable, count);
	
	assign enable = (count == 26'd50000000)?1'b1:1'b0; //counter rate: 1Hz
endmodule 

module twentySixBitCounter(clock, reset_synch, count); //Behavioral code for 25bit counter with active high synch reset
	input clock; //Clock signal
	
	input reset_synch; //Active high synch reset
	output reg [25:0] count = 26'd0; //Stored number initialized to 0
	
	always @(posedge clock)
	
		begin
			if (reset_synch == 1'b1)
				count <= 26'd0;
			else 
				count <= count + 1'b1;
		end 
endmodule 

	
module Hex(inputs, display); 
	input [3:0] inputs;
	output [6:0] display;
	
	hex0 h0(
		.c3(inputs[3]),
		.c2(inputs[2]),
		.c1(inputs[1]),
		.c0(inputs[0]),
		.m(display[0])
		);
	
	hex1 h1(
		.c3(inputs[3]),
		.c2(inputs[2]),
		.c1(inputs[1]),
		.c0(inputs[0]),
		.m(display[1])
		);
	
	hex2 h2(
		.c3(inputs[3]),
		.c2(inputs[2]),
		.c1(inputs[1]),
		.c0(inputs[0]),
		.m(display[2])
		);
	
	hex3 h3(
		.c3(inputs[3]),
		.c2(inputs[2]),
		.c1(inputs[1]),
		.c0(inputs[0]),
		.m(display[3])
		);
			
	hex4 h4(
		.c3(inputs[3]),
		.c2(inputs[2]),
		.c1(inputs[1]),
		.c0(inputs[0]),
		.m(display[4])
		);
	
	hex5 h5(
		.c3(inputs[3]),
		.c2(inputs[2]),
		.c1(inputs[1]),
		.c0(inputs[0]),
		.m(display[5])
		);
	
	hex6 h6(
		.c3(inputs[3]),
		.c2(inputs[2]),
		.c1(inputs[1]),
		.c0(inputs[0]),
		.m(display[6])
		);
	
endmodule 


module hex0(c3, c2, c1, c0, m); 
	input c3, c2, c1, c0; 
	output m; 
	assign m = ~((c3|c2|c1|~c0)&(c3|~c2|c1|c0)&(~c3|c2|~c1|~c0)&(~c3|~c2|c1|~c0)); 	
endmodule 

module hex1(c3, c2, c1, c0, m); 
	input c3, c2, c1, c0; 
	output m; 
	assign m = ~((c3|~c2|c1|~c0)&(c3|~c2|~c1|c0)&(~c3|c2|~c1|~c0)&(~c3|~c2|c1|c0)&(~c3|~c2|~c1|c0)&(~c3|~c2|~c1|~c0));
endmodule

module hex2(c3, c2, c1, c0, m) ; 
	input c3, c2, c1, c0; 
	output m; 
   assign m = ~((c3|c2|~c1|c0)&(~c3|~c2|c1|c0)&(~c3|~c2|~c1|c0)&(~c3|~c2|~c1|~c0));
endmodule 

module hex3(c3, c2, c1, c0, m) ; 
	input c3, c2, c1, c0; 
	output m; 
	assign m = ~((c3|c2|c1|~c0)&(c3|~c2|c1|c0)&(c3|~c2|~c1|~c0)&(~c3|c2|c1|~c0)&(~c3|c2|~c1|c0)&(~c3|~c2|~c1|~c0));
endmodule

module hex4(c3, c2, c1, c0, m) ; 
	input c3, c2, c1, c0; 
	output m; 
	assign m = ~((c3|c2|c1|~c0)&(c3|c2|~c1|~c0)&(c3|~c2|c1|c0)&(c3|~c2|c1|~c0)&(c3|~c2|~c1|~c0)&(~c3|c2|c1|~c0));
endmodule

module hex5(c3, c2, c1, c0, m) ; 
	input c3, c2, c1, c0; 
	output m; 
	assign m = ~((c3|c2|c1|~c0)&(c3|c2|~c1|c0)&(c3|c2|~c1|~c0)&(c3|~c2|~c1|~c0)&(~c3|~c2|c1|~c0));
endmodule 

module hex6(c3, c2, c1, c0, m) ; 
	input c3, c2, c1, c0; 
	output m; 
	assign m = ~((c3|c2|c1|c0)&(c3|c2|c1|~c0)&(c3|~c2|~c1|~c0)&(~c3|~c2|c1|c0));
endmodule 