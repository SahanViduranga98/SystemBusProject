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

	input read_en,
	input write_en,

	input master_ready,
	input master_valid,

	output slave_valid,
	output slave_ready,

	input rx_addr,
	input rx_data,
	input rx_burst,

	output tx_data);
	
	
    wire [7:0]data_in;
    wire [11:0]addr;
    wire [7:0]data_out;
    wire read_enable;
    wire write_enable;
    wire reset_busy;
    
    slave_port SLAVE_PORT(
        .clk(clk), 
        .reset(reset),
        
        .read_en(read_en),
        .write_en(write_en),
        
        .master_ready(master_ready),
        .master_valid(master_valid),
        
        .slave_valid(slave_valid),
        .slave_ready(slave_ready),
        
        .rx_addr(rx_addr),
        .rx_data(rx_data),
        .rx_burst(rx_burst),
        .tx_data(tx_data),
        
        .data_in(data_in),
        .addr_out(addr),
        .data_out(data_out),
        
        .read_enable(read_enable),
        .write_enable(write_enable));
        
        bram_wrapper bram(
        .BRAM_PORTA_0_addr(addr),
        .BRAM_PORTA_0_clk(clk),
        .BRAM_PORTA_0_din(data_out),
        .BRAM_PORTA_0_dout(data_in),
        .BRAM_PORTA_0_en(read_enable),
        .BRAM_PORTA_0_rst(reset),
        .BRAM_PORTA_0_we(write_enable),
        .rsta_busy_0(reset_busy));
        
endmodule 