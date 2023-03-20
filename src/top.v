`define TESTBENCH

module top(
	input clock,	
	input rst,
	input enable,
	input button1_raw,
	input button2_raw,
	input button3_raw,
	input [11:0]switch_array,
	input mode_switch,
	input rw_switch1,
	input rw_switch2,
	output scaled_clk,
	output m1_busy,
	output m2_busy,
	output [6:0]display1_pin,
	output [6:0]display2_pin,
	output [6:0]display3_pin,
	output [6:0]display4_pin,
	output [6:0]display5_pin,
	output [6:0]display6_pin,
	output [6:0]display7_pin,
	output [6:0]display8_pin
	
	`ifndef TESTBENCH
		
		,
		output LCD_ON,	// LCD Power ON/OFF
		output LCD_BLON,	// LCD Back Light ON/OFF
		output LCD_RW,	// LCD Read/Write Select, 0 = Write, 1 = Read
		output LCD_EN,	// LCD Enable
		output LCD_RS,	// LCD Command/Data Select, 0 = Command, 1 = Data
		inout [7:0] LCD_DATA	// LCD Data bus 8 bits
	
	`endif
	);

parameter SLAVE_LEN=2; 
parameter ADDR_LEN=12; 
parameter DATA_LEN=8;
parameter BURST_LEN=12;	

/***********************************************************/
//Change when switching between FPGA and testbench

`ifdef TESTBENCH

//Testbench
parameter MAX_COUNT_CLK=4;	//Fast enough to reduce testbench time

`else

//FPGA
parameter MAX_COUNT_CLK=5000000;	//Clock slow enough to see values getting updated

`endif

/***********************************************************/
	
// Wires in interconnect
wire m1_request; 
wire m2_request;
wire m1_slave_sel;
wire m2_slave_sel;
wire m1_grant;
wire m2_grant;
wire arbiter_busy;
wire m1_master_valid;
wire m1_tx_address;
wire m1_tx_data;
wire m1_tx_burst_num;
wire m1_rx_data;
wire m1_write_en;
wire m1_read_en;
wire m1_slave_ready;
wire m2_master_valid;
wire m2_tx_address;
wire m2_tx_data;
wire m2_tx_burst_num;
wire m2_rx_data;
wire m2_write_en;
wire m2_read_en;
wire m2_slave_ready;
wire s1_clk;
wire s1_rst;
wire s1_master_valid;
wire s1_rx_address;
wire s1_rx_data;
wire s1_tx_data;
wire s1_write_en;
wire s1_read_en;
wire s1_slave_ready;
wire s2_clk;
wire s2_rst;
wire s2_master_valid;
wire s2_rx_address;
wire s2_rx_data;
wire s2_tx_data;
wire s2_write_en;
wire s2_read_en;
wire s2_slave_ready;
wire s3_clk;
wire s3_rst;
wire s3_master_valid;
wire s3_rx_address;
wire s3_rx_data;
wire s3_tx_data;
wire s3_write_en;
wire s3_read_en;
wire s3_slave_ready;

wire s1_rx_burst_num;
wire s2_rx_burst_num;
wire s3_rx_burst_num;

// // slave
// wire slave_tx_done;
// wire rx_done;

// master
wire bus_busy;
wire m1_trans_done;
wire m2_trans_done;
wire trans_done = m1_trans_done || m2_trans_done;

//new master to slave connections
wire m1_master_ready;
wire m2_master_ready;
wire s1_master_ready;
wire s2_master_ready;
wire s3_master_ready;

wire m1_slave_valid;
wire m2_slave_valid;
wire s1_slave_valid;
wire s2_slave_valid;
wire s3_slave_valid;


//assign bus_busy=0;

// command processor to master
wire read1;
wire write1;
wire [DATA_LEN-1:0]data1;
wire [ADDR_LEN:0]address1;
wire [SLAVE_LEN-1:0]slave1;
wire [BURST_LEN:0]burst_num1;
wire read2;
wire write2;
wire [DATA_LEN-1:0]data2;
wire [ADDR_LEN:0]address2;
wire [SLAVE_LEN-1:0]slave2;
wire [BURST_LEN:0]burst_num2;
wire [3:0]config_state;//to LCD display

// output port conversions
wire reset, button1, button2, button3, clk;
assign reset = ~rst;
assign scaled_clk = clk;
assign button1 = ~button1_raw;
assign button2 = ~button2_raw;
assign button3 = ~button3_raw;

