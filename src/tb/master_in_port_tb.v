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

    initial begin
    $display($time ,"Starting time of simulation");

    reset<=0;
    #30
    reset<=1;

    #30                        //Normal Read operation
    reset<=0;
    instruction <= 2'b11;
    burst_num <= 11'd0;
    tx_done<= 1 ;

    //approval_grant <= 1 ;
    #30
    slave_valid<=1;
    rx_data<=0;
    #10
    rx_data<=1;
    #10
    rx_data<=1;
    #10
    rx_data<=0;
    #10
    rx_data<=1;
    #10
    rx_data<=0;
    #10
    rx_data<=1;
    #10
    rx_data<=1;
    
    #30
    reset <= 1;

    #30
    reset <= 0;
    instruction <= 2'b11;
    slave_valid<=0;

    #30                     //Burst Operation 
    instruction <= 2'b11;
    burst_num <= 11'd3;
    //

    #30
    slave_valid<=1;
    tx_done<= 1 ;
    //approval_grant <= 1 ;

    rx_data<=0;
    #10
    rx_data<=1;
    #10
    rx_data<=1;
    #10
    rx_data<=1;
    #10
    rx_data<=1;
    #10
    rx_data<=0;
    #10
    rx_data<=1;
    #10
    rx_data<=0;

    #10
    rx_data<=0;
    #10
    rx_data<=0;
    #10
    rx_data<=1;
    #10
    rx_data<=0;
    #10
    rx_data<=1;
    #10
    rx_data<=0;
    #10
    rx_data<=1;
    #10
    rx_data<=1;
    
    #10
    rx_data<=0;
    #10
    rx_data<=1;
    #10
    rx_data<=1;
    #10
    rx_data<=1;
    #10
    rx_data<=1;
    #10
    rx_data<=0;
    #10
    rx_data<=1;
    #10
    rx_data<=1;

    #30
    reset <= 1;

    $display($time ,"End time of simulation");
    $stop;
end

endmodule