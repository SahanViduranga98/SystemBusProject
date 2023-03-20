`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2023 05:25:12 PM
// Design Name: 
// Module Name: master_out_port_tb
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
`timescale 1ns / 1ps
module master_out_port_tb();

    parameter CLOCK_PERIOD  = 4'b1010;

    reg clk, reset, approval_grant, bus_busy, slave_ready, rx_done,arbitor_busy ;
    reg [11:0]address;                
    reg [7:0]data;                   
    reg [11:0]burst_num;             
    reg [1:0]slave_select;          
    reg [1:0]instruction;                     

    wire approval_request ;
    wire tx_slave_select ;
    wire master_ready ;
    wire master_valid ;
    wire tx_address ;
    wire tx_data ;
    wire tx_burst_num ;
    wire tx_done ;
    wire write_en ;
    wire read_en ;  
    
    master_out_port MasterOut(
            .clk(clk),
            .reset(reset),
            .arbitor_busy(arbitor_busy),
            .address(address),
            .data(data),
            .burst_num(burst_num),
            .slave_select(slave_select),
            .approval_grant(approval_grant),
            .bus_busy(bus_busy),
            .slave_ready(slave_ready),
            .rx_done(rx_done),
    
            .approval_request(approval_request) ,
            .tx_slave_select(tx_slave_select) ,
            .master_ready(master_ready) ,
            .master_valid(master_valid) ,
            .tx_address(tx_address) ,
            .tx_data(tx_data) ,
            .tx_burst_num(tx_burst_num) ,
            .tx_done(tx_done) ,
            .write_en(write_en) ,
            .read_en(read_en) 
        );
    
    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2);
            clk <= ~clk;
        end
    end
    initial begin
        $display($time ,"Starting time of simulation");
    
    reset<=0;
    #(CLOCK_PERIOD*3);
    reset<=1;
    #(CLOCK_PERIOD*3);
    reset<=0;
    
        #(CLOCK_PERIOD*3);                     //Read Operation
        instruction <= 2'b11;
        slave_select <= 2'b11;
        address <= 12'd5459;
        burst_num <= 12'd03;
    
        #(CLOCK_PERIOD*3);
        bus_busy<=1;
    
        #(CLOCK_PERIOD*3);
        bus_busy<=0;
        arbitor_busy<=0;
        approval_grant<=1;
    
      #(CLOCK_PERIOD*3);
        slave_ready<=1;
       #(CLOCK_PERIOD*10);
        rx_done<=1;
    
       #(CLOCK_PERIOD*3);
        reset<=1;
    
        #(CLOCK_PERIOD*10)
        instruction <= 2'b00;
        slave_select <= 2'b00;
        address <= 11'b00;
        burst_num <= 11'd00;
        approval_grant<=0;
        slave_ready<=0;
    
    
        #CLOCK_PERIOD     //Write Operation
        reset<=0;
    
        #CLOCK_PERIOD
        instruction <= 2'b10 ;
        slave_select <= 2'b10 ;
        address <= 12'd5459 ;
        burst_num <= 12'd00 ;
        data <= 8'd09 ;
        approval_grant <= 1 ;
        bus_busy <= 0 ;
        rx_done <= 0 ;
        
        #(CLOCK_PERIOD*10)
       
        slave_ready <= 1;
        bus_busy <= 0;
       
        #(CLOCK_PERIOD*20)
        reset<=1;
       
       //    #30
       //    instruction <= 2'b00;
       //    slave_select <= 2'b00;
       //    address <= 11'b00;
       //    burst_num <= 11'd00;
       //    approval_grant<=0;
       //    slave_ready<=0;
end
endmodule

