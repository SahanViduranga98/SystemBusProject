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
    
    output reg[11:0] burst_counter,
    output rx_done,
    output slave_ready);

    reg [1:0] DATA_RECV_STATE=0;
    reg [2:0] ADDR_RECV_STATE=0;
    reg [2:0] DATA_STATE=0;
    reg [3:0] ADDR_DATA_STATE=0;
    reg [1:0] DATA_ADDR_WAIT_STATE=0;
    reg ADDR_READ_BURST_WAIT_STATE=0;
    wire hand_shake = master_valid & slave_ready;

    reg rx_done_reg;
    assign rx_done=rx_done_reg;

    reg slave_ready_reg;
    assign slave_ready=slave_ready_reg;

    reg addr_idle_reg=1;
    reg [3:0] delay_counter=0;

    parameter
    DATA_IDLE = 0,
    DATA_RECEIVE = 1,
    DATA_ADDR_WAIT = 2,

    ADDR_IDLE=0,
    ADDR_RECEIVE=1,
    ADDR_BURST_CHECK=2,
    ADDR_WAIT_HANDSHAKE=3,
    ADDR_INC_BURST=4,
    ADDR_INTERRUPT=5,
    ADDR_READ_BURST_HANDSHAKE=6,
    
    ADDR_DATA0=0,
    ADDR_DATA1=1,
    ADDR_DATA2=2,
    ADDR_DATA3=3,
    ADDR_DATA4=4,
    ADDR_DATA5=5,
    ADDR_DATA6=6,
    ADDR_DATA7=7,
    ADDR_DATA8=8,
    ADDR_DATA9=9,
    ADDR_DATA10=10,
    ADDR_DATA11=11,


    DATA0=0,
    DATA1=1,
    DATA2=2,
    DATA3=3,
    DATA4=4,
    DATA5=5,
    DATA6=6,
    DATA7=7,
    
    DATA_ADDR_WAIT0=0,
    DATA_ADDR_WAIT1=1,
    DATA_ADDR_WAIT2=2,
    
    ADDR_READ_BURST_WAIT0=0,
    ADDR_READ_BURST_WAIT1=1;
    
    
    always @(posedge clk or posedge reset)
    begin
        if(reset)
            begin
                DATA_RECV_STATE<=DATA_IDLE;
                DATA_STATE<=DATA0;

                ADDR_RECV_STATE <= ADDR_IDLE;
                ADDR_DATA_STATE<=ADDR_DATA0;

                slave_ready_reg<=0;
                addr_idle_reg<=1;

            end
        else
            begin
                case(DATA_RECV_STATE)
                    DATA_IDLE:
                        begin
                        if(hand_shake && write_en)
                            begin
                                DATA_RECV_STATE<=DATA_RECEIVE;
                                
                            end
                        else
                            begin
                                DATA_RECV_STATE<=DATA_IDLE;
                            end
                        end
                    DATA_RECEIVE:
 
                            begin
                                case(DATA_STATE)
                                    DATA0:
                                        begin
                                        data_out[0]<=rx_data;
                                        DATA_STATE<=DATA1;
                                        end
                                    DATA1:
                                        begin
                                        data_out[1]<=rx_data;
                                        DATA_STATE<=DATA2;
                                        end
                                    DATA2:
                                        begin
                                        data_out[2]<=rx_data;
                                        DATA_STATE<=DATA3;
                                        end
                                    DATA3:
                                        begin
                                        data_out[3]<=rx_data;
                                        DATA_STATE<=DATA4;
                                        end
                                    DATA4:
                                        begin
                                        data_out[4]<=rx_data;
                                        DATA_STATE<=DATA5;
                                        end
                                    DATA5:
                                        begin
                                        data_out[5]<=rx_data;
                                        DATA_STATE<=DATA6;
                                        end
                                    DATA6:
                                        begin
                                        data_out[6]<=rx_data;
                                        DATA_STATE<=DATA7;
                                        end
                                    DATA7:
                                        begin
                                            data_out[7]<=rx_data;
                                            DATA_STATE<=DATA0;
                                            if(burst[0]==0)
                                                begin
                                                    DATA_STATE<=DATA0;
                                                    DATA_RECV_STATE<=DATA_IDLE;
                                                end
                                            else
                                                begin
                                                    if(burst_counter==0)
                                                        DATA_RECV_STATE<=DATA_ADDR_WAIT;
                                                    else
                                                        begin
                                                            DATA_RECV_STATE<=DATA_IDLE;
                                                           
                                                        end
                                                end

                                        
                                        end
                                endcase
                            end        
                        
                    DATA_ADDR_WAIT:
                        begin
                            case(DATA_ADDR_WAIT_STATE)
                                DATA_ADDR_WAIT0:
                                    DATA_ADDR_WAIT_STATE<=DATA_ADDR_WAIT1;
                                DATA_ADDR_WAIT1:
                                    DATA_ADDR_WAIT_STATE<=DATA_ADDR_WAIT2;
                                DATA_ADDR_WAIT2:
                                    begin
                                        DATA_ADDR_WAIT_STATE<=DATA_ADDR_WAIT0;
                                        DATA_RECV_STATE<=DATA_IDLE;
                                        DATA_STATE<=DATA0;
                                    end
                            endcase

                        end
                
                endcase

                case(ADDR_RECV_STATE)
                    ADDR_IDLE:
                        begin
                        if(hand_shake)//HANDSHAKE
                            begin
                                ADDR_RECV_STATE<=ADDR_RECEIVE;
                                rx_done_reg <= 0;
                                burst_counter<=12'd0;
                                addr_idle_reg<=0;
                            end
                        else
                            begin
                                ADDR_RECV_STATE<=ADDR_IDLE;
                                burst_counter<=burst_counter;
                                addr_idle_reg<=1;
                            end
                        end

                    ADDR_RECEIVE:
                        begin
                            case(ADDR_DATA_STATE)
                                ADDR_DATA0:
                                    begin
                                    addr_out[0]<=rx_addr;
                                    ADDR_DATA_STATE<=ADDR_DATA1;
                                    end
                                ADDR_DATA1:
                                     begin
                                    addr_out[1]<=rx_addr;
                                    ADDR_DATA_STATE<=ADDR_DATA2;
                                    end
                                ADDR_DATA2:
                                    begin
                                    addr_out[2]<=rx_addr;
                                    ADDR_DATA_STATE<=ADDR_DATA3;
                                    end
                                ADDR_DATA3:
                                    begin
                                    addr_out[3]<=rx_addr;
                                    ADDR_DATA_STATE<=ADDR_DATA4;
                                    end
                                ADDR_DATA4:
                                    begin
                                    addr_out[4]<=rx_addr;
                                    ADDR_DATA_STATE<=ADDR_DATA5;
                                    end
                                ADDR_DATA5:
                                    begin
                                    addr_out[5]<=rx_addr;
                                    ADDR_DATA_STATE<=ADDR_DATA6;
                                    end
                                ADDR_DATA6:
                                    begin
                                    addr_out[6]<=rx_addr;
                                    ADDR_DATA_STATE<=ADDR_DATA7;
                                    end
                                ADDR_DATA7:
                                    begin
                                    addr_out[7]<=rx_addr;
                                    ADDR_DATA_STATE<=ADDR_DATA8;
                                    end
                                ADDR_DATA8:
                                    begin
                                    addr_out[8]<=rx_addr;
                                    ADDR_DATA_STATE<=ADDR_DATA9;
                                    end
                                ADDR_DATA9:
                                    begin
                                    addr_out[9]<=rx_addr;
                                    ADDR_DATA_STATE<=ADDR_DATA10;
                                    end
                                ADDR_DATA10:
                                    begin
                                    addr_out[10]<=rx_addr;
                                    ADDR_DATA_STATE<=ADDR_DATA11;
                                    end
                                ADDR_DATA11:
                                    begin
                                    addr_out[11]<=rx_addr;
                                    ADDR_RECV_STATE<=ADDR_BURST_CHECK;
                                    ADDR_DATA_STATE<=ADDR_DATA0;
                                    rx_done_reg<=1;
                                    end
                            endcase
                        end
                    ADDR_BURST_CHECK:
                        begin
                        if(burst[0] && hand_shake )
                            ADDR_RECV_STATE<=ADDR_INC_BURST; 
                        else if(burst[0] && ~hand_shake)
                            begin
                                ADDR_RECV_STATE<=ADDR_WAIT_HANDSHAKE;
                                addr_idle_reg<=1;
                            end
                        else
                            begin
                                ADDR_RECV_STATE<=ADDR_IDLE;
                                
                            end
                       
                        end
                    ADDR_WAIT_HANDSHAKE:
                        begin
                            if(hand_shake)
                                begin
                                    ADDR_RECV_STATE<=ADDR_INC_BURST;
                                    addr_idle_reg<=1;
                                    rx_done_reg<=0;
                                end
                            else if(rx_done_reg==1 && read_en==1)
                                begin
                                    ADDR_RECV_STATE<=ADDR_READ_BURST_HANDSHAKE;
                                    rx_done_reg<=0;
                                end
                            else
                                begin
                                    ADDR_RECV_STATE<=ADDR_WAIT_HANDSHAKE;
                                    rx_done_reg<=0;
                                end
                        end
                    ADDR_READ_BURST_HANDSHAKE:
                        begin
                            if(ADDR_READ_BURST_WAIT_STATE==ADDR_READ_BURST_WAIT1 && master_ready==0 && (burst_counter%8==0))
                                begin
                                    ADDR_RECV_STATE<=ADDR_RECV_STATE;
                                end
                            else
                                begin
                                    case(ADDR_READ_BURST_WAIT_STATE)
                                        ADDR_READ_BURST_WAIT0:
                                            begin
                                                ADDR_RECV_STATE<=ADDR_RECV_STATE;
                                                ADDR_READ_BURST_WAIT_STATE<=ADDR_READ_BURST_WAIT1;
                                            end
                                        ADDR_READ_BURST_WAIT1:
                                            begin
                                                ADDR_RECV_STATE<=ADDR_INC_BURST;
                                                ADDR_READ_BURST_WAIT_STATE<=ADDR_READ_BURST_WAIT0;
                                            end
                                    endcase
                                    addr_idle_reg<=1;
                                    rx_done_reg<=0;
                                end
                        end
                    ADDR_INC_BURST://4
                        begin
                            if(delay_counter<4'd7)
                                begin
                                    ADDR_RECV_STATE<=ADDR_RECV_STATE;
                                    delay_counter<=delay_counter+4'd1;
                                    addr_idle_reg<=1;
                                    rx_done_reg<=0;
                                end
                            else
                                begin
                                    if(burst_counter<burst[12:1])
                                        begin
                                            delay_counter<=0;
                                            addr_idle_reg<=1;
                                            rx_done_reg<=1;
                                            addr_out<=addr_out+12'b1;
                                            burst_counter<=burst_counter+12'd1;
                                        end
                                    else
                                        begin
                                            delay_counter<=0;
                                            addr_idle_reg<=1;
                                            rx_done_reg<=1;
                                            addr_out<=addr_out+12'b1;
                                            burst_counter<=burst_counter+12'd1;
                                            ADDR_RECV_STATE<=ADDR_IDLE;
                                        end

                                end
                                
                        end   
                    ADDR_INTERRUPT:
                        begin
                        end  
                endcase

                if(DATA_RECV_STATE==DATA_IDLE && addr_idle_reg==1)
                    slave_ready_reg<=1;
                else
                    slave_ready_reg<=0;
                    
            end

        
    end
            

endmodule