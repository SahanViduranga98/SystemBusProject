`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Create Date: 01/20/2023 07:51:33 PM
// Designer Name: Isuru Munasinghe
// Module Name: Arbiter
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


module Arbiter(

input clk, 
input rst, //system reset 
input m1_request,
input m2_request,
input [1:0] m1_slave_sel,
input [1:0] m2_slave_sel,
input trans_done,

output reg m1_grant,
output reg m2_grant,
output reg arbiter_busy,
output reg[1:0] bus_grant, //indicates the master address to which the slave communicates
output reg[1:0] slave_sel //indicates the slave address which was requested by the master

);

parameter[2:0] IDLE_STATE = 3'd0;
parameter[2:0] MASTER1_SLAVE_SELECT_STATE = 3'd1;
parameter[2:0] MASTER2_SLAVE_SELECT_STATE  = 3'd2;

reg [2:0] state = IDLE_STATE;

always@(posedge clk or posedge rst)
begin
    if (rst == 1'b1)
        begin
            m1_grant <= 0;
            m2_grant <= 0;
            arbiter_busy <= 0;
            bus_grant <= 2'b00;
            slave_sel <= 2'b00; 
        end
    // if master 1 request it since it is the highest priority master,
    // make the next state as MASTER1_REQUEST_STATE
        
     else if((m1_request == 1) )
         begin
             m1_grant <= 1;
             m2_grant <= 0;
             arbiter_busy <= 1;
             slave_sel <= m1_slave_sel;
             bus_grant <= 2'd1;
             state <= MASTER1_SLAVE_SELECT_STATE;
         end
         
    // if master 2 request and master 1 is not acquiring the bus and arbiter is not busy
    // make the next state as MASTER2_REQUEST_STATE      
    else if((m2_request == 1) && (arbiter_busy != 1) && (bus_grant!= 2'b01))
        begin
            m1_grant <= 0;
            m2_grant <= 1;
            arbiter_busy <= 1;
            slave_sel <= m2_slave_sel;
            bus_grant <= 2'd2;
            state <= MASTER2_SLAVE_SELECT_STATE;
        end
     else if((m2_request == 1))
     
       begin
           m1_grant <= 0;
           m2_grant <= 1;
           arbiter_busy <= 1;
           slave_sel <= m2_slave_sel;
           bus_grant <= 2'd2;
           state <= MASTER2_SLAVE_SELECT_STATE;
       end
     else
        begin
            m1_grant <= 0;
            m2_grant <= 0;
            arbiter_busy <= 0;
            slave_sel <= 0;
            bus_grant <= 2'd0;
            state <= IDLE_STATE;  
        end    

end

always @(posedge clk) 
    begin
        case(state)
        MASTER1_SLAVE_SELECT_STATE:
            if(trans_done == 1)
                begin
                    state<=IDLE_STATE;
                end
            else
                begin
                    slave_sel <= m1_slave_sel;
                    bus_grant <= 2'd1;
                    state<=MASTER1_SLAVE_SELECT_STATE;
                end    
             
        MASTER2_SLAVE_SELECT_STATE:
            if(trans_done == 1)
                begin
                    state <= IDLE_STATE;
                end
                else
                begin
                    slave_sel <= m2_slave_sel;
                    bus_grant <= 2'd2;
                    state<=MASTER2_SLAVE_SELECT_STATE;
                end 
                
        IDLE_STATE:
             begin
                m1_grant <= 0;
                m2_grant <= 0;
                arbiter_busy <= 0;
                bus_grant <= 2'b00;
                slave_sel <= 2'b00;      
             end
                    
        endcase
        
    end

endmodule
