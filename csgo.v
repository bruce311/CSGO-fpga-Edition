// Part 2 skeleton

module csgo
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input	CLOCK_50;				//	50 MHz
	
	// Declare your inputs and outputs here
	input	[3:0]	KEY;	//KEY[0]->RESET; KEY[1]->blood; KEY[2]->bullet; 
	
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	//assign KEYs to wires; 
	wire blood; 
	//wire bullet; 
	assign blood = ~KEY[1];
	//assign bullet = ~KEY[2];
	
	//wires to connect datapath with fsm; 
	//wire plot,bd1,bd2,bd3,bd4,bd5,bd6,bd7,bd8,bd9,bd10, bt1,bt2,bt3,bt4,bt5,bt6,bt7,bt8,bt9,bt10;
	
	
	//wire [7:0] counterDraw; //16x16 block; 
	//wire [8:0] x_reg;
	//wire [7:0] y_reg;
	
	//wire [3:0] counterblood; 
	//wire [3:0] counterbullet; 
	
	wire Bd1,Bd2,Bd3,Bd4,Bd5,Bd6,Bd7,Bd8,Bd9,Gg;
	wire Finish; 
	
	

	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [23:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	wire writeEn; //signal for drawing the block 

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
		

	datapath control(.clock(CLOCK_50),
						  //.reset(resetn), 
						  .plot(writeEn),
						  .finish(Finish),
						  .bd1(Bd1),
						  .bd2(Bd2),
						  .bd3(Bd3),
						  .bd4(Bd4),
						  .bd5(Bd5),
						  .bd6(Bd6),
						  .bd7(Bd7),
						  .bd8(Bd8),
						  .bd9(Bd9),
						  .gg(Gg), 
						  .x(x),
						  .y(y),
						  .colour_out(colour)
						  );
						  
	fsm signals(.clock(CLOCK_50),
					.reset(resetn),
					.blood(blood), 
					.bd1(Bd1),
					.bd2(Bd2),
					.bd3(Bd3),
					.bd4(Bd4),
					.bd5(Bd5),
					.bd6(Bd6),
					.bd7(Bd7),
					.bd8(Bd8),
					.bd9(Bd9),
					.gg(Gg), 
					.plot(writeEn),
					.finish(Finish)
					); 
	
	
	
endmodule





module datapath(clock, finish, plot, bd1,bd2,bd3,bd4,bd5,bd6,bd7,bd8,bd9,gg, x, y, colour_out); 
	input clock; 
	input plot; 
	input bd1,bd2,bd3,bd4,bd5,bd6,bd7,bd8,bd9,gg;
	output reg [8:0] x; 
	output reg [7:0] y; 
	output reg [23:0] colour_out; 	
	output reg finish; //feed back to fsm; 
	reg [8:0] start_x; 
	reg [7:0] start_y;
	reg [3:0] count_x; 
	reg [3:0] count_y; 
	
	reg [6:0] count_endx; 
	reg [5:0] count_endy; 
	
	wire [8:0] black_x;
	wire [7:0] black_y; 
	wire [8:0] end_x; 
	wire [7:0] end_y;
	
	wire  [7:0] address1;
	wire  [12:0] address2; 
	
	wire [23:0] colour1;
	wire [23:0] colour2;
	
	
	always @(posedge clock)
		begin 
			if(plot)
				begin 
					if(bd1) begin 
						start_x <= 9'd144;
						start_y <= 8'd224;
					end 
					
					if(bd2) begin 
						start_x <= 9'd128;
						start_y <= 8'd224; 
					end 
					
					if(bd3) begin 
						start_x <= 9'd112;
						start_y <= 8'd224; 
					end 

					if(bd4) begin 
						start_x <= 9'd96;
						start_y <= 8'd224; 
					end 
	
					if(bd5) begin 
						start_x <= 9'd80;
						start_y <= 8'd224; 
					end 
					
					if(bd6) begin 
						start_x <= 9'd64;
						start_y <= 8'd224; 
					end 
					
					if(bd7) begin 
						start_x <= 9'd48;
						start_y <= 8'd224; 
					end 
					
					if(bd8) begin 
						start_x <= 9'd32;
						start_y <= 8'd224; 
					end 
					
					if(bd9) begin 
						start_x <= 9'd16;
						start_y <= 8'd224; 
					end 
					
					if(gg) begin 
						start_x <= 9'd96;
						start_y <= 8'd88;
					end 
	
				end 
		end 

		
		always @(posedge clock)
		begin
		finish <= 0;
			if (plot && !gg) begin
				
				if(count_x == 4'd15)
					count_y <= count_y + 1; 
				
				if(count_x == 4'd15 && count_y == 4'd15)
					begin 
						count_x <= 4'b0; 
						count_y <= 4'b0;
						finish <= 1;
					end
				else begin 
					count_x <= count_x + 1;
				end 
				
			end
		

		
			if (plot && gg) begin 
				finish <= 0; 
					if (count_endx == 7'd127)
						count_endy <= count_endy + 1; 
					if (count_endx == 7'd127 && count_endy == 6'd63)
						begin 
							count_endx <= 7'd0; 
							count_endy <= 6'd0; 
							finish <= 1; 
						end 
			
					else 
						count_endx <= count_endx + 1;  
			end 
			
		end
		
		
		assign black_x = start_x + count_x; 
		assign black_y = start_y + count_y;	
		assign address1 = (count_y)*16 + count_x;	
			
		assign end_x = start_x + count_endx; 
		assign end_y = start_y + count_endy; 
		assign address2 = (count_endy)*128 + count_endx; 
		  
		  
		  
		black bloodout(.address(address1),
							.clock(clock),
							.q(colour1)
							);	
					
		endpage gameover(.address(address2),
								 .clock(clock),
								 .q(colour2)
								 ); 	
			
		
	
		
		
		always @(*)
			begin 
				if ( bd1||bd2||bd3||bd4||bd5||bd6||bd7||bd8||bd9 ) begin 
					x <= black_x; 
					y <= black_y;
					colour_out <= colour1; 
					end 
				if ( gg ) begin 
					x <= end_x;
					y <= end_y; 
					colour_out <= colour2; 
				end 
			end
		
endmodule




 

module fsm(clock,reset,blood, bd1,bd2,bd3,bd4,bd5,bd6,bd7,bd8,bd9,gg, plot, finish); 
	input clock, reset, blood; 
	output reg plot, finish;
	output reg bd1,bd2,bd3,bd4,bd5,bd6,bd7,bd8,bd9,gg;
	
	reg [4:0] currentstate; 
	reg [4:0] nextstate; 

	localparam [4:0]  start = 5'd0,
							bd_to_90 = 5'd1,
							blood_90 = 5'd2,
							bd_to_80 = 5'd3,
							blood_80 = 5'd4,
							bd_to_70 = 5'd5,
							blood_70 = 5'd6,
							bd_to_60 = 5'd7,
							blood_60 = 5'd8,
							bd_to_50 = 5'd9,
							blood_50 = 5'd10,
							bd_to_40 = 5'd11,
							blood_40 = 5'd12,
							bd_to_30 = 5'd13,
							blood_30 = 5'd14,
							bd_to_20 = 5'd15,
							blood_20 = 5'd16,
							bd_to_10 = 5'd17,
							blood_10 = 5'd18,
							bd_to_00 = 5'd19,
							gameover = 5'd20,
							endgame = 5'd21;
							
						
							
	always @(*)
		begin 	
			case(currentstate) 
				start: nextstate = blood ? bd_to_90 : start; 
				bd_to_90: nextstate = blood ? bd_to_90 : blood_90;
				blood_90: nextstate = blood ? bd_to_80 : blood_90;
				bd_to_80: nextstate = blood ? bd_to_80 : blood_80;
				blood_80: nextstate = blood ? bd_to_70 : blood_80;
				bd_to_70: nextstate = blood ? bd_to_70 : blood_70;
				blood_70: nextstate = blood ? bd_to_60 : blood_70;
				bd_to_60: nextstate = blood ? bd_to_60 : blood_60;
				blood_60: nextstate = blood ?	bd_to_50 : blood_60;
				bd_to_50: nextstate = blood ? bd_to_50 : blood_50;
				blood_50: nextstate = blood ? bd_to_40 : blood_50;
				bd_to_40: nextstate = blood ? bd_to_40 : blood_40;
				blood_40: nextstate = blood ? bd_to_30 : blood_40;
				bd_to_30: nextstate = blood ? bd_to_30 : blood_30;
				blood_30: nextstate = blood ? bd_to_20 : blood_30;
				bd_to_20: nextstate = blood ? bd_to_20 : blood_20;
				blood_20: nextstate = blood ? bd_to_10 : blood_20;
				bd_to_10: nextstate = blood ? bd_to_10 : blood_10;
				blood_10: nextstate = blood ? bd_to_00 : blood_10;
				bd_to_00: nextstate = blood ? bd_to_00 : gameover; 
				gameover: nextstate = finish ? endgame : gameover; 
				endgame: nextstate = ~reset ? start : endgame; 
				default: nextstate = start; 
			endcase 		
		end 				
							

	//always block for updating signals
	always @(*)
		begin 
			case(currentstate)	
				start: begin 	
					plot = 1'b0;
					bd1 = 1'b0; //90%
					bd2 = 1'b0; //80%
					bd3 = 1'b0; //70%
 					bd4 = 1'b0; //60%
					bd5 = 1'b0; //50%
					bd6 = 1'b0; //40%
					bd7 = 1'b0; //30%
					bd8 = 1'b0; //20%
					bd9 = 1'b0; //10%
					gg = 1'b0;  //end page
				end
				
				bd_to_90: begin 
					plot = 1'b0;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				blood_90: begin 
					plot = 1'b1;
					bd1 = 1'b1;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				bd_to_80: begin 
					plot = 1'b0;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				blood_80: begin 
					plot = 1'b1;
					bd1 = 1'b0;
					bd2 = 1'b1;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				bd_to_70: begin 
					plot = 1'b0;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				blood_70: begin 
					plot = 1'b1;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b1;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				bd_to_60: begin 
					plot = 1'b0;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				blood_60: begin 
					plot = 1'b1;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b1;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				bd_to_50: begin 
					plot = 1'b0;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				blood_50: begin 
					plot = 1'b1;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b1;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				bd_to_40: begin 
					plot = 1'b0;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				blood_40: begin 
					plot = 1'b1;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b1;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				bd_to_30: begin 
					plot = 1'b0;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				blood_30: begin 
					plot = 1'b1;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b1;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				bd_to_20: begin 
					plot = 1'b0;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				blood_20: begin 
					plot = 1'b1;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b1;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				bd_to_10: begin 
					plot = 1'b0;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				blood_10: begin 
					plot = 1'b1;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b1;
					gg = 1'b0;
				end
				
				bd_to_00: begin 
					plot = 1'b0;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b0;
				end
				
				gameover: begin 
					plot = 1'b1;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b1;
				end
				
				endgame: begin 
					plot = 1'b0;
					bd1 = 1'b0;
					bd2 = 1'b0;
					bd3 = 1'b0;
					bd4 = 1'b0;
					bd5 = 1'b0;
					bd6 = 1'b0;
					bd7 = 1'b0;
					bd8 = 1'b0;
					bd9 = 1'b0;
					gg = 1'b1;
				end 
				
			endcase
		end


		//always block for plot black box; 
		always @(posedge clock)
			begin
				if (!reset)
					currentstate <= start;  
				else	
					currentstate <= nextstate;
			end
			
endmodule 





/*

module datapath(Clock, Reset, plot,bd1,bd2,bd3,bd4,bd5,bd6,bd7,bd8,bd9,gg, x, y, colour_out);
	input Clock, Reset;
	input [3:0] Counterblood; 
	input [3:0] Counterbullet; 
	reg [8:0] X_reg; //initial plotting spot of x;
	reg [7:0] Y_reg; //initial plotting spot of y;
	reg [7:0] CounterDraw; 
	
	output reg [8:0] x; 
	output reg [7:0] y; 
	output reg [23:0] colour_out; 
	
	output reg plot;  //write enable for vga; 


	always @(posedge Clock) 
		begin 
			//implement reset later; 
			
			
			//first press reset before game; 
			if(!Reset)begin 
				X_reg <= 9'd0; 
				Y_reg <= 8'd0;
				CounterDraw <= 8'd0;
				plot <= 1'b0; 
				end 
			//blood------------------------
			
			if(Counterblood == 4'd1) begin 
				X_reg <= 9'd224;
				Y_reg <= 8'd144;
				if (CounterDraw < 8'd256)
					CounterDraw <= CounterDraw + 8'b00000001; 
					
				x <= X_reg + CounterDraw[3:0]; 
				y <= Y_reg + CounterDraw[7:4];
				colour_out <= 3'b000; 
				plot <= 1'b1; 
			end
			
			if(Counterblood == 4'd2) begin 
				X_reg <= 9'd224;
				Y_reg <= 8'd128;
				
				if (CounterDraw < 8'd256)
					CounterDraw <= CounterDraw + 8'b00000001; 
					
				x <= X_reg + CounterDraw[3:0]; 
				y <= Y_reg + CounterDraw[7:4];
				colour_out <= 3'b000; 
				plot <= 1'b1; 
			end
			
			if(Counterblood == 4'd3) begin 
				X_reg <= 9'd224;
				Y_reg <= 8'd112;
				
				if (CounterDraw < 8'd256)
					CounterDraw <= CounterDraw + 8'b00000001; 
					
				x <= X_reg + CounterDraw[3:0]; 
				y <= Y_reg + CounterDraw[7:4];
				colour_out <= 3'b000; 
				plot <= 1'b1; 
			end
			
			if(Counterblood == 4'd4) begin 
				X_reg <= 9'd224;
				Y_reg <= 8'd96;
				
				if (CounterDraw < 8'd256)
					CounterDraw <= CounterDraw + 8'b00000001; 
					
				x <= X_reg + CounterDraw[3:0]; 
				y <= Y_reg + CounterDraw[7:4];
				colour_out <= 3'b000; 
				plot <= 1'b1; 
			end
			
			if(Counterblood == 4'd5) begin 
				X_reg <= 9'd224;
				Y_reg <= 8'd80;
				
				if (CounterDraw < 8'd256)
					CounterDraw <= CounterDraw + 8'b00000001; 
					
				x <= X_reg + CounterDraw[3:0]; 
				y <= Y_reg + CounterDraw[7:4];
				colour_out <= 3'b000; 
				plot <= 1'b1; 
			end
			
			
			if(Counterblood == 4'd6) begin 
				X_reg <= 9'd224;
				Y_reg <= 8'd64;
				
				if (CounterDraw < 8'd256)
					CounterDraw <= CounterDraw + 8'b00000001; 
					
				x <= X_reg + CounterDraw[3:0]; 
				y <= Y_reg + CounterDraw[7:4];
				colour_out <= 3'b000; 
				plot <= 1'b1; 
			end
			
			if(Counterblood == 4'd7) begin 
				X_reg <= 9'd224;
				Y_reg <= 8'd48;
				
				if (CounterDraw < 8'd256)
					CounterDraw <= CounterDraw + 8'b00000001; 
					
				x <= X_reg + CounterDraw[3:0]; 
				y <= Y_reg + CounterDraw[7:4];
				colour_out <= 3'b000; 
				plot <= 1'b1; 
			end
			
			if(Counterblood == 4'd8) begin 
				X_reg <= 9'd224;
				Y_reg <= 8'd32;
				
				if (CounterDraw < 8'd256)
					CounterDraw <= CounterDraw + 8'b00000001; 
					
				x <= X_reg + CounterDraw[3:0]; 
				y <= Y_reg + CounterDraw[7:4];
				colour_out <= 3'b000; 
				plot <= 1'b1; 
			end
			
			if(Counterblood == 4'd9) begin 
				X_reg <= 9'd224;
				Y_reg <= 8'd16;
				
				if (CounterDraw < 8'd256)
					CounterDraw <= CounterDraw + 8'b00000001; 
					
				x <= X_reg + CounterDraw[3:0]; 
				y <= Y_reg + CounterDraw[7:4];
				colour_out <= 3'b000; 
				plot <= 1'b1; 
			end
			
			if(Counterblood == 4'd10) begin 
				X_reg <= 9'd224;
				Y_reg <= 8'd0;
				
				if (CounterDraw < 8'd256)
					CounterDraw <= CounterDraw + 8'b00000001; 
					
				x <= X_reg + CounterDraw[3:0]; 
				y <= Y_reg + CounterDraw[7:4];
				colour_out <= 3'b000; 
				plot <= 1'b1; 
			end
			
			//bullet-----------------------
				
		
		end
	

endmodule

*/


