scaledclock #(.maxcount(MAX_COUNT_CLK)) CLK_DIV(.inclk(clock), .ena(enable), .clk(clk));
	
//command_processor #(.SLAVE_LEN(SLAVE_LEN), .ADDR_LEN(ADDR_LEN), .DATA_LEN(DATA_LEN), .BURST_LEN(BURST_LEN)) COMMAND(
//	.clk(clk), 
//	.reset(reset),
//	.button1(button1),
//	.button2(button2),
//	.button3(button3),
//	.switch_array(switch_array),
//	.mode_switch(mode_switch),
//	.rw_switch1(rw_switch1),
//	.rw_switch2(rw_switch2),
//	.display1_pin(display1_pin),
//	.display2_pin(display2_pin),
//	.display3_pin(display3_pin),
//	.display4_pin(display4_pin),
//	.display_val4(config_state),

//	.read1(read1),
//	.write1(write1),
//	.data1(data1),
//	.address1(address1),
//	.slave1(slave1),
//	.burst_num1(burst_num1),
//	.read2(read2),
//	.write2(write2),
//	.data2(data2),
//	.address2(address2),
//	.slave2(slave2),
//	.burst_num2(burst_num2));

master #(.SLAVE_LEN(SLAVE_LEN), .ADDR_LEN(ADDR_LEN), .DATA_LEN(DATA_LEN), .BURST_LEN(BURST_LEN)) MASTER1(
	.clk(clk), 
	.reset(reset),
	.busy(m1_busy),
	
	.read(read1),
	.write(write1),
	.data_load(data1),
	.address_load(address1),
	.slave_select_load(slave1),
	.burst_num_load(burst_num1),
	
	.arbitor_busy(arbiter_busy),
	.bus_busy(bus_busy),  //include in bus  ----> INCLUDED
	.approval_grant(m1_grant),
	.approval_request(m1_request),
	.tx_slave_select(m1_slave_sel),
	.trans_done(m1_trans_done), //include in bus  ----> INCLUDED
	
	.rx_data(m1_rx_data),
	.tx_address(m1_tx_address),
	.tx_data(m1_tx_data),
	.tx_burst_num(m1_tx_burst_num),
	
	.slave_valid(m1_slave_valid), //need port ----> INCLUDED
	.slave_ready(m1_slave_ready),
	.master_valid(m1_master_valid),
	.master_ready(m1_master_ready), //nead port ----> INCLUDED
	.write_en(m1_write_en),
	.read_en(m1_read_en));

master #(.SLAVE_LEN(SLAVE_LEN), .ADDR_LEN(ADDR_LEN), .DATA_LEN(DATA_LEN), .BURST_LEN(BURST_LEN)) MASTER2(
	.clk(clk), 
	.reset(reset),
	.busy(m2_busy),
	
	.read(read2),
	.write(write2),
	.data_load(data2),
	.address_load(address2),
	.slave_select_load(slave2),
	.burst_num_load(burst_num2),
	
	.arbitor_busy(arbiter_busy),
	.bus_busy(bus_busy),  //include in bus  ----> INCLUDED
	.approval_grant(m2_grant),
	.approval_request(m2_request),
	.tx_slave_select(m2_slave_sel),
	.trans_done(m2_trans_done), //include in bus  ----> INCLUDED
	
	.rx_data(m2_rx_data),
	.tx_address(m2_tx_address),
	.tx_data(m2_tx_data),
	.tx_burst_num(m2_tx_burst_num),
	
	.slave_valid(m2_slave_valid), //need port ----> INCLUDED
	.slave_ready(m2_slave_ready),
	.master_valid(m2_master_valid),
	.master_ready(m2_master_ready), //nead port ----> INCLUDED
	.write_en(m2_write_en),
	.read_en(m2_read_en));
	
