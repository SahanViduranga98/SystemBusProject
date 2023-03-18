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


module slave_in_port (
	input clk, 
	input reset,
	input rx_address,
	input rx_data,
	input master_valid,
	input read_en,
	input write_en,
	input slave_valid,
	input master_ready,
	input [12:0]burst,
	output slave_ready,
	output reg rx_done,
	output reg[11:0]address = 12'b0,
	output reg[7:0]data = 8'b0,
	output reg read_en_in1 = 0,
	output reg write_en_in1 = 0,
	output read_en_in,
	output write_en_in,
	output reg[11:0] burst_counter = 12'd0,
	output reg[3:0] addr_counter = 4'd0);
	

    reg [3:0]addr_state = 4'd13;
    reg [3:0]data_state = 4'd13;
    reg addr_idle = 1;
    reg data_idle = 1;
    // reg [3:0]addr_counter = 4'd0;
    reg [3:0]data_counter = 4'd0;
    
    wire handshake = master_valid & slave_ready;
    
    assign slave_ready = data_idle & addr_idle;
    assign read_en_in  = rx_done & read_en_in1;
    assign write_en_in = rx_done & write_en_in1;
    
    parameter 
    IDLE                = 13, 
    ADDR_RECIEVE        = 1,
    ADDR_INC_BURST      = 2, 
    DATA_RECIEVE 	    = 3,
    DATA_BURST_GAP      = 4,
    DATA_RECIEVE_BURST  = 5,
    ADDR_WAIT_HANDSHAKE = 6,
    READ_BURST_WAIT_HANDSHAKE = 7;

    
    
    // Statemachine to capture the 12 bit address
    always @ (posedge clk or posedge reset) 
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
                            address[addr_counter] <= rx_address;
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
                        address[addr_counter] <= rx_address;
                        addr_idle             <= 0;
                        rx_done               <= 0;
                    end
                    else 
                    begin
                        if ((burst[0] == 1) && handshake == 1)        addr_state <= ADDR_INC_BURST; 
                        else if ((burst[0] == 1) && handshake == 0)   addr_state <= ADDR_WAIT_HANDSHAKE; 
                        else                                                      addr_state <= IDLE;
                        addr_counter          <= 0;
                        address[addr_counter] <= rx_address;
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