`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2023 07:51:33 PM
// Design Name: 
// Module Name: Arbiter
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


module Arbiter(

input clk, 
input rst, //system reset 
input m1_request,
input m2_request,
input m1_slave_sel,
input m2_slave_sel,


output reg m1_grant,
output reg m2_grant,
output reg arbiter_busy,
output reg[1:0] bus_grant,
output reg[1:0] slave_sel 

);

parameter[2:0] IDLE_STATE = 3'd0;
parameter[2:0] MASTER1_REQUEST_STATE = 3'd1;
parameter[2:0] MASTER2_REQUEST_STATE  = 3'd2;



reg [2:0] state = IDLE_STATE;

always@(posedge clk or posedge rst)
begin
    if (rst == 1'b1)
        begin
            m1_grant <= 0;
            m2_grant <= 0;
            arbiter_busy <= 0;
            bus_grant <= 2'd0;
            slave_sel  <= 2'd0; 
        end
    // if master 1 request it since it is the highest priority master,
    // make the next state as MASTER1_REQUEST_STATE
    else if(m1_request == 1) 
        begin
            m1_grant <= 1;
            m2_grant <= 0;
            arbiter_busy <= 1;
            bus_grant <= 2'd1;
            slave_sel  <= 2'd0;
            state <= MASTER1_REQUEST_STATE;
         end
         
    // if master 2 request and master 1 is not acquiring the bus and arbiter is not busy
    // make the next state as MASTER2_REQUEST_STATE      
    else if((m2_request == 1) && (state != MASTER1_REQUEST_STATE) && (arbiter_busy != 1))
        begin
            m1_grant <= 0;
            m2_grant <= 1;
            arbiter_busy <= 1;
            bus_grant <= 2'd2;
            slave_sel  <= 2'd0;
            state <= MASTER2_REQUEST_STATE;
        end
     else
        begin
            m1_grant <= 0;
            m2_grant <= 0;
            arbiter_busy <= 0;
            bus_grant <= 2'd0;
            slave_sel  <= 2'd0;
            state <= IDLE_STATE;  
        end    

end

always @(posedge clk) 
    begin
        case(state)
        MASTER1_REQUEST_STATE :begin
        
        
        end
        
        endcase

    end
    


endmodule
