`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2023 05:02:45 PM
// Design Name: 
// Module Name: slave_in_port
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


module slave_in_port(
    input clk,
    input reset,
    
    input rx_data,
    input rx_addr,
    
    input master_ready,
    input master_valid,
    input [12:0] burst,
    input read_en,
    input write_en,
    
    output reg[7:0] data_out,
    output reg[11:0] addr_out,
    output reg read_enable,
    
    output reg rx_done,
    output reg slave_ready,
    output reg data_received  
    );
    reg [1:0] DATA_RECV_STATE=0;
    reg [1:0] ADDR_RECV_STATE=0;
    parameter
    DATA_IDLE                = 0,
    DATA_RECEIVE        = 1,
    DATA_BURST_GAP        = 2;
    
    reg DATA_STATE=0;
    always @(posedge clk)
    begin
        case(DATA_STATE)
            DATA_IDLE:
                begin
                 if(read_en && master_valid)
                    begin
                        DATA_STATE<=DATA_RECEIVE;
                        data_received<=0;
                        rx_done<=0;
                        slave_ready<=0;
                    end
                else
                    begin
                        data_received<=1;
                        rx_done<=1;
                        slave_ready<=1;
                    end
                end
            DATA_RECEIVE:
                begin
                    
                end
        endcase
    end
            
                
        
        
    
endmodule
