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
        if (reset)
        begin
            addr_state   <= IDLE;
            addr_counter <= 4'd0;
            addr_idle    <= 1;
            read_en_in1     <= 0;
            write_en_in1 <= 0;
            burst_counter <= 0;
        end
        else
        begin
            case (addr_state)
                IDLE:
                begin
                    // if ((handshake == 1'd1) && (burst_counter < burst)) 
                    if ((handshake == 1'd1)) 
                        begin
                            addr_state            <= ADDR_RECIEVE;
                            addr_counter          <= addr_counter + 4'd1;
                            address[addr_counter] <= rx_addr;
                            addr_idle             <= 0;
                            rx_done               <= 0;
                            read_en_in1               <= read_en;
                            write_en_in1           <= write_en;
                            burst_counter <= 0;
                        end
                    else
                        begin
                            addr_state    <= IDLE;
                            addr_counter  <= 4'd0;
                            addr_idle     <= 1;
                            rx_done       <= 0;
                            read_en_in1      <= 0;
                            write_en_in1  <= 0;
                            burst_counter <= burst_counter;
                        end
                end
                ADDR_RECIEVE:
                begin
                    if (addr_counter < 4'd11)
                    begin
                        addr_state            <= addr_state;
                        addr_counter          <= addr_counter + 4'd1;
                        address[addr_counter] <= rx_addr;
                        addr_idle             <= 0;
                        rx_done               <= 0;
                    end
                    else 
                    begin
                        if ((burst[0] == 1) && handshake == 1)        addr_state <= ADDR_INC_BURST; 
                        else if ((burst[0] == 1) && handshake == 0)   addr_state <= ADDR_WAIT_HANDSHAKE; 
                        else                                                      addr_state <= IDLE;
                        addr_counter          <= 0;
                        address[addr_counter] <= rx_addr;
                        addr_idle             <= 1;
                        rx_done               <= 1;
                        burst_counter           <= burst_counter + 1;
                    end
                end
                ADDR_WAIT_HANDSHAKE:
                begin
                    if (handshake == 1)  //edited
                    begin
                        addr_state <= ADDR_INC_BURST;
                        addr_counter <= addr_counter + 1;
                        rx_done <= 0;
                    end
                    else if ((rx_done == 1) && (read_en_in1 == 1))
                    begin
                        addr_state <= READ_BURST_WAIT_HANDSHAKE;
                        addr_counter <= addr_counter + 1;
                        rx_done <= 0;                    
                    end
                    else 
                    begin
                        addr_state <= ADDR_WAIT_HANDSHAKE;
                        rx_done <= 0;
                    end
                end
                READ_BURST_WAIT_HANDSHAKE:
                begin
                    if (addr_counter == 2 && master_ready == 0 && (burst_counter % 8 == 0))
                    begin
                        addr_counter <= addr_counter;
                        addr_state <= addr_state;
                    end
                    else 
                    begin
                        if (addr_counter == 1) addr_state <= addr_state;
                        else addr_state <= ADDR_INC_BURST;
                        addr_counter <= addr_counter + 4'd1;
                        addr_idle <= 1;
                        rx_done <= 0;            
                    end
                end
                ADDR_INC_BURST:
                begin
                    if ((addr_counter < 4'd7))
                    begin
                        addr_state <= addr_state;
                        addr_counter <= addr_counter + 4'd1;
                        addr_idle <= 1;
                        rx_done <= 0;            
                    end
                    else 
                    begin
                        if (burst_counter < burst[12:1])  
                        begin
                            addr_state <= ADDR_WAIT_HANDSHAKE;
                            addr_counter <= 0;
                            addr_idle <= 1;
                            burst_counter <= burst_counter + 1;
                            address <= address + 1;
                            rx_done <= 1;
                        end
                        else             
                        begin           
                            addr_state <= IDLE;
                            addr_counter <= 0;
                            addr_idle <= 1;
                            burst_counter <= burst_counter + 1;
                            address <= address + 1;
                            rx_done <= 1;
                        end
                    end
                end
                default:
                begin
                    addr_state   <= IDLE;
                    addr_counter <= 4'd0;
                    addr_idle    <= 1;
                end
            endcase
        end 
    end
    
    // Statemachine to capture the 8 bit data
    always @ (posedge clk or posedge reset) 
    begin
        if (reset)
        begin
            data_state <= IDLE;
            data_counter <= 0;
            data_idle <= 1;
        end
        else
        begin
            case (data_state)
                IDLE:
                begin
                    if (handshake == 1'd1 && (write_en || write_en_in1))
                        begin
                            data_state         <= DATA_RECIEVE;
                            data_counter       <= data_counter + 4'd1;
                            data[data_counter] <= rx_data;
                            data_idle          <= 0;
                        end
                    else
                        begin
                            data_state    <= data_state;
                            data_counter  <= 0;
                            data_idle     <= 1;
                        end
                end
                DATA_RECIEVE:
                begin
                    if (data_counter < 4'd7 && write_en_in1 == 1)
                    begin
                        data_state         <= data_state;
                        data_counter       <= data_counter + 4'd1;
                        data[data_counter] <= rx_data;
                        data_idle <= 0;
                    end
                    else 
                    begin
                        if (burst_counter == 0 && write_en_in1 == 1) data_state <= DATA_BURST_GAP;
                        else         
                        begin
                            data_state <= IDLE;
                            data_idle <= 1;
                        end            
                        data_counter <= 0;
                        data[data_counter] <= rx_data;
                    end
                end
                DATA_BURST_GAP:
                begin
                    if (data_counter < 3)
                    begin
                        data_state <= DATA_BURST_GAP;
                        data_counter <= data_counter + 1;    
                        data_idle <= 0;
                    end
                    else
                    begin
                        data_state <= IDLE;
                        data_counter <= 0;
                        data_idle <= 1; 
                    end
                end
                default:
                begin
                    data_state <= IDLE;
                end
            endcase
        end
    end
    
    
    
    endmodule