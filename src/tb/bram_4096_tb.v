`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Group ##, ENTC 18, UOM
// Engineer: Vishva Oshada
// 
// Create Date: 01/19/2023 10:04:41 PM
// Design Name: 4096KB block ram
// Module Name: bram_4096_tb
// Project Name: System Bus Design
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module bram_4096_tb();
    reg clk;
    reg reset;
    reg r_en=0;
    reg w_en=0;
    reg [11:0]addr;
    reg [7:0] d_in;
    wire [7:0] d_out;
    wire reset_busy;
    
	
	
	bram_4096 BRAM_4096(
	   .clka(clk),
	   .rsta(reset),
	   .ena(r_en),
	   .wea(w_en),
	   .addra(addr),
	   .dina(d_in),
	   .douta(d_out),
	   .rsta_busy(reset_busy)
	);
	parameter CLK_PERIOD=10;
	initial begin 
            clk=0;
            forever #(CLK_PERIOD/2) clk <= ~clk;
    end
    
    initial begin
            @(posedge clk);//
                reset<=0;
            @(posedge clk);
                reset<=1;
            @(posedge clk);
                reset<=0;
                #(CLK_PERIOD*3);
            
            @(posedge clk);//writing data to 12'd2 address
                addr<=12'd2;
                d_in<=8'b10101010;
            
            @(posedge clk);//removing write enable signal
                w_en<=1'b1;
                #(CLK_PERIOD*4);
                w_en<=1'b0;
 
            @(posedge clk);//removing other signals related to writing
                addr<=12'd0;
                d_in<=8'b0;
                
            @(posedge clk);//removing other signals related to writing
                #(CLK_PERIOD*4);
                addr<=12'd2;
                
            @(posedge clk);//removing write enable signal
                #(CLK_PERIOD*1);
                r_en<=1'b1;
                #(CLK_PERIOD*4);
                r_en<=1'b0;
         
    end
endmodule
