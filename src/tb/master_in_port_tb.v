`timescale 1ns/10ps

module master_in_port_tb();
	parameter burst_len=12;
    parameter data_len=8;
	reg clk; 
	reg reset;

    reg tx_done;
    reg [1:0] instruction;
    reg [burst_len-1:0] burst_num;
    wire [data_len-1:0] data;
    wire rx_done;
    wire new_rx;

    reg rx_data;
    reg slave_valid;
    wire master_ready;
	
	
	
	master_in_port MASTER_IN(
		.clk(clk), 
		.reset(reset),
		.tx_done(tx_done),
        .instruction(instruction),
        .burst_num(burst_num),
        .data(data),
        .rx_done(rx_done),
        .new_rx(new_rx),
        .rx_data(rx_data),
        .slave_valid(slave_valid),
        .master_ready(master_ready));

    parameter CLK_PERIOD=10;
    initial begin 
    clk=0;
    forever #(CLK_PERIOD/2) clk <= ~clk;
    end

	

endmodule 