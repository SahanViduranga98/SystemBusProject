/* 
 file name : master_in_port.v
 Description:
	This file contains the input port of the master port.
	It is responsible for receiving the data from 
	the slave.
 Maintainers : Sahan Viduranga <sahanvidurangassc767@gmail.com>
					
					
 Revision : v1.0 
*/

module master_in_port #(parameter DATA_LEN=8, parameter BURST_LEN=12)(
	input clk, 
	input reset,
	
	input tx_done,
	input [1:0]instruction,
	input [BURST_LEN-1:0]burst_num,
	output reg[DATA_LEN-1:0]data,
	output reg rx_done,
	output reg new_rx,
	
	input rx_data,
	input slave_valid,
	output reg master_ready);
	
reg [2:0]state = 0;
reg [DATA_LEN-1:0]temp_data;
parameter IDLE=0, WAIT_HANDSHAKE=1, RECEIVE_DATA=2;

integer count = 0;
integer burst_count = 0;

always @ (posedge clk or posedge reset) 
begin
    //if reset is high, back to start position
	if (reset)
	begin
		count <= 0;
		state <= IDLE;
		data  <= 0;
		temp_data <= 0;
		rx_done <= 0;
		new_rx <= 0;
		master_ready <= 1;
		burst_count <= 0;
		
	end	
	
	else
		case (state)
		
		IDLE:
		begin
            //go to hand_shake state
			if (instruction == 2'b11 && tx_done == 1)
			begin
				count <= 0;
				state <= WAIT_HANDSHAKE;
				data	<= data;
				temp_data <= temp_data;		
				rx_done <= 0;
				new_rx <= 0;
				master_ready <= 1;
				burst_count <= 0;
				
			end
			
			else
            //stay in the idle state
			begin
				count <= count;
				state <= IDLE;
				data	<= data;
				temp_data <= temp_data;	
				rx_done <= 0;
				new_rx <= 0;
				master_ready <= 1;
				burst_count <= burst_count;
				
			end
		end
		
		WAIT_HANDSHAKE:
		begin
            //go to receive_data state
			if (slave_valid == 1 && master_ready == 1)
			begin
				count <= count + 1;
				state <= RECEIVE_DATA;
				temp_data[count] <= rx_data;
				data <= data;	
				
				rx_done <= rx_done;
				new_rx <= 0;
				master_ready <= 0;
				burst_count <= burst_count;
				
			end
			
			else
            //stay in the wait_handshake state
			begin
				count <= count;
				state <= WAIT_HANDSHAKE;
				data	<= data;
				temp_data <= temp_data;	
				rx_done <= rx_done;
				new_rx <= 0;
				master_ready <= 1;
				burst_count <= burst_count;
				
			end
		end
		
		RECEIVE_DATA:
		begin
			if (count >= DATA_LEN-1)
			begin
				count <= 0;
				if (burst_count >= burst_num)
				begin
					state <= IDLE;
					rx_done <= 1;
					burst_count <= burst_count;
				end
				else
				begin
					state <= WAIT_HANDSHAKE;
					rx_done <= 0;
					burst_count <= burst_count+1;
				end
				
				new_rx <= 1;
				temp_data[count] <= rx_data;
				data[count] <= rx_data;
				data[DATA_LEN-2:0] <= temp_data[DATA_LEN-2:0];
				master_ready <= 1;
				
			end
			
			else
            //stay in receive_data state
			begin
				count <= count + 1;
				state <= RECEIVE_DATA;
				temp_data[count] <= rx_data;
				data <= data;	
				rx_done <= rx_done;
				new_rx <= new_rx;
				master_ready <= 0;
				burst_count <= burst_count;
			end
		end
		
		default:
		begin 
			count <= count;
			state <= IDLE;
			data	<= data;
			temp_data <= temp_data;	
			rx_done <= 0;
			new_rx <= 0;
			master_ready <= 1;
			burst_count <= burst_count;
		end
		
		endcase
end

endmodule