`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2023 11:53:37 AM
// Design Name: 
// Module Name: slave_port
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


module slave_port(
    input clk,
    input reset,

    input read_en,
    input write_en,

    input master_ready,
    input master_valid,

    output reg slave_valid,
    output slave_ready,

    input rx_data,
    input rx_addr,

    output tx_data,

    input [7:0] bram_data_in,
    output [7:0] bram_data_out,
    output [11:0] bram_addr,

    output bram_read_en,
    output bram_write_en);

    wire slave_ready_in;
    wire slave_ready_out;

    wire rx_done;
    wire slave_tx_done;

    reg [3:0] reg_counter=0;
    reg read_en_reg=0;
    reg write_en_reg=0;

    assign slave_ready = slave_ready_in & slave_ready_out;
    assign bram_read_en = rx_done & read_en;
    assign bram_write_en = rx_done & write_en;

    slave_out_port SLAVE_OUT(
        .clk(clk),
        .reset(reset),
        .data_in(bram_data_in),
        .master_ready(master_ready),
        .slave_valid(slave_valid),
        .slave_ready(slave_ready),
        .tx_data(tx_data),
        .tx_done(slave_tx_done)
    );

    slave_in_port SLAVE_IN(
        .clk(clk),
        .reset(reset),
        .rx_data(rx_data),
        .rx_addr(rx_addr),
        .master_ready(master_ready),
        .master_valid(master_valid),
        .burst(burst),
        .read_en(read_en),
        .write_en(write_en),
        .data_out(data_out),
        .addr_out(addr_out),
        .read_enable(read_enable),
        .burst_counter(burst_counter),
        .rx_done(rx_done),
        .slave_ready(slave_ready)
    );


endmodule
