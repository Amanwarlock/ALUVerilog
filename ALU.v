//I am using iVerilog, downloaded from http://bleyer.org/icarus/
//For OSX we are using iVerilog, downloaded from MacPorts
// iverilog -o alu.vvp ALU.v
// vvp alu.vvp

//multiplication circuit
module MULTIPLY(x, y, mult_out);
	//define inputs
	input [15:0] x, y;

	//define outputs
	output [15:0] mult_out;

	//develop circuitry for outputs
	assign mult_out = x * y;

endmodule

//divide circuit
module DIVIDE(x, y, div_out);
	//define inputs
	input [15:0] x, y;
	//define outputs
	output [15:0] div_out;

	//because division is hard we use /
	assign div_out = x / y;

endmodule

//Multiplexer
module MUX4(a3, a2, a1, a0, s, mux4_out);
	parameter k = 16;
	input [15:0] a3, a2, a1, a0;  // inputs
	input [3:0]   s; // one-hot select
	output[15:0] mux4_out;
	assign mux4_out = ({k{s[3]}} & a3) | 
				({k{s[2]}} & a2) | 
				({k{s[1]}} & a1) |
				({k{s[0]}} & a0);
endmodule

//D-Flip-Flop
module DFF16(clk, in, dff_out);
	input clk;
	input[15:0] in;
	output[15:0] dff_out;
	reg[15:0] dff_out;
	
	always @(posedge clk) begin
		begin
			dff_out = in;
		end
	end
endmodule

module DFF2(clk, in, dff_out);
	input clk;
	input[31:0] in;
	output[31:0] dff_out;
	reg[31:0] dff_out;
	
	always @(posedge clk) begin
		begin
			dff_out = in;
		end
	end
endmodule

//ADDERS
module ADD_HALF (input x, y, output c_out, sum);
	xor G1(sum, x, y);	// Gate instance names are optional
	and G2(c_out, x, y);
endmodule
//-----------------------------------------------------------------------------
module ADD_FULL (input a, b, c_in, output c_out, sum);	 
	wire w1, w2, w3;				// w1 is c_out; w2 is sum
	ADD_HALF M1 (a, b, w1, w2);
	ADD_HALF M0 (w2, c_in, w3, sum);
	or (c_out, w1, w3);
endmodule
//-----------------------------------------------------------------------------
module ADD_4 (input [3:0] a, b, input c_in, output c_out, output [3:0] sum);
	wire c_in1, c_in2, c_in3, c_in4;			// Intermediate carries
	ADD_FULL M0 (a[0], b[0], c_in,  c_in1, sum[0]);
	ADD_FULL M1 (a[1], b[1], c_in1, c_in2, sum[1]);
	ADD_FULL M2 (a[2], b[2], c_in2, c_in3, sum[2]);
	ADD_FULL M3 (a[3], b[3], c_in3, c_out, sum[3]);
endmodule
//-----------------------------------------------------------------------------
module ADD_8 (input [7:0] a, b, input c_in, output c_out, output [7:0] sum);
	wire c_in4;
	ADD_4 M0 (a[3:0], b[3:0], c_in, c_in4, sum[3:0]);
	ADD_4 M1 (a[7:4], b[7:4], c_in4, c_out, sum[7:4]);
endmodule
//-----------------------------------------------------------------------------
module ADD (input [15:0] a, b, input c_in, output c_out, output [15:0] sum);
   wire c_in4;
   ADD_8 M0 (a[7:0], b[7:0], c_in, c_in4, sum[7:0]);
   ADD_8 M1 (a[15:8], b[15:8], c_in4, c_out, sum[15:8]);
endmodule


module AND(x,y,z);
	input[15:0] x,y;          
	output[15:0] z;    
 
	assign z = x & y;
endmodule
 
module NAND(x,y,z);
	input[15:0] x,y;          
	output[15:0] z;    
   
	assign z = ~(x & y);
endmodule
 
module SHIFT_LEFT(shift, in, out);
	input[4:0] shift;
	input[15:0] in;
	output[15:0] out;
 
	assign out = in << shift;
endmodule
 
module SHIFT_RIGHT(shift, in, out);
	input[4:0] shift;
	input[15:0] in;
	output[15:0] out;
 
	assign out = in >> shift;
