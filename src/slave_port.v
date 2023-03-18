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

	//input [5:0]slave_delay,

	input read_en,
	input write_en,

	input master_ready,
	input master_valid,
	
	output reg slave_valid,
	output slave_ready,

	input rx_address,
	input rx_data,
	input rx_burst,
	output tx_data,

	input [7:0]datain,
	output [11:0]address,
	output [7:0]data,
	
	output read_en_in,
	output write_en_in/*,
	output reg split_en = 0*/);
	

wire [11:0]burst_counter;
wire slave_ready_IN;
wire slave_ready_OUT;
wire rx_done;
wire slave_tx_done;
wire read_en_in1;
wire write_en_in1;
wire [3:0]addr_counter;

reg [3:0]counterReg = 0; 
reg [12:0]burst = 13'd0;

assign slave_ready = slave_ready_IN & slave_ready_OUT;

reg [2:0]state = 1;
reg [4:0]burst_bit_counter = 4'd0;
reg [2:0]burst_state = 0;

parameter 
IDLE = 0,
NORMAL = 1,
/*SPLIT = 2,*/
VALID = 3,
BURST_END = 4,
BURST_BIT_RECIEVE = 5;

	
slave_in_port SLAVE_IN_PORT(
	.clk(clk), 
	.reset(reset),
	
	.rx_data(rx_data),
	.rx_addr(rx_address),
	
	.master_ready(master_ready),
	.master_valid(master_valid),
	.burst(burst),
	.read_en(read_en),
	.write_en(write_en),
	
	.slave_valid(slave_valid),
	
	
	.slave_ready(slave_ready_IN),
	.rx_done(rx_done),
	.address(address),
	.data(data),
	.read_en_in1(read_en_in1),
	.write_en_in1(write_en_in1),
	.read_en_in(read_en_in),
	.write_en_in(write_en_in),
	.burst_counter(burst_counter),
	.addr_counter(addr_counter));

slave_out_port SLAVE_OUT_PORT(
	.clk(clk), 
	.reset(reset),
	.master_ready(master_ready),
	.datain(datain),
	.slave_valid(slave_valid),
	.slave_ready(slave_ready_OUT),
	.slave_tx_done(slave_tx_done),
	.tx_data(tx_data));


always @ (posedge clk)
begin
	case (state)
		NORMAL:
		begin
			if ((read_en_in1 == 1) & (rx_done == 1)/* & (slave_delay < 5)*/) 
			begin
				counterReg <= 4'b0;
				slave_valid <= 1'b0;
				state <= VALID;
				//split_en <= 1'b0;
			end
			/*else if ((read_en_in1 == 1) & (rx_done == 1) & (~(slave_delay < 5))) //slow slave split
			begin
				counterReg <= 4'b0;
				slave_valid <= 1'b0;
				state <= SPLIT;
				split_en <= 1'b1;
			end
			else if ((addr_counter == 4'd5) && ((burst_counter + 12'd1) % 8 == 0) && (burst_counter != burst[12:1]))  //Write burst split
			begin
				counterReg <= 4'b0;
				slave_valid <= 1'b0;
				state <= SPLIT;
				split_en <= 1'b1;
			end*/
			else
			begin
				counterReg <= 4'b0;
				slave_valid <= 1'b0;
				//split_en <= 1'b0;
				state <= NORMAL;
			end
		end 
		/*SPLIT:
		begin
			if (counterReg < slave_delay)  //delayed slave split
			begin
				counterReg <= counterReg + 4'b1;
				slave_valid <= 1'b0; 
				split_en = 1'b1;
				state <= SPLIT;
			end
			else if ((addr_counter == 4'd6) && ((burst_counter + 12'd1) % 8 == 0) && (read_en_in1 == 0))  //write burst split
			begin
				slave_valid <= 1'b0;
				split_en = 1'b1;
				state <= NORMAL;
			end
			else if ((addr_counter == 4'd7) && ((burst_counter + 12'd1) % 8 == 0) && (read_en_in1 == 1))  //read burst split
			begin
				slave_valid <= 1'b1; 
				split_en = 1'b1;  
				state <= VALID;
			end				
			else
			begin
				counterReg <= 4'b0;
				slave_valid <= 1'b1;
				split_en <= 1'b0;
				state <= VALID;
			end
		end*/
		VALID:
		begin
			if((slave_tx_done == 1) & (slave_valid == 1) & (burst[0] == 1'd0))
			begin
				counterReg <= 4'b0;
				slave_valid <= 1'b0;
				//split_en <= 1'b0;
				state <= NORMAL;
			end
			else if((slave_tx_done == 1) & (slave_valid == 1) & (burst[12:1] + 1 == burst_counter) & (burst[0] == 1'd1))
			begin
				counterReg <= 4'b0;
				slave_valid <= 1'b1;
				//split_en <= 1'b0;
				state <= BURST_END;
			end/*
			else if ((addr_counter == 4'd6) && ((burst_counter + 12'd1) % 8 == 0))  //read burst split
			begin
				counterReg <= 4'b0;
				slave_valid <= 1'b1;
				state <= SPLIT;
				split_en <= 1'b1;  
			end */
			else
			begin
				counterReg <= 4'b0;
				slave_valid <= 1'b1;
				//split_en <= 1'b0;
				state <= VALID;
			end
		end
		BURST_END:
		begin
			if((slave_tx_done == 1) & (slave_valid == 1))
			begin
				counterReg <= 4'b0;
				slave_valid <= 1'b0;
				//split_en <= 1'b0;
				state <= NORMAL;
			end
			else 
			begin
				counterReg <= 4'b0;
				slave_valid <= 1'b1;
				//split_en <= 1'b0;
				state <= BURST_END;
			end
		end
	endcase
end


always @ (posedge clk or posedge reset) 
begin
	if (reset)
	begin
		burst_state <= IDLE;
		burst_bit_counter <= 0;
	end
	else
	begin
	case (burst_state)
            IDLE:
            begin
                if ((master_valid && slave_ready) && (read_en || write_en))
                begin
                    burst[burst_bit_counter] <= rx_burst;
                    burst_state <= BURST_BIT_RECIEVE;
                    burst_bit_counter <= burst_bit_counter + 1;
                end
                else
                begin
                    burst_state <= burst_state;
                    burst_bit_counter <= 0;
                end
            end
            BURST_BIT_RECIEVE:
            begin
                if (burst_bit_counter < 4'd12)    // change to 13 ?
                begin
                    burst[burst_bit_counter] <= rx_burst;
                    burst_bit_counter <= burst_bit_counter + 1;
                    burst_state <= burst_state;
                end
                else 
                begin
                    burst_state <= IDLE;
                    burst_bit_counter <= 0;
                end
            end
            default:
            begin
                burst_state <= IDLE;
            end
        endcase
    end
end

endmodule