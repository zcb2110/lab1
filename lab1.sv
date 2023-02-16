// CSEE 4840 Lab 1: Run and Display Collatz Conjecture Iteration Counts
//
// Spring 2023
//
// By: Alan Hwang, Zach Burpee
// Uni: awh2135

module lab1( input logic        CLOCK_50,  // 50 MHz Clock input
	     
	     input logic [3:0] 	KEY, // Pushbuttons; KEY[0] is rightmost

	     input logic [9:0] 	SW, // Switches; SW[0] is rightmost

	     // 7-segment LED displays; HEX0 is rightmost
	     output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,

	     output logic [9:0] LEDR // LEDs above the switches; LED[0] on right
	     );

   logic 			clk, go, done, flag, up, down, reset, set_switches, increment;   
   logic [31:0] 		start;
   logic [15:0] 		count;
   logic [15:0]			display;
   logic [15:0]			check;
   logic [7:0]			max_count;	// 255 counter

   logic [11:0] 		n;
   logic [11:0]			temp_n;
   logic [6:0] y0, y1, y2, y3, y4, y5;
   logic [22:0]                 start_counter;

   assign clk = CLOCK_50;
 
   range #(256, 8) // RAM_WORDS = 256, RAM_ADDR_BITS = 8)
         r (.clk(clk),
	    .go(go),
            .start(start),
            .done(done),
            .count(count)
           ); // Connect everything with matching names

    hex7seg h (.a(n[3:0]),
               .y(y0) 
              );

    hex7seg h1 (.a(n[7:4]),
               .y(y1)
              );

    hex7seg h2 (.a(n[11:8]),
                .y(y2)
              );

    hex7seg h3 (.a(display[3:0]),
                .y(y3)
              );

    hex7seg h4 (.a(display[7:4]),
                .y(y4)
              );

    hex7seg h5 (.a(display[11:8]),
                .y(y5)
              );


   // Replace this comment and the code below it with your own code;
   // The code below is merely to suppress Verilator lint warnings

   assign HEX5 = y2;
   assign HEX4 = y1;
   assign HEX3 = y0;
  
   assign HEX2 = y5;
   assign HEX1 = y4;
   assign HEX0 = y3;

   assign LEDR = SW;
 
   //assign n[0] = (SW[0] == 'd1) ? 'd1 : 'd0;
   //assign n[1] = (SW[1] == 'd1) ? 'd1 : 'd0;
   //assign n[2] = (SW[2] == 'd1) ? 'd1 : 'd0;
   //assign n[3] = (SW[3] == 'd1) ? 'd1 : 'd0;
   //assign n[4] = (SW[4] == 'd1) ? 'd1 : 'd0;
   //assign n[5] = (SW[5] == 'd1) ? 'd1 : 'd0;
   //assign n[6] = (SW[6] == 'd1) ? 'd1 : 'd0;
   //assign n[7] = (SW[7] == 'd1) ? 'd1 : 'd0;
   //assign n[8] = (SW[8] == 'd1) ? 'd1 : 'd0;
   //assign n[9] = (SW[9] == 'd1) ? 'd1 : 'd0;



   assign go = (KEY[3] == 'd0) ? 'd1 : 'd0;
   assign up = (KEY[0] == 'd0) ? 'd1 : 'd0;
   assign down = (KEY[1] == 'd0) ? 'd1 : 'd0;
   assign reset = (KEY[2] == 'd0) ? 'd1 : 'd0;
   
   initial set_switches = 'd1;
   initial max_count = 8'd0; 
   initial start_counter = 23'd0;
   initial increment = 'd1;

   always_ff @(posedge clk) begin

      // Evaluate range
      if (go == 'd1) begin
	start[11:0] <= n[11:0];
	check[11:0] <= count[11:0];
	display[11:0] <= 12'd0;
	flag <= 0;

	// stop switches
	set_switches <= 'd0;
      end
      
      if (done == 1) begin
	start[11:0] <= 12'd0;
	flag <= 1;
      end 
      
      if (flag == 1) begin
	if (check[11:0] != count[11:0]) begin
	  display <= count;
	end
	else begin
	  display <= count - 16'd1;
	end
      end

      // Pushbuttons & switches
      // first use switches, then evaluate, then can change based on buttons, otherwise only reset and can use switches 
      // again

      // set_switches = 1 - means set n using switches (will NOT register push buttons until KEY[3] is pushed to eval count
      if (set_switches == 'd1) begin
	n[9:0] <= SW;
	temp_n[9:0] <= n[9:0];
      end

      else begin
	// push buttons (set_switches = 0)
	if (up == 'd1 && max_count < 8'b11111111 && increment == 'd1) begin
	  n[9:0] <= n[9:0] + 10'd1;
	  max_count <= max_count + 8'd1;
	  if (increment == 'd1) begin
	    increment <= 'd0;
	  end
	end
	else if (down == 'd1 && n > temp_n && increment == 'd1) begin
	  n[9:0] <= n[9:0] - 10'd1;
	  max_count <= max_count - 8'd1;
	  if (increment == 'd1) begin
	    increment <= 'd0;
	  end
	end
	else if (reset == 'd1) begin
	  n[9:0] <= temp_n[9:0];
	  max_count <= 8'd0;
	  set_switches <= 'd1;
	  increment <= 'd1;
	  display[11:0] <= 12'd0;
      flag <= 0;
	end

      end

      // Always increment start count once flag is set to start the counter for each second
	// Actually a *23 bit counter instead of the suggested 22 bit
	start_counter <= start_counter + 23'd1;
	if (start_counter == 23'h7FFFFF) begin
	  increment <= 'd1;
	  start_counter <= 23'd0;
	end
      /*
      if (flag == 1) begin
	if (check[11:0] != count[11:0]) begin
	  display <= count;
	end
	else begin
	  display <= count - 16'd1;
	end
      end
      */
   end    

endmodule
