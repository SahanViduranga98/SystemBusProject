`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2023 10:51:20 AM
// Design Name: 
// Module Name: slave_out_port_tb
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

`timescale 1ns/10ps
module slave_out_port_tb();
    reg clk;
    reg reset=0;
    
    reg [7:0] data_in;
    reg master_ready=0;
    reg slave_valid=0;
    
    
    wire slave_ready;
    wire tx_done;
    wire tx_data;
    
    
    
    slave_out_port SLAVE_OUT(
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .master_ready(master_ready),
        .slave_valid(slave_valid),
        .slave_ready(slave_ready),
        .tx_data(tx_data),
        .tx_done(tx_done)
    );
    parameter CLK_PERIOD=10;
    initial begin 
    clk=0;
    forever #(CLK_PERIOD/2) clk <= ~clk;
    end
    
    initial begin
    @(posedge clk);//
    reset<=0;
    @(posedge clk);
        begin
        reset<=1;
        #(CLK_PERIOD*3);
        end
   
    @(posedge clk);
        begin
        master_ready<=0;
        reset<=0;
        #(CLK_PERIOD*3);
        end
    
    @(posedge clk);//writing data to 12'd2 address
        begin
        slave_valid<=1;
        data_in<=8'b10101010;
        end
    @(posedge clk);//removing write enable signal
        begin
        #(CLK_PERIOD*2);
//        slave_valid<=0;
        end
    
    @(posedge clk);//removing other signals related to writing
        master_ready<=1;
    
     @(posedge clk);//removing write enable signal
       begin
       #(CLK_PERIOD*3);
       slave_valid<=0;
       end
    
//    @(posedge clk);//removing other signals related to writing
//    #(CLK_PERIOD*4);
//    addr<=12'd2;
    
//    @(posedge clk);//removing write enable signal
//    #(CLK_PERIOD*1);
//    r_en<=1'b1;
//    #(CLK_PERIOD*4);
//    r_en<=1'b0;
    
    end
endmodule
