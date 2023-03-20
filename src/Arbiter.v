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

input clk, //Both m1 and m2 clocks are equal
input rst,
input m1_request, //marks the start of the transmission
input m2_request,
input m1_slave_sel,
input m2_slave_sel,
input trans_done,

output reg m1_grant,
output reg m2_grant,
output reg arbiter_busy,
output reg bus_busy,

output reg[1:0] bus_grant,//to mux
output reg[1:0] slave_sel //to mux
);

parameter[2:0] IDLE_STATE = 3'd0;
parameter[2:0] MASTER1_REQUEST_STATE = 3'd1;
parameter[2:0] MASTER2_REQUEST_STATE  = 3'd2;
parameter[2:0] BUS_BUSY_STATE = 3'd3;



reg [2:0] arbiter_state = 0; //added later
reg [1:0] rx_m1_slave;
reg [1:0] rx_m2_slave;
reg [1:0] clk_count;
reg slave_sel_done;

reg previous_m1_grant;
reg previous_m2_grant;
reg [1:0]previous_grant;
reg [1:0]previous_slave_sel;

reg [1:0] slave_addr_state = 0;
wire start = m1_request || m2_request;


/////////////////////////////////////////////////
parameter 
idle = 0, 
addr1 = 1, 
addr2 = 2; 
/////////////////////////////////////////////////
always @(posedge clk or posedge rst) 
begin
    if (rst == 1'b1)
    begin
        rx_m1_slave <= 2'b0;
        rx_m2_slave <= 2'b0;
		slave_sel_done <= 1'b0;
		slave_addr_state <= idle;
        
    end
	else
    begin
		case (slave_addr_state)
			idle:begin
				if (start == 1 & arbiter_busy == 0 & bus_busy == 0)
				
				begin
				slave_addr_state <= addr1;
                rx_m1_slave[0] <= m1_slave_sel;
                rx_m2_slave[0] <= m2_slave_sel;
                slave_sel_done <= 1'b0;
				end
				
				else
				slave_addr_state <= idle;
                slave_sel_done <= 1'b0;
                end  
                  
	            addr1:begin
		        slave_addr_state <= addr2;
                rx_m1_slave[1] <= m1_slave_sel;
                rx_m2_slave[1] <= m2_slave_sel;
                end
                
                addr2: begin
                slave_addr_state <= idle;
                slave_sel_done = 1'b1;
                end
                
                default: begin
                slave_addr_state <= idle;
                end  
                
        endcase
    end
end   
///////////////////////////////////////////////

////state machine to grant permission to the masters based on priority
always @(posedge clk or posedge rst)
begin
if (rst == 1'b1)
    begin
        arbiter_state <= IDLE_STATE ;
        m1_grant = 0;
        m2_grant = 0; 
        bus_grant = 2'b0;
        slave_sel = 2'b0;
	    arbiter_busy = 0;
		bus_busy = 0;
    end
else 
    begin
    case (arbiter_state)
    IDLE_STATE :begin      
            if (m1_request == 1'b1) //priority
            begin
                arbiter_state <= MASTER1_REQUEST_STATE ;	
				arbiter_busy = 1;
            end
            else if (m2_request == 1'b1 ) 
            begin
                arbiter_state <= MASTER2_REQUEST_STATE ;
                arbiter_busy = 1;
            end
            else
            begin
                arbiter_state <= IDLE_STATE ;
				arbiter_busy = 0;
				bus_busy = 0;

            end
        end
    MASTER1_REQUEST_STATE :begin
            if (slave_sel_done == 1'b1)        
            begin
                arbiter_state <= BUS_BUSY_STATE;
                bus_grant = 2'd1;
				m1_grant = 1;
				m2_grant = 0;
                slave_sel[0] = rx_m1_slave[0];
                slave_sel[1] = rx_m1_slave[1];
         	    arbiter_busy = 0;
				bus_busy = 1;
            end
            else
            begin
                arbiter_state <= MASTER1_REQUEST_STATE ;
            end
        end
    MASTER2_REQUEST_STATE :begin
            if (slave_sel_done == 1'b1)            
            begin
                arbiter_state <= BUS_BUSY_STATE;
                bus_grant = 2'd2;
                m2_grant = 1;
				m1_grant = 0;
                slave_sel[0] = rx_m2_slave[0];
                slave_sel[1] = rx_m2_slave[1];
         	    arbiter_busy = 0;
				bus_busy = 1;
            end
            else
            begin
                arbiter_state <= MASTER2_REQUEST_STATE ;
            end
        end
		  
    BUS_BUSY_STATE :begin
            if (trans_done == 1'b1)            
            begin
                arbiter_state <= IDLE_STATE;
				bus_busy = 0;
				m1_grant = 0;
                m2_grant = 0;
            end
			else
            begin
                arbiter_state <= BUS_BUSY_STATE ;
				bus_busy = 1;
            end
        end     

        default : begin
            arbiter_state <= IDLE_STATE ;
            m1_grant = 0;
            m2_grant = 0; 
            bus_grant = 2'b0;
            slave_sel = 2'b0;
			arbiter_busy = 0;
			bus_busy = 0;
        end
    endcase
    end
end

endmodule