endmodule
   
module OR(a, b, c);
	parameter n = 16;
	input[n-1:0] a, b;
	output[n-1:0] c;

	assign c = a | b;
endmodule

module NOR(a, b, c);
	parameter n = 16;
	input[n-1:0] a, b;
	output[n-1:0] c;
	
	assign c = ~(a | b);
endmodule

module MUX2(a1, a0, s, b);
	parameter k = 16;
	input [k-1:0] a1, a0;
	input [1:0] s;
	output[k-1:0] b;
	assign b = ({k{s[1]}} & a1) |
				({k{s[0]}} & a0);
endmodule

//-----------------------------------------------------------------------------
module XOR(a, b, c);
	input [15:0] a;
	input [15:0] b;
	output [15:0] c;
	assign c = a ^ b;
endmodule

//-----------------------------------------------------------------------------
module XNOR(a, b, c);
	input [15:0] a;
	input [15:0] b;
	output [15:0] c;
	assign c = ~(a ^ b);
endmodule


module Input_registers(clk, a_in, b_in, acc_val, a_s, b_s, a_out, b_out);
	parameter n = 16;
	
	input clk;
	
	//inputs and outputs to the entire section
	input [n-1:0] a_in, b_in, acc_val;	//a&b and current accumulator value
	input [1:0] a_s;		//2 bit one-hot selector
	input [3:0] b_s;		//4 bit one-hot selector
	output [n-1:0] a_out, b_out;
	
	
	//wires
	wire [n-1:0] muxA_out;
	wire [n-1:0] muxB_out;
	wire [n-1:0] a_out, b_out;
	
	//module instantiations for the two muxes and two d flip-flops
	MUX2 #(n) muxA(a_in, a_out, a_s, muxA_out);
	MUX4 #(n) muxB(16'b0000000000000000, b_in, acc_val, b_out, b_s, muxB_out);
	DFF16  #(n) selectedA(clk, muxA_out, a_out);
	DFF16  #(n) selectedB(clk, muxB_out, b_out);
endmodule


module testbench();
 
	reg [15:0] one;
	reg [15:0] two;
	reg [4:0] three;
	wire [15:0] out1;
	wire [15:0] out2;
	wire [15:0] out3;
	
	XOR testXor(one, two, out1);
	XNOR testXnor(one, two, out2);
	SHIFT_RIGHT testShiftRight(one, three, out3);

	// Inputs
	reg[15:0]       in;
	reg[4:0]        shift;
	reg             clk;
	reg[15:0]           x;
	reg[15:0]           y;
	reg[1:0]            a;
	reg[1:0]            b;
	wire[3:0]           out;
	wire[15:0]          andres;
	wire[15:0]          nandres;
   
	// Output from module
	wire[15:0]      shifted;
   
	SHIFT_LEFT sL (shift, in, shifted);
	AND anding(x,y, andres);
	NAND nanding(x,y, nandres);
	initial begin
	   
		a = 3;
		b = 3;
		#10
		$display("mult: %1b", out);
	   
	   
	   x = 65535;
	   y = 0;
	   #10
	   $display ("x:    %1b", x);
	   $display ("y:    %1b", y);
	   $display ("AND:  %1b", andres);
	   $display ("NAND: %1b", nandres);
	   
		in = 11;
		shift = 5;
		#10 // Wait
	   
		$display ("Input:   %1b", in);
		$display ("Left Shift: ", shift);
		$display ("Shifted: %1b", shifted);
	   
		in = shifted;
		shift = 2;
		#10
		$display ("Left Shift: ", shift);
		$display ("Shifted: %1b", shifted);
		#10
		$finish;

		one = 16'b0000000011111111;
		 two = 16'b0000111100001111;
		 three = 4'b0111;
		 
		 #10
		 $display("    input 1     |     input 2    |     xor out     |    xnor out   |    shift out   ");
		 $display("%15b|%15b|%15b|%15b|%15b", one, two, out1, out2, out3);
		 
		 #10
		 $finish;
	end
   
	//---------------------------------------------
	// Clock Control
	//---------------------------------------------
	initial begin
	  forever
		begin
			#5
			clk = 0 ;
			#5
			clk = 1 ;
		end
	end

endmodule