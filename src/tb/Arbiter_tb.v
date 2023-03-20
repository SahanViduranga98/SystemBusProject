`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2023 11:09:38 AM
// Design Name: 
// Module Name: Arbiter_tb
// Project Name: 
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

module Arbiter_tb;
parameter CLOCK_PERIOD  = 4'b1010;
reg clk;
reg rst;

reg m1_request = 0;
reg m2_request = 0;
reg [1:0] m1_slave_sel;
reg [1:0] m2_slave_sel;
reg trans_done;

wire m1_grant;
wire m2_grant;
wire arbiter_busy;
wire [1:0] bus_grant; 
wire [1:0] slave_sel; 

Arbiter Arbiter(
.clk(clk), 
.rst(rst),
.m1_request(m1_request), 
.m2_request(m2_request),
.m1_slave_sel(m1_slave_sel),
.m2_slave_sel(m2_slave_sel),
.m1_grant(m1_grant),
.m2_grant(m2_grant),
.arbiter_busy(arbiter_busy),
.bus_grant(bus_grant), 
.slave_sel(slave_sel),
.trans_done(trans_done)
);

initial begin
    clk = 0;
    forever begin
        #(CLOCK_PERIOD/2);
        clk <= ~clk;
    end
end
	 
	initial begin
		#30 rst <= 1;
		
		//#30 rst <= 0; trans_done<=0; m1_request <= 0; m2_request <= 1; m1_slave_sel <= 2'b00; m2_slave_sel <= 2'b11;// Master 2 priority request
		
       #30 rst <= 0; trans_done<=0; m1_request <= 1; m2_request <= 0; m1_slave_sel <= 2'd2; m2_slave_sel <= 2'd0; // Master 1 request
		
		//#30 rst <= 0; trans_done<=0; m1_request <= 1; m2_request <= 1; m1_slave_sel <= 2'b01; m2_slave_sel <= 2'b10; // Master 1 & 2 request1
		
		//#20 rst <= 0;trans_done<=0;  m1_request <= 0; m2_request <= 1; m1_slave_sel <= 2'b00; m2_slave_sel <= 2'b11;// Master 2 priority request
		
		
		//#20 rst <= 0; m1_request <= 0; m2_request <= 1; m1_slave_sel <= 2'b00; m2_slave_sel <= 2'b10;// Master 2 priority request
		
		//#1 rst <= 0; m1_request <= 1; m1_slave_sel <= 2'b10; 
		
		//#5 rst <= 0; m1_request <= 0; m2_request <= 1; m2_slave_sel <= 2'b10; 

        //#20 rst = 1;
	end


endmodule
