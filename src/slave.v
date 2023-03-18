`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2023 11:53:37 AM
// Design Name: 
// Module Name: slave
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


module slave(
	input clk, 
	input reset,

	//input [5:0]slave_delay,

	input read_en,
	input write_en,

	input master_ready,
	input master_valid,

	output slave_valid,
	output slave_ready,

	input rx_address,
	input rx_data,
	input rx_burst,

	// output slave_tx_done,
	// output rx_done,
	output tx_data/*,
	output split_en*/);
	
	
    wire [7:0]datain;
    wire [11:0]address;
    wire [7:0]data;
    wire read_en_in;
    wire write_en_in;
    wire reset_busy;
    
    slave_port SLAVE_PORT(
        .clk(clk), 
        .reset(reset),
        //.slave_delay(slave_delay),
        .read_en(read_en),
        .write_en(write_en),
        .master_ready(master_ready),
        .master_valid(master_valid),
        .slave_valid(slave_valid),
        .slave_ready(slave_ready),
        .rx_address(rx_address),
        .rx_data(rx_data),
        .rx_burst(rx_burst),
        // .slave_tx_done(slave_tx_done),
        // .rx_done(rx_done),
        .tx_data(tx_data),
        .datain(datain),
        .address(address),
        .data(data),
        .read_en_in(read_en_in),
        .write_en_in(write_en_in)/*,
        .split_en(split_en)*/);
        
        bram bram_wrapper(
        .BRAM_PORTA_0_addr(address),
        .BRAM_PORTA_0_clk(clk),
        .BRAM_PORTA_0_din(datain),
        .BRAM_PORTA_0_dout(data),
        .BRAM_PORTA_0_en(read_en_in),
        .BRAM_PORTA_0_rst(reset),
        .BRAM_PORTA_0_we(write_en_in),
        .rsta_busy_0(reset_busy));
        
endmodule 