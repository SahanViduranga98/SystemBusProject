`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2023 09:46:02 AM
// Design Name: 
// Module Name: slave_out_port
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


module slave_out_port(
    input clk,
    input reset,
    
    input[7:0] data_in,
    input master_ready,
    input slave_valid,
    
    output reg slave_ready,
    output reg tx_data,
    output reg tx_done
    );
    
    reg CURRENT_STATE=0;
    reg [3:0] DATA_STATE=0;
    
    parameter 
    IDLE=0,
    TRANSMIT=1,
    DATA0=0,
    DATA1=1,
    DATA2=2,
    DATA3=3,
    DATA4=4,
    DATA5=5,
    DATA6=6,
    DATA7=7;
    
    
    always @(posedge clk or posedge reset)
    begin
        if(reset)
            begin
                CURRENT_STATE<=IDLE;
                DATA_STATE<=DATA0;
            end
        else
            begin
                case(CURRENT_STATE)
                    IDLE:
                        begin
                            if(master_ready && slave_valid)
                                begin
                                CURRENT_STATE<=TRANSMIT;
                                slave_ready<=0;
                                tx_done<=0;
                                end  
                            else
                                begin
                                slave_ready<=1;
                                tx_done<=1;
                                end   
                        end
                    TRANSMIT:
                        begin
                            case(DATA_STATE)
                                DATA0:
                                    begin
                                    tx_data<=data_in[0];
                                    DATA_STATE<=DATA1;
                                    end
                                DATA1:
                                    begin
                                    tx_data<=data_in[1];
                                    DATA_STATE<=DATA2;
                                    end
                                DATA2:
                                    begin
                                    tx_data<=data_in[2];
                                    DATA_STATE<=DATA3;
                                    end
                                DATA3:
                                    begin
                                    tx_data<=data_in[3];
                                    tx_done<=0;
                                    DATA_STATE<=DATA4;
                                    end
                                DATA4:
                                    begin
                                    tx_data<=data_in[4];
                                    DATA_STATE<=DATA5;
                                    end
                                DATA5:
                                    begin
                                    tx_data<=data_in[5];
                                    DATA_STATE<=DATA6;
                                    end
                                DATA6:
                                    begin
                                    tx_data<=data_in[6];
                                    DATA_STATE<=DATA7;
                                    end
                                DATA7:
                                    begin
                                    tx_data<=data_in[7];
                                    tx_done<=1;
                                    CURRENT_STATE<=IDLE;
                                    DATA_STATE<=DATA0;
                                    end
                                    
                            endcase
                        end
                    
                endcase
            end
    end
endmodule