Bus_interconnect BUS(
	.sys_clk(clk),
	.sys_rst(reset),
	.m1_request(m1_request), 
	.m2_request(m2_request),
	.m1_slave_sel(m1_slave_sel),
	.m2_slave_sel(m2_slave_sel),
	.trans_done(trans_done),
	
	.m1_grant(m1_grant),
	.m2_grant(m2_grant),
	.arbiter_busy(arbiter_busy),
	.bus_busy(bus_busy),
	
	.m1_clk(clk), 
	.m1_rst(reset),
	.m1_master_valid(m1_master_valid),
	.m1_master_ready(m1_master_ready),
	.m1_tx_address(m1_tx_address),
	.m1_tx_data(m1_tx_data),
	.m1_rx_data(m1_rx_data),
	.m1_write_en(m1_write_en),
	.m1_read_en(m1_read_en),
	.m1_slave_valid(m1_slave_valid),
	.m1_slave_ready(m1_slave_ready),
	
	.m2_clk(clk), 
	.m2_rst(reset),
	.m2_master_valid(m2_master_valid),
	.m2_master_ready(m2_master_ready),
	.m2_tx_address(m2_tx_address),
	.m2_tx_data(m2_tx_data),
	.m2_rx_data(m2_rx_data),
	.m2_write_en(m2_write_en),
	.m2_read_en(m2_read_en),
	.m2_slave_valid(m2_slave_valid),
	.m2_slave_ready(m2_slave_ready),
	
	.s1_clk(s1_clk), 
	.s1_rst(s1_rst),
	.s1_master_valid(s1_master_valid),
	.s1_master_ready(s1_master_ready),
	.s1_rx_address(s1_rx_address),
	.s1_rx_data(s1_rx_data),
	.s1_tx_data(s1_tx_data),
	.s1_write_en(s1_write_en),
	.s1_read_en(s1_read_en),
	.s1_slave_valid(s1_slave_valid),
	.s1_slave_ready(s1_slave_ready),
	
	.s2_clk(s2_clk), 
	.s2_rst(s2_rst),
	.s2_master_valid(s2_master_valid),
	.s2_master_ready(s2_master_ready),
	.s2_rx_address(s2_rx_address),
	.s2_rx_data(s2_rx_data),
	.s2_tx_data(s2_tx_data),
	.s2_write_en(s2_write_en),
	.s2_read_en(s2_read_en),
	.s2_slave_valid(s2_slave_valid),
	.s2_slave_ready(s2_slave_ready),
	
	.s3_clk(s3_clk), 
	.s3_rst(s3_rst),
	.s3_master_valid(s3_master_valid),
	.s3_master_ready(s3_master_ready),
	.s3_rx_address(s3_rx_address),
	.s3_rx_data(s3_rx_data),
	.s3_tx_data(s3_tx_data),
	.s3_write_en(s3_write_en),
	.s3_read_en(s3_read_en),
	.s3_slave_valid(s3_slave_valid),
	.s3_slave_ready(s3_slave_ready),
	

	.m1_tx_burst_num(m1_tx_burst_num),
	.m2_tx_burst_num(m2_tx_burst_num),

	.s1_rx_burst_num(s1_rx_burst_num),
	.s2_rx_burst_num(s2_rx_burst_num),
	.s3_rx_burst_num(s3_rx_burst_num));

slave SLAVE_1(
	.clk(clk), 
	.reset(reset),

	//.slave_delay(6'd0),

	.read_en(s1_read_en),
	.write_en(s1_write_en),

	.master_ready(s1_master_ready),//need port ----> INCLUDED
	.master_valid(s1_master_valid),

	.slave_valid(s1_slave_valid),//need port -----> INCLUDED
	.slave_ready(s1_slave_ready),

	.rx_addr(s1_rx_address),
	.rx_data(s1_rx_data),
	.rx_burst(s1_rx_burst_num),
	.tx_data(s1_tx_data));

slave SLAVE_2(
	.clk(clk), 
	.reset(reset),

	//.slave_delay(6'd0),	

	.read_en(s2_read_en),
	.write_en(s2_write_en),

	.master_ready(s2_master_ready),//need port ----> INCLUDED
	.master_valid(s2_master_valid),

	.slave_valid(s2_slave_valid),//need port -----> INCLUDED
	.slave_ready(s2_slave_ready),

	.rx_addr(s2_rx_address),
	.rx_data(s2_rx_data),
	.rx_burst(s2_rx_burst_num),				
	.tx_data(s2_tx_data));

slave SLAVE_3(
	.clk(clk), 
	.reset(reset),

	//.slave_delay(6'd10),

	.read_en(s3_read_en),
	.write_en(s3_write_en),

	.master_ready(s3_master_ready),//need port ----> INCLUDED
	.master_valid(s3_master_valid),

	.slave_valid(s3_slave_valid),//need port -----> INCLUDED
	.slave_ready(s3_slave_ready),

	.rx_addr(s3_rx_address),
	.rx_data(s3_rx_data),	
	.rx_burst(s3_rx_burst_num),				
	.tx_data(s3_tx_data));

endmodule