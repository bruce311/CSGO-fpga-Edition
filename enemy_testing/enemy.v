
module enemy
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		
		//****************
		SW, //FOR NOW; 
		//****************
		
		HEX0,
		HEX1,
		
		
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
	input	[3:0]	KEY;	//KEY[0]->RESET; 
	
	
	input [9:0] SW; //4 SWsSHOOTS, sw[4]->start; 
	
	//HEX DISPLAY FOR TIME
	output [6:0] HEX0, HEX1; 
	
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	
	
	// INPUT SIGNAL;
	// assign signal to wires; 
	wire resetn;
	assign resetn = KEY[0];
	
	wire start;  
	//assign start = ~KEY[3];
	assign start = SW[9];
	
	wire shoot1, shoot2, shoot3, shoot4; 
	//assign shoot1 = ~KEY[3];
	assign shoot1 = SW[0];
	assign shoot2 = SW[1];
	assign shoot3 = SW[2];
	assign shoot4 = SW[3];
		
	
	//connect input wires to FSM and counters
	//---------------------------------------
	//input to enemy fsm from enable counter; 
	wire enable;  
	//input to blood fsm;
	//wire blood; 
	
	//blood-------------------------------------
	//wires to connect blood fsm with datapath ;
	//wire Bd1,Bd2,Bd3,Bd4,Bd5,Bd6,Bd7,Bd8,Bd9,Gg;
	//signal from datapath to blood fsm;  
	//wire Finish_blood; 
	
	//enemy------------------------------------
	//wires to connect enemy fsm with datapath; 
	wire enemy_plot1; //enemy_plot2, enemy_plot3, enemy_plot4;
	wire enemyon; 
	wire enemy_erase1; //enemy_erase2,enemy_erase3,enemy_erase4;
	wire success; 
	//signal from datapath to enemy fsm;
	wire Finish_enemy; 
	
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [23:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	
	//====================
	//PLOT SIGNAL FROM FSM
	wire writeEn; //signal for drawing the block 

	//wire writeEn_blood; 
	wire writeEn_enemy; 
	
	
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
								  
								  
	wire [3:0] count_1;
	wire [3:0] count_2; 
								  		
				
	counters timecounter(.clock(CLOCK_50), 
								.start(start), 
								.reset(resetn), 
								.count1(count_1), 
								.count2(count_2)
								);
								
								
	Hex second1(.inputs(count_1),.display(HEX0)); 
	Hex second2(.inputs(count_2),.display(HEX1)); 

	

	enemyenable enemycounter(.clock(CLOCK_50),  
									 .start(start), 
									 .enable(enable)
									 );  
	

								 
								 
	enemyfsm enemysignals(.clock(CLOCK_50), 
								 .reset(resetn), 
								 .enable(enable), 
								 .finish_enemy(Finish_enemy), 
								 .shoot1(shoot1), 
								 .shoot2(shoot2), 
								 .shoot3(shoot3), 
								 .shoot4(shoot4), 
								 .enemy_plot1(enemy_plot1), 
								 .enemy_plot2(enemy_plot2), 
								 .enemy_plot3(enemy_plot3), 
								 .enemy_plot4(enemy_plot4), 
								 .enemyon(enemyon), 
								 .enemy_erase1(enemy_erase1), 
								 .enemy_erase2(enemy_erase2), 
								 .enemy_erase3(enemy_erase3), 
								 .enemy_erase4(enemy_erase4), 
								 .success(success),
								 .plot(writeEn_enemy) 
								 
								 );
								 

	datapath control(.clock(CLOCK_50),
						  //.plot_blood(writeEn_blood),
						  .plot_enemy(writeEn_enemy),
						  .plot(writeEn),
						  //.bd1(Bd1),
						  //.bd2(Bd2),
						  //.bd3(Bd3),
						  //.bd4(Bd4),
						  //.bd5(Bd5),
						  //.bd6(Bd6),
						  //.bd7(Bd7),
						  //.bd8(Bd8),
						  //.bd9(Bd9),
						  //.gg(Gg), 
						  .enemy_plot1(enemy_plot1),
						  .enemy_plot2(enemy_plot2),
						  .enemy_plot3(enemy_plot3),
						  .enemy_plot4(enemy_plot4),
						  .enemy_erase1(enemy_erase1),
						  .enemy_erase2(enemy_erase2),
						  .enemy_erase3(enemy_erase3),
						  .enemy_erase4(enemy_erase4),
						  .success(success),
						  //.finish_blood(Finish_blood),
						  .finish_enemy(Finish_enemy),
						  .x(x),
						  .y(y),
						  .colour_out(colour)
						  );

								 
endmodule




//DATAPATH;
//*****************************************************************************
module datapath(clock, 
					//plot_blood, 
					plot_enemy, 
					plot,
					//bd1,bd2,bd3,bd4,bd5,bd6,bd7,bd8,bd9,gg,
					enemy_plot1, 
					enemy_plot2, enemy_plot3, enemy_plot4, 
					enemy_erase1, 
					enemy_erase2, enemy_erase3, enemy_erase4, 
					start_screen1, start_screen2, start_screen3, start_screen4,
					success,
					//finish_blood, 
					finish_enemy,
					x, y, colour_out); 
					
					
	input clock; 
	//input plot_blood;
	input plot_enemy;
	output plot; 
	
	//input bd1,bd2,bd3,bd4,bd5,bd6,bd7,bd8,bd9,gg;
	
	input enemy_plot1, enemy_plot2, enemy_plot3, enemy_plot4;
	input enemy_erase1, enemy_erase2, enemy_erase3, enemy_erase4;
	input start_screen1, start_screen2, start_screen3, start_screen4;
	input success;
	
	output reg [8:0] x; 
	output reg [7:0] y; 
	output reg [23:0] colour_out; 	
	//output reg finish_blood; //feed back to bloodfsm;
	output reg finish_enemy; //feed back to enemyfsm;    
		
	reg [8:0] start_x; 
	reg [7:0] start_y;

	
	
	assign plot = plot_enemy; 
		
		
	
	always @(posedge clock)
		begin 
					//for ENEMY FSM 
					//-------------------
					//draw
				if(plot_enemy) begin 
					
					if (start_screen1) begin 
						start_x <= 9'd0;
						start_y <= 8'd0; 
					end
					
					if (start_screen2) begin 
						start_x <= 9'd159;
						start_y <= 8'd0; 
					end
					
					if (start_screen3) begin 
						start_x <= 9'd0; 
						start_y <= 8'd119;
					end
					
					if (start_screen4) begin 
						start_x <= 9'd159; 
						start_y <= 8'd119;
					end
					
					
					if(enemy_plot1) begin 
						start_x <= 9'd64;
						start_y <= 8'd124; 
					end
					
					if(enemy_plot2) begin 
						start_x <= 9'd131;
						start_y <= 8'd131; 
					end 
					
					if(enemy_plot3) begin 
						start_x <= 9'd174;
						start_y <= 8'd132; 
					end 
					
					if(enemy_plot4) begin 
						start_x <= 9'd209;
						start_y <= 8'd109; 
					end
					
					
					//Erase
					if(enemy_erase1) begin 
						start_x <= 9'd64;
						start_y <= 8'd124; 
					end
					
					if(enemy_erase2) begin 
						start_x <= 9'd131;
						start_y <= 8'd131; 
					end 
					
					if(enemy_erase3) begin 
						start_x <= 9'd174;
						start_y <= 8'd132; 
					end 
					
					if(enemy_erase4) begin 
						start_x <= 9'd209;
						start_y <= 8'd109; 
					end
				
				
					//success screen;
				
					if(success) begin 
						start_x <= 9'd96;
						start_y <= 9'd88;
					end 
				end  
		end 

		
		//counters for drawing
	
		//-----------------------------------------------------
		//for enemy; 
		reg [7:0] start1_x;
		reg [6:0] start1_y; 
		
		reg [7:0] start2_x;
		reg [6:0] start2_y;
		
		reg [7:0] start3_x;
		reg [6:0] start3_y;
		
		reg [7:0] start4_x;
		reg [6:0] start4_y;
		
		reg [6:0] count_successx; 
		reg [5:0] count_successy;
	
		reg [3:0] enemy_x1; 
		reg [5:0] enemy_y1;
		reg [3:0] enemy_x_e1; 
		reg [5:0] enemy_y_e1;
				
		reg [3:0] enemy_x2; 
		reg [5:0] enemy_y2;
		reg [3:0] enemy_x_e2; 
		reg [5:0] enemy_y_e2;
			
		reg [3:0] enemy_x3; 
		reg [5:0] enemy_y3;
		reg [3:0] enemy_x_e3; 
		reg [5:0] enemy_y_e3;
			
		reg [3:0] enemy_x4; 
		reg [5:0] enemy_y4;
		reg [3:0] enemy_x_e4; 
		reg [5:0] enemy_y_e4;
		
		always @(posedge clock)
		begin 
		finish_enemy <= 0; 
			
			if (start_screen1) begin 
				if (start1_x == 8'd159)
						start1_y <= start1_y + 1; 
				if (start1_x == 8'd159 && start1_y == 7'd119)
					begin 
						start1_x <= 8'd0; 
						start1_y <= 7'd0; 
						finish_enemy <= 1; 
					end 
			
				else 
					start1_x <= start1_x + 1;
			
			end 
			
			if (start_screen2) begin 
				if (start2_x == 8'd159)
						start2_y <= start2_y + 1; 
				if (start2_x == 8'd159 && start2_y == 7'd119)
					begin 
						start2_x <= 8'd0; 
						start2_y <= 7'd0; 
						finish_enemy <= 1; 
					end 
			
				else 
					start2_x <= start2_x + 1; 
			end 
			
			if (start_screen3) begin 
				if (start3_x == 8'd159)
						start3_y <= start3_y + 1; 
				if (start3_x == 8'd159 && start3_y == 7'd119)
					begin 
						start3_x <= 8'd0; 
						start3_y <= 7'd0; 
						finish_enemy <= 1; 
					end 
			
				else 
					start3_x <= start3_x + 1;
			end 
			
			if (start_screen4) begin 
				if (start4_x == 8'd159)
						start4_y <= start4_y + 1; 
				if (start4_x == 8'd159 && start4_y == 7'd119)
					begin 
						start4_x <= 8'd0; 
						start4_y <= 7'd0; 
						finish_enemy <= 1; 
					end 
			
				else 
					start4_x <= start4_x + 1;
			end 
			
			
			
			//SUCCESS 
			if (success) begin 
			
				if (count_successx == 7'd127)
						count_successy <= count_successy + 1; 
				if (count_successx == 7'd127 && count_successy == 6'd63)
					begin 
						count_successx <= 7'd0; 
						count_successy <= 6'd0; 
						finish_enemy <= 1; 
					end 
			
				else 
					count_successx <= count_successx + 1;  
			end 
			
			
			//counters for enemy image; 
			//========================
			//enemy; 
			
			//Enemy1
			if (enemy_plot1) begin 
				if (enemy_x1 == 4'd14)
					enemy_y1 <= enemy_y1 + 1;
					
				if (enemy_x1 == 4'd14 && enemy_y1 == 6'd30)
					begin 
						enemy_x1 <= 4'd0; 
						enemy_y1 <= 6'd0;
					end 
				else
					enemy_x1 <= enemy_x1 + 1;  
			end 
		
			
			if (enemy_erase1) begin 
			
				if (enemy_x_e1 == 4'd14)
					enemy_y_e1 <= enemy_y_e1 + 1; 
				if (enemy_x_e1 == 4'd14 && enemy_y_e1 == 6'd30)
					begin 
						enemy_x_e1 <= 4'd0; 
						enemy_y_e1 <= 6'd0;
						finish_enemy <= 1;
					end 
				else
					enemy_x_e1 <= enemy_x_e1 + 1;
			end 
			
			//Enemy2
			if (enemy_plot2) begin 
				if (enemy_x2 == 4'd14)
					enemy_y2 <= enemy_y2 + 1; 
				if (enemy_x2 == 4'd14 && enemy_y2 == 6'd32)
					begin 
						enemy_x2 <= 4'd0; 
						enemy_y2 <= 6'd0; 
					end 
				else
					enemy_x2 <= enemy_x2 + 1;  
			end 
		
			
			if (enemy_erase2) begin 
			
				if (enemy_x_e2 == 4'd14)
					enemy_y_e2 <= enemy_y_e2 + 1; 
				if (enemy_x_e2 == 4'd14 && enemy_y_e2 == 6'd32)
					begin 
						enemy_x_e2 <= 4'd0; 
						enemy_y_e2 <= 6'd0;
						finish_enemy <= 1; 
					end 
				else
					enemy_x_e2 <= enemy_x_e2 + 1;
			end 
			
			//Enemy3
			if (enemy_plot3) begin 
				if (enemy_x3 == 4'd14)
					enemy_y3 <= enemy_y3 + 1; 
				if (enemy_x3 == 4'd14 && enemy_y3 == 6'd29)
					begin 
						enemy_x3 <= 4'd0; 
						enemy_y3 <= 6'd0;
					end 
				else
					enemy_x3 <= enemy_x3 + 1;  
			end 
		
			
			if (enemy_erase3) begin 
			
				if (enemy_x_e3 == 4'd14)
					enemy_y_e3 <= enemy_y_e3 + 1; 
				if (enemy_x_e3 == 4'd14 && enemy_y_e3 == 6'd29)
					begin 
						enemy_x_e3 <= 4'd0; 
						enemy_y_e3 <= 6'd0;
						finish_enemy <= 1; 
					end 
				else
					enemy_x_e3 <= enemy_x_e3 + 1;
			end 
			
			//Enemy4 
			if (enemy_plot4) begin 
				if (enemy_x4 == 4'd14)
					enemy_y4 <= enemy_y4 + 1; 
				if (enemy_x4 == 4'd14 && enemy_y4 == 6'd24)
					begin 
						enemy_x4 <= 4'd0; 
						enemy_y4 <= 6'd0;
					end 
				else
					enemy_x4 <= enemy_x4 + 1;  
			end 
		
			
			if (enemy_erase4) begin 
			
				if (enemy_x_e4 == 4'd14)
					enemy_y_e4 <= enemy_y_e4 + 1; 
				if (enemy_x_e4 == 4'd14 && enemy_y_e4 == 6'd24)
					begin 
						enemy_x_e4 <= 4'd0; 
						enemy_y_e4 <= 6'd0;
						finish_enemy <= 1; 
					end 
				else
					enemy_x_e4 <= enemy_x_e4 + 1;
			end 
			
		end
			
		
		
	
		//*************************************************************************
		//Wire connections; 
		//*************************************************************************
			
		//reset start screen
		//FISRST
		wire [8:0] START1_X; 
		wire [7:0] START1_Y; 
		wire [14:0] address_start1; 
		wire [23:0] colour_start1; 
		
		assign START1_X = start_x + start1_x; 
		assign START1_Y = start_y + start1_y; 
		assign address_start1 = (start1_y)*160 + start1_x; 
		
		//ROM START1
		
		
		
			
			
		//SECOND 
		wire [8:0] START2_X; 
		wire [7:0] START2_Y; 
		wire [14:0] address_start2; 
		wire [23:0] colour_start2;
		
		assign START2_X = start_x + start2_x; 
		assign START2_Y = start_y + start2_y; 
		assign address_start2 = (start2_y)*160 + start2_x; 
		
		//ROM START2
		
		
		
		
		
		
		//THIRD 
		wire [8:0] START3_X; 
		wire [7:0] START3_Y; 
		wire [14:0] address_start3; 
		wire [23:0] colour_start3;
		
		assign START3_X = start_x + start3_x; 
		assign START3_Y = start_y + start3_y; 
		assign address_start3 = (start3_y)*160 + start3_x; 
		
		//ROM START3
		
		
		
		
		
		
		//FOURTH
		wire [8:0] START4_X; 
		wire [7:0] START4_Y; 
		wire [14:0] address_start4; 
		wire [23:0] colour_start4;
	
		assign START4_X = start_x + start4_x; 
		assign START4_Y = start_y + start4_y; 
		assign address_start4 = (start4_y)*160 + start4_x; 
	
		//ROM START4
		
	
	
	
	
	
			
		//----------------------------------------------
		//SUCCESS
		wire [8:0] success_x; 
		wire [7:0] success_y;
		wire [12:0] address_success;
		wire [23:0] colour_success;
		
		
		assign success_x = start_x + count_successx; 
		assign success_y = start_y + count_successy; 
		assign address_success = (count_successy)*128 + count_successx; 
	
		//Success ROM
		success win(.address(address_success),
						.clock(clock), 
						.q(colour_success)
						);
			
		
		//Enemys  
		//===============================
		//-------------------------------------------
		//Enemy_1
		wire [8:0] ENEMY_X_1; 
		wire [7:0] ENEMY_Y_1;
		wire [8:0] address_enemy1;
		wire [23:0] colour_enemy1;
		
		assign ENEMY_X_1 = start_x + enemy_x1;
		assign ENEMY_Y_1 = start_y + enemy_y1; 
		assign address_enemy1 = (enemy_y1)*15 + enemy_x1;  
		
		
		//enemy1 Draw ROM 
		enemy1 draw1(.address(address_enemy1),
						.clock(clock),
						.q(colour_enemy1)
						);
		
		
		wire [8:0] ENEMY_X_1_ERASE; 
		wire [7:0] ENEMY_Y_1_ERASE;
		wire [8:0] address_enemy1_ERASE;
		wire [23:0] colour_enemy1_erase;
		
		
		assign ENEMY_X_1_ERASE = start_x + enemy_x_e1;
		assign ENEMY_Y_1_ERASE = start_y + enemy_y_e1; 
		assign address_enemy1_ERASE = (enemy_y_e1)*15 + enemy_x_e1;  
		
		
		//enemy1 Erase ROM 
		enemyback1 erase1(.address(address_enemy1_ERASE),
								.clock(clock),
								.q(colour_enemy1_erase)
								);
		
		//-----------------------------------------
		//Enemy_2
		wire [8:0] ENEMY_X_2; 
		wire [7:0] ENEMY_Y_2;
		wire [8:0] address_enemy2;
		wire [23:0] colour_enemy2;
		
		assign ENEMY_X_2 = start_x + enemy_x2;
		assign ENEMY_Y_2 = start_y + enemy_y2; 
		assign address_enemy2 = (enemy_y2)*15 + enemy_x2;
		
		//enemy2 Draw ROM 
		enemy2 draw2(.address(address_enemy2),
						.clock(clock),
						.q(colour_enemy2)
						);
		
		
		wire [8:0] ENEMY_X_2_ERASE; 
		wire [7:0] ENEMY_Y_2_ERASE;
		wire [8:0] address_enemy2_ERASE;
		wire [23:0] colour_enemy2_erase;
		
		assign ENEMY_X_2_ERASE = start_x + enemy_x_e2;
		assign ENEMY_Y_2_ERASE = start_y + enemy_y_e2; 
		assign address_enemy2_ERASE = (enemy_y_e2)*15 + enemy_x_e2; 
		
		//enemy2 Erase ROM 
		enemyback2 erase2(.address(address_enemy2_ERASE),
								.clock(clock),
								.q(colour_enemy2_erase)
								);
		
		//-------------------------------------------
		//Enemy_3
		wire [8:0] ENEMY_X_3; 
		wire [7:0] ENEMY_Y_3;
		wire [8:0] address_enemy3;
		wire [23:0] colour_enemy3;
		
		
		assign ENEMY_X_3 = start_x + enemy_x3;
		assign ENEMY_Y_3 = start_y + enemy_y3; 
		assign address_enemy3 = (enemy_y3)*15 + enemy_x3;

		//enemy3 Draw ROM 
		enemy3 draw3(.address(address_enemy3),
						.clock(clock),
						.q(colour_enemy3)
						);
		
		
		wire [8:0] ENEMY_X_3_ERASE; 
		wire [7:0] ENEMY_Y_3_ERASE;
		wire [8:0] address_enemy3_ERASE;
		wire [23:0] colour_enemy3_erase;
		
		assign ENEMY_X_3_ERASE = start_x + enemy_x_e3;
		assign ENEMY_Y_3_ERASE = start_y + enemy_y_e3; 
		assign address_enemy3_ERASE = (enemy_y_e3)*15 + enemy_x_e3; 
		
		//enemy3 Erase ROM 
		enemyback3 erase3(.address(address_enemy3_ERASE),
								.clock(clock),
								.q(colour_enemy3_erase)
								);
		
		
		
		//---------------------------------------------
		//Enemy_4
		wire [8:0] ENEMY_X_4; 
		wire [7:0] ENEMY_Y_4;
		wire [8:0] address_enemy4;
		wire [23:0] colour_enemy4;
		
		assign ENEMY_X_4 = start_x + enemy_x4;
		assign ENEMY_Y_4 = start_y + enemy_y4; 
		assign address_enemy4 = (enemy_y4)*15 + enemy_x4;
		
		//enemy4 Draw ROM 
		enemy4 draw4(.address(address_enemy4),
						.clock(clock),
						.q(colour_enemy4)
						);
		
		
		wire [8:0] ENEMY_X_4_ERASE; 
		wire [7:0] ENEMY_Y_4_ERASE;
		wire [8:0] address_enemy4_ERASE;
		wire [23:0] colour_enemy4_erase;
		
		assign ENEMY_X_4_ERASE = start_x + enemy_x_e4;
		assign ENEMY_Y_4_ERASE = start_y + enemy_y_e4; 
		assign address_enemy4_ERASE = (enemy_y_e4)*15 + enemy_x_e4; 
		
		//enemy4 Erase ROM 
		enemyback4 erase4(.address(address_enemy4_ERASE),
								.clock(clock),
								.q(colour_enemy4_erase)
								);
		
		
		//************************************************************
		//MUX SELECTION; 
		//ASSIGN X, Y, COLOUR;
		//====================
		//always @(*)
		always @(posedge clock)
			begin 
				if (start_screen1) begin 
					x <= START1_X;
					y <= START1_Y;
					colour_out <= colour_start1;
				end 
			
				if (start_screen2) begin 
					x <= START2_X;
					y <= START2_Y;
					colour_out <= colour_start2;
				end 
			
				if (start_screen3) begin 
					x <= START3_X;
					y <= START3_Y; 
					colour_out <= colour_start3;
				end 
			
				if (start_screen4) begin 
					x <= START4_X;
					y <= START4_Y; 
					colour_out <= colour_start4;
				end 
			
				if (enemy_plot1) begin 
					x <= ENEMY_X_1;
					y <= ENEMY_Y_1;
				   colour_out <= colour_enemy1;
				end
				
				if (enemy_plot2) begin
					x <= ENEMY_X_2;
					y <= ENEMY_Y_2;
					colour_out <= colour_enemy2;
				end 
				
				if (enemy_plot3) begin
					x <= ENEMY_X_3;
					y <= ENEMY_Y_3;
					colour_out <= colour_enemy3;
				end 
				
				if (enemy_plot4) begin
					x <= ENEMY_X_4;
					y <= ENEMY_Y_4;
					colour_out <= colour_enemy4;
				end 
				
				
				if (enemy_erase1) begin 
					x <= ENEMY_X_1_ERASE;
					y <= ENEMY_Y_1_ERASE;
					colour_out <= colour_enemy1_erase;
				end
				
				if (enemy_erase2) begin
					x <= ENEMY_X_2_ERASE;
					y <= ENEMY_Y_2_ERASE;
					colour_out <= colour_enemy2_erase;
				end
				
				if (enemy_erase3) begin
					x <= ENEMY_X_3_ERASE;
					y <= ENEMY_Y_3_ERASE;
					colour_out <= colour_enemy3_erase;
				end
				
				if (enemy_erase4) begin
					x <= ENEMY_X_4_ERASE;
					y <= ENEMY_Y_4_ERASE;
					colour_out <= colour_enemy4_erase;
				end
				
				if (success) begin 
					x <= success_x;
					y <= success_y;
					colour_out <= colour_success;
				end 
			
		//-----------------------------------	
				/*
				else begin 
					x <= 9'd0;
					y <= 8'd0;
					colour_out <= 23'd0;
				end
				*/
				
			end
			
endmodule




//ENEMY FSM;
//***********************************************************************************************
module enemyfsm(clock, reset, enable, finish_enemy, shoot1, shoot2, shoot3, shoot4, 
					enemy_plot1, 
					enemy_plot2, enemy_plot3, enemy_plot4, 
					enemyon,
					enemy_erase1, 
					enemy_erase2, enemy_erase3, enemy_erase4, 
					start_screen1, start_screen2, start_screen3, start_screen4,
					plot, success);
	
	input clock, reset, enable, finish_enemy, shoot1, shoot2, shoot3, shoot4; 
	output reg plot, success; 
	output reg enemy_plot1, enemy_plot2, enemy_plot3, enemy_plot4;
	output reg enemyon; 
	output reg enemy_erase1, enemy_erase2, enemy_erase3, enemy_erase4;
	output reg start_screen1, start_screen2, start_screen3, start_screen4; 

	reg [4:0] currentstate; 
	reg [4:0] nextstate; 

	localparam [4:0] START1 = 5'd0,
						  START2 = 5'd1,
						  START3 = 5'd2,
						  START4 = 5'd3,
						  ENEMY1_WAIT = 5'd4,
						  ENEMY1_DRAW = 5'd5,
						  ERASE_ENEMY1 = 5'd6,
						  
						  ENEMY2_WAIT = 5'd7,
						  ENEMY2_DRAW = 5'd8, 
						  ERASE_ENEMY2 = 5'd9,
						  
						  ENEMY3_WAIT = 5'd10,
						  ENEMY3_DRAW = 5'd11, 
						  ERASE_ENEMY3 = 5'd12,
						  
						  ENEMY4_WAIT = 5'd13, 
						  ENEMY4_DRAW = 5'd14, 
						  ERASE_ENEMY4 = 5'd15,
						  
						  ENDSCREEN = 5'd16;
						  
						  //MORE TO COME
	
	always @(*)
		begin 
			case(currentstate)
				
				START1: nextstate = finish_enemy ? START2 : START1;
				START2: nextstate = finish_enemy ? START3 : START2;
				START3: nextstate = finish_enemy ? START4 : START3;
				START4: nextstate = finish_enemy ? ENEMY1_WAIT : START4; 
		
			
				//SEQUEENCE-->1324
				ENEMY1_WAIT: nextstate =  enable ? ENEMY1_DRAW : START; 
				ENEMY1_DRAW: nextstate = (shoot1|enable) ? ERASE_ENEMY1 : ENEMY1_DRAW;
				//ENEMY1_DRAW: nextstate = shoot1 ? ERASE_ENEMY1 : ENEMY1_DRAW;
				//ENEMY1_DRAW: nextstate = enable ? ERASE_ENEMY1 : ENEMY1_DRAW;
				 
				//ERASE_ENEMY1: nextstate = finish_enemy ? ENDSCREEN : ERASE_ENEMY1;  	
				
				ERASE_ENEMY1: nextstate = finish_enemy ? ENEMY3_WAIT : ERASE_ENEMY1;
				
				ENEMY3_WAIT: nextstate = enable ? ENEMY3_DRAW : ENEMY3_WAIT;
				ENEMY3_DRAW: nextstate = (shoot3|enable) ? ERASE_ENEMY3 : ENEMY3_DRAW;
				ERASE_ENEMY3: nextstate = finish_enemy ? ENEMY2_WAIT : ERASE_ENEMY3;
				
				ENEMY2_WAIT: nextstate = enable ? ENEMY2_DRAW : ENEMY2_WAIT;
				ENEMY2_DRAW: nextstate = (shoot2|enable) ? ERASE_ENEMY2 : ENEMY2_DRAW;
				ERASE_ENEMY2: nextstate = finish_enemy ? ENEMY4_WAIT : ERASE_ENEMY2;
				
				ENEMY4_WAIT: nextstate = enable ? ENEMY4_DRAW : ENEMY4_WAIT;
				ENEMY4_DRAW: nextstate = (shoot4|enable) ? ERASE_ENEMY4 : ENEMY4_DRAW;
				ERASE_ENEMY4: nextstate = finish_enemy ? ENDSCREEN : ERASE_ENEMY4;
				
				ENDSCREEN : nextstate = ~reset ? START : ENDSCREEN; 
				default: nextstate = START; 
			endcase
		end 
				
				
	always @(*)
		begin 
			plot = 1'b0;
			start_screen1 = 1'b1;
			start_screen2 = 1'b1;
			start_screen3 = 1'b1;
			start_screen4 = 1'b1;
			enemy_plot1 = 1'b0;
			enemy_plot2 = 1'b0;
			enemy_plot3 = 1'b0;
			enemy_plot4 = 1'b0;
			enemyon = 1'b0; 
			enemy_erase1 = 1'b0;
			enemy_erase2 = 1'b0;
			enemy_erase3 = 1'b0;
			enemy_erase4 = 1'b0;
			success = 1'b0;
			
			case(currentstate)
					
				START1: begin 
					plot = 1'b1;  
					start_screen1 = 1'b1; 
				end 
				
				START2: begin 
					plot = 1'b1; 
					start_screen2 = 1'b1;
				end 
				
				START3: begin 
					plot = 1'b1;
					start_screen3 = 1'b1;
				end 
					
				START4: begin 
					plot = 1'b1;
					start_screen4 = 1'b1;
				end 
					
					
				ENEMY1_DRAW: begin 	
					plot = 1'b1;
					enemy_plot1 = 1'b1;					
					enemyon = 1'b1; 
				end 
			
				ERASE_ENEMY1: begin 
					plot = 1'b1;
					enemy_erase1 = 1'b1;
				end
				
				ENEMY2_DRAW: begin 	
					plot = 1'b1;
					enemy_plot2 = 1'b1;					
					enemyon = 1'b1; 
				end 
			
				ERASE_ENEMY2: begin 
					plot = 1'b1;
					enemy_erase2 = 1'b1;
				end
				
				ENEMY3_DRAW: begin 	
					plot = 1'b1;
					enemy_plot3 = 1'b1;					
					enemyon = 1'b1; 
				end 
			
				ERASE_ENEMY3: begin 
					plot = 1'b1;
					enemy_erase3 = 1'b1;
				end
				
				ENEMY4_DRAW: begin 	
					plot = 1'b1;
					enemy_plot4 = 1'b1;					
					enemyon = 1'b1; 
				end 
			
				ERASE_ENEMY4: begin 
					plot = 1'b1;
					enemy_erase4 = 1'b1;
				end
				
				
				ENDSCREEN: begin 
					plot = 1'b1;
					success = 1'b1;
				end
				
			endcase 
		end
		
		
	always @(posedge clock)
		begin
			if (!reset)
				currentstate <= START;  
			else	
				currentstate <= nextstate;
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












