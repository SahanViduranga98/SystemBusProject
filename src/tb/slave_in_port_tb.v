`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2023 04:08:14 PM
// Design Name: 
// Module Name: slave_in_port_tb
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


module slave_in_port_tb();
    reg clk;
    reg reset=0;

    reg rx_data;
    reg rx_addr;
    
    reg  master_ready;
    reg  master_valid;
        
    reg  read_en;
    reg  write_en;
    reg [12:0] burst;
    wire [7:0] data_out;
    wire [11:0] addr_out;
    wire  read_enable;
    wire [11:0] burst_counter=12'd0;
    wire rx_done;
    wire slave_ready;
    
    parameter [11:0] sent_addr=12'b01010101010;
    parameter [7:0] sent_data=8'b01010101;
    parameter [12:0] sent_burst=13'b0;
    integer  dc=0;
    integer ac=0;

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

    parameter CLK_PERIOD=10;

    initial begin 
    clk=0;
    forever #(CLK_PERIOD/2) clk <= ~clk;
    end
    
    initial begin
    @(posedge clk);
        begin
            reset<=0;
            master_valid<=0;
            read_en<=0;
        end
    @(posedge clk);
        begin
            reset<=1;
        end
    @(posedge clk);
        begin
            reset<=0;
        end
    @(posedge clk);
        begin
            master_valid<=1;
            write_en<=1;
        end
    for(ac=0;ac<12;ac=ac+1)
        begin
            @(posedge clk);
                begin
                    if(ac<1)
                        begin
                              master_valid<=0;
                              write_en<=0;
                              burst<=sent_burst;
                        end
                    rx_addr<=sent_addr[ac];
                    if(ac<8)
                        begin
                            rx_data<=sent_data[ac];
                        end
                end
        end
    
   
   
    
    end
endmodule
