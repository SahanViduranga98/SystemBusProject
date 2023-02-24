/* 
 file name : master_out_port.v
 Description:
	This file contains the output port of the master port.
	It is responsible for accessing a slave.
 Maintainers : Sahan Viduranga <sahanvidurangassc767@gmail.com>
					
					
 Revision : v1.0 
*/

module master_out_port #(parameter SLAVE_LEN=2, parameter ADDR_LEN=12, parameter DATA_LEN=8, parameter BURST_LEN=12)(
	input clk, 
	input reset,
	
	input [SLAVE_LEN-1:0]slave_select,
	input [1:0]instruction, 
	input [ADDR_LEN-1:0]address,
	input [DATA_LEN-1:0]data,
	input [BURST_LEN-1:0]burst_num,
	input rx_done,
	output reg tx_done,
	
	input slave_ready,
	input arbitor_busy,
	input bus_busy,
	input approval_grant,
	output reg master_ready,
	output reg approval_request,
	output reg tx_slave_select,
	output reg master_valid,
	output reg write_en,
	output reg read_en,	
	output reg tx_address,
	output reg tx_data,
	output reg tx_burst_num); //check

reg [4:0]state = 0;
reg [DATA_LEN-1:0]temp_data = 0;

parameter IDLE=0, WAIT_ARBITOR=1, TRANSMIT_SELECT=2, WAIT_APPROVAL=3, WAIT_HANDSHAKE=4, 
				TRANSMIT_BURST_ADDR_DATA=5, TRANSMIT_ADDR_DATA=6, TRANSMIT_BURST_ADDR=7, TRANSMIT_BURST_DATA=8,
				TRANSMIT_BURST_FIRST_BIT=9, TRANSMIT_DATA=10, TRANSMIT_ADDR=11, WAIT_BUS=12, FIRST_BIT_BURST=13,
				WAIT_HANDSHAKE_BURST=14, TRANSMIT_DATA_BURST=15, FINISH=16, READ_WAIT=17;
				
parameter INACTIVE=2'b00, WRITE=2'b10, READ=2'b11;

integer count = 0;
integer count2 = 0;
integer burst_count = 0;

always @ (posedge clk or posedge reset) 
begin
	if (reset)
	begin
		count <= 0;
		state <=IDLE;
		master_ready<= 1;
		approval_request<= 0;
		tx_slave_select<= 0;
		master_valid<= 0;
		write_en<= 0;
		read_en<= 0;	
		tx_address<= 0;
		tx_data<= 0;
		tx_done<= 0;
		burst_count <= 0;
		temp_data <= 0;
		tx_burst_num <= 0;
		count2 <= 0;
	end
	else
		case (state)
		
		IDLE:
		begin
			if (instruction[1]==1)
			begin
				if (bus_busy == 0 && arbitor_busy == 0)
				begin
					count <= count+1;
					state <= TRANSMIT_SELECT;
					master_ready<= 0;
					approval_request <= 1;
					tx_slave_select <= slave_select[count];
					master_valid <= 0;
					write_en <= 0;
					read_en <= 0;	
					tx_address <= tx_address;
					tx_data <= tx_data;
					tx_done <= 0;
					burst_count <= 0;
					temp_data <= data;
					tx_burst_num <= tx_burst_num;
					count2 <= count2;
				end
				else
				begin
					count <= count;
					state <= WAIT_ARBITOR;
					master_ready<= 0;
					approval_request <= 0;
					tx_slave_select <= tx_slave_select;
					master_valid <= 0;
					write_en <= 0;
					read_en <= 0;	
					tx_address <= tx_address;
					tx_data <= tx_data;
					tx_done <= 0;
					burst_count <= 0;
					temp_data <= data;
					tx_burst_num <= tx_burst_num;
					count2 <= count2;
				end
			end
			
			else
			begin
				count <= 0;
				state <=IDLE;
				master_ready <= 1;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 0;
				write_en <= 0;
				read_en <= 0;	
				tx_address <= tx_address;
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
			
		end
		
		WAIT_ARBITOR:
		begin
			if (bus_busy == 0 && arbitor_busy == 0)
			begin
				count <= count+1;
				state <= TRANSMIT_SELECT;
				master_ready<= 0;
				approval_request <= 1;
				tx_slave_select <= slave_select[count];
				master_valid <= 0;
				write_en <= 0;
				read_en <= 0;	
				tx_address <= tx_address;
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
			else
			begin
				count <= count;
				state <= WAIT_ARBITOR;
				master_ready<= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 0;
				write_en <= 0;
				read_en <= 0;	
				tx_address <= tx_address;
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
		end
		
		TRANSMIT_SELECT:
		begin
			if (count >= SLAVE_LEN-1)
			begin
				count <= 0;
				if (bus_busy==0)
					state <=WAIT_APPROVAL;
				else	
					state <=WAIT_BUS;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= slave_select[count];
				master_valid <= 0;
				write_en <= 0;
				read_en <= 0;	
				tx_address <= tx_address;
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
			
			else
			begin
				count <= count+1;
				state <=TRANSMIT_SELECT;
				master_ready <= 0;
				approval_request <= 1;
				tx_slave_select <= slave_select[count];
				master_valid <= 0;
				write_en <= 0;
				read_en <= 0;	
				tx_address <= tx_address;
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
		end
		
		WAIT_BUS:
		begin
			if (bus_busy==0)
			begin
				count <= count;
				state <= WAIT_APPROVAL;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 0;
				write_en <= 0;
				read_en <= 0;	
				tx_address <= tx_address;
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
			
			else
			begin
				count <= count;
				state <= WAIT_BUS;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 0;
				write_en <= 0;
				read_en <= 0;	
				tx_address <= tx_address;
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
		end
		
		WAIT_APPROVAL:
		begin
			if (approval_grant==1)
			begin
				count <= count+1;
				state <=WAIT_HANDSHAKE;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;

			// instruction==1--->read enable
				if (instruction[0]==1)
				begin
					write_en <= 0;
					read_en <= 1;	
				end
				else
				// instruction==0--->write enable
				begin
					write_en <= 1;
					read_en <= 0;	
				end
				tx_address <= address[count];
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				if (burst_num==0)
					tx_burst_num <= 0;
				else
					tx_burst_num <= 1;
				count2 <= 0;
			end
			
			else
			begin
			
				if (bus_busy == 1) 
				begin
					count <= 0;
					state <= WAIT_ARBITOR;
					master_ready<= 0;
					approval_request <= 1;
					tx_slave_select <= slave_select[count];
					master_valid <= 0;
					write_en <= 0;
					read_en <= 0;	
					tx_address <= tx_address;
					tx_data <= tx_data;
					tx_done <= 0;
					burst_count <= burst_count;
					temp_data <= temp_data;
					tx_burst_num <= tx_burst_num;
					count2 <= count2;
				end
				
				else
				begin
					count <= count;
					state <= WAIT_APPROVAL;
					master_ready <= 0;
					approval_request <= 0;
					tx_slave_select <= tx_slave_select;
					master_valid <= 0;
					write_en <= 0;
					read_en <= 0;	
					tx_address <= tx_address;
					tx_data <= tx_data;
					tx_done <= 0;
					burst_count <= burst_count;
					temp_data <= temp_data;
					tx_burst_num <= tx_burst_num;
					count2 <= count2;
				end

			end
		end
		
		WAIT_HANDSHAKE:
		begin
			//if master and slave are ready to data transaction, sampling of the first bit is done
			if (master_valid==1 && slave_ready==1)
			begin
				count <= count+1;
				state <=TRANSMIT_BURST_ADDR_DATA;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2+1;
			end
			
			//if master and slave are not ready to data transaction, go back to wait_handshake state 
			else
			begin
				count <= count;
				state <= WAIT_HANDSHAKE;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;	
				tx_address <= tx_address;
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
		end
		
		//after hanshaking, transmitting addtess and data starts
		TRANSMIT_BURST_ADDR_DATA:
		begin
			if (count >= DATA_LEN-1 && count >= ADDR_LEN-1 && count2 >= BURST_LEN-1)
			begin
				count <= 0;
				//for write operation
				if (instruction[0]==0)
				begin
					//if it is not a burst operation, go to finish state
					if (burst_num==0)
					begin
						state <= FINISH;
						temp_data <= temp_data;
						tx_done <= 1;
					end
					else
					//if it is a burst operation, send the last bit of the burst number
					begin
						state <= FIRST_BIT_BURST;
						temp_data <= temp_data+1;
						tx_done <= 0;
					end
				end
				//for read operation
				else
				begin
					state <= READ_WAIT;
					temp_data <= temp_data;
					tx_done <= 1;
				end
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= temp_data[count];
				burst_count <= burst_count;
				tx_burst_num <= burst_num[count2];
				count2 <= count2;
			end
			
			//no need of this state, always address_len>burst_len
			else if (count < DATA_LEN-1 && count < ADDR_LEN-1 && count2 >= BURST_LEN-1)
			begin
				count <= count+1;
				state <= TRANSMIT_ADDR_DATA;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2;
			end
			
			//finishes sending data(count>data_len-1)
			else if (count >= DATA_LEN-1 && count < ADDR_LEN-1 && count2 < BURST_LEN-1)
			begin
				count <= count+1;
				state <= TRANSMIT_BURST_ADDR;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2+1;
			end
			
			//no need of this state,always data_len<address_len
			else if (count < DATA_LEN-1 && count >= ADDR_LEN-1 && count2 < BURST_LEN-1)
			begin
				count <= count+1;
				state <= TRANSMIT_BURST_DATA;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2+1;
			end
			
			//no need of this state, since always burst_len>address_len
			else if (count >= DATA_LEN-1 && count < ADDR_LEN-1 && count2 >= BURST_LEN-1)
			begin
				count <= count+1;
				state <= TRANSMIT_ADDR;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2;
			end
			
			//no need of this state, since always burst_len>address_len
			else if (count < DATA_LEN-1 && count >= ADDR_LEN-1 && count2 >= BURST_LEN-1)
			begin
				count <= count+1;
				state <= TRANSMIT_DATA;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2;
			end
			
			//finshed reading data and address
			else if (count >= DATA_LEN-1 && count >= ADDR_LEN-1 && count2 < BURST_LEN-1)
			begin
				count <= 0;
				//check whether the instruction is to write
				if (instruction[0]==0)
				begin
					//check whether it is burst operation
					if (burst_num==0)
					//if not only one data write, go to finish state
					begin
						state <= FINISH;
						tx_done <= 1;
						temp_data <= temp_data;
					end
					//if it is a burst write, goto next state to send the last bit of the burst address
					else
					begin
						state <= TRANSMIT_BURST_FIRST_BIT;
						tx_done <= 0;
						temp_data <= temp_data+1;
					end
				end
				//if it is a read operation, 
				else
				begin
					//if it is not a burst read command, go to read_wait state, transmission done
					if (burst_num==0)
					begin
						state <= READ_WAIT;
						tx_done <= 1;
						temp_data <= temp_data;
					end
					//if it is a burst write, goto next state to send the last bit of the burst address
					else
					begin
						state <= TRANSMIT_BURST_FIRST_BIT;
						tx_done <= 0;
						temp_data <= temp_data+1;
					end
				end
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= temp_data[count];
				burst_count <= burst_count;
				tx_burst_num <= burst_num[count2];
				count2 <= count2+1;
			end
			
			//count<data_len, continus to transmit data, address and burst_num
			else
			begin
				count <= count+1;
				state <= TRANSMIT_BURST_ADDR_DATA;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= 0;
				read_en <= 0;	
				tx_address <= address[count];
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2+1;
			end
		end
		
		//no need of this state
		TRANSMIT_ADDR_DATA:
		begin
			//receive all the data and address bits
			if (count >= DATA_LEN-1 && count >= ADDR_LEN-1)
			begin
				count <= 0;
				//if the instruction is to write 
				if (instruction[0]==0)
				begin
					//if it is not a burst write, go to finish state
					if (burst_num==0)
					begin
						state <= FINISH;
						temp_data <= temp_data;
						tx_done <= 1;
					end
					//else go to next state to send last bit of burst address
					else
					begin
						state <= FIRST_BIT_BURST;
						temp_data <= temp_data+1;
						tx_done <= 0;
					end
				end
				//if it is a read instruction
				else
				begin
					state <= READ_WAIT;
					temp_data <= temp_data;
					tx_done <= 1;
				end
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= temp_data[count];
				burst_count <= burst_count;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
			
			//finished sending data bits
			else if (count >= DATA_LEN-1 && count < ADDR_LEN-1)
			begin
				count <= count+1;
				state <= TRANSMIT_ADDR;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
			

			//finished sending address
			else if (count < DATA_LEN-1 && count >= ADDR_LEN-1)
			begin
				count <= count+1;
				state <= TRANSMIT_DATA;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
			
			//not finishing sending addresss and data
			else
			begin
				count <= count+1;
				state <= TRANSMIT_ADDR_DATA;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= 0;
				read_en <= 0;	
				tx_address <= address[count];
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
		end
		
		//after finishing sending data, this state comes,send the remaining address bits
		TRANSMIT_BURST_ADDR:
		begin
			//send first 12 bits of the burst address and address
			if (count2 >= BURST_LEN-1 && count >= ADDR_LEN-1)
			begin
				count <= 0;
				if (instruction[0]==0)
				begin
					//if it is not a burst write
					if (burst_num==0)
					begin
						state <= FINISH;
						temp_data <= temp_data;
						tx_done <= 1;
					end
					//if it is a burst write
					else
					begin
						state <= FIRST_BIT_BURST;
						temp_data <= temp_data+1;
						tx_done <= 0;
					end
				end
				//if it is a read command
				else
				begin
					state <= READ_WAIT;
					temp_data <= temp_data;
					tx_done <= 1;
				end
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= tx_data;
				burst_count <= burst_count;
				tx_burst_num <= burst_num[count2];
				count2 <= count2;
			end
			
			//no use of this condition
			else if (count2 >= BURST_LEN-1 && count < ADDR_LEN-1)
			begin
				count <= count+1;
				state <= TRANSMIT_ADDR;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2;
			end
			
			//send all the adreess 
			else if (count2 < BURST_LEN-1 && count >= ADDR_LEN-1)
			begin
				count <= 0;
				//if it is a write command
				if (instruction[0]==0)
				begin
					//if it is not a burst operaton 
					if (burst_num==0)
					begin
						state <= FINISH;
						temp_data <= temp_data;
						tx_done <= 1;
						
					end
					//if burst then send last bit of address
					else
					begin
						state <= TRANSMIT_BURST_FIRST_BIT;
						temp_data <= temp_data+1;
						tx_done <= 0;
					end
				end
				//read command
				else
				begin
					//if it is not a burst operaton 
					if (burst_num==0)
					begin
						state <= READ_WAIT;
						temp_data <= temp_data;
						tx_done <= 1;
					end
					//if burst then send last bit of address
					else
					begin
						state <= TRANSMIT_BURST_FIRST_BIT;
						temp_data <= temp_data+1;
						tx_done <= 0;
					end
				end
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= tx_data;
				burst_count <= burst_count;
				tx_burst_num <= burst_num[count2];
				count2 <= count2+1;
			end
			
			//not completed sending address
			else
			begin
				count <= count+1;
				state <= TRANSMIT_BURST_ADDR;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= 0;
				read_en <= 0;	
				tx_address <= address[count];
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2+1;
			end
		end
		

		//no use of this state
		TRANSMIT_BURST_DATA:
		begin
			if (count >= DATA_LEN-1 && count2 >= BURST_LEN-1)
			begin
				count <= 0;
				if (instruction[0]==0)
				begin
					if (burst_num==0)
					begin
						state <= FINISH;
						temp_data <= temp_data;
						tx_done <= 1;
					end
					else
					begin
						state <= FIRST_BIT_BURST;
						temp_data <= temp_data+1;
						tx_done <= 0;
					end
				end
				else
				begin
					state <= READ_WAIT;
					temp_data <= temp_data;
					tx_done <= 1;
				end
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= tx_address;
				tx_data <= temp_data[count];
				burst_count <= burst_count;
				tx_burst_num <= burst_num[count2];
				count2 <= count2;
			end
			
			else if (count >= DATA_LEN-1 && count2 < BURST_LEN-1)
			begin
				count <= 0;
				if (instruction[0]==0)
				begin
					if (burst_num==0)
					begin
						state <= FINISH;
						temp_data <= temp_data;
						tx_done <= 1;
					end
					else
					begin
						state <= TRANSMIT_BURST_FIRST_BIT;						
						temp_data <= temp_data+1;
						tx_done <= 0;
					end
				end
				else
				begin
					if (burst_num==0)
					begin
						state <= READ_WAIT;
						tx_done <= 1;
					end
					else
					begin
						state <= TRANSMIT_BURST_FIRST_BIT;
						tx_done <= 0;
					end
				end
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= tx_address;
				tx_data <= temp_data[count];
				burst_count <= burst_count;
				tx_burst_num <= burst_num[count2];
				count2 <= count2+1;
			end
			
			else if (count < DATA_LEN-1 && count2 >= BURST_LEN-1)
			begin
				count <= count+1;
				state <= TRANSMIT_DATA;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= tx_address;
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2;
			end
			
			else
			begin
				count <= count+1;
				state <= TRANSMIT_BURST_DATA;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= 0;
				read_en <= 0;	
				tx_address <= tx_address;
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2+1;
			end
		end
		

		//no use of this state
		TRANSMIT_DATA:
		begin
			if (count >= DATA_LEN-1)
			begin
				count <= 0;
				if (instruction[0]==0)
				begin
					if (burst_num==0)
					begin
						state <= FINISH;
						temp_data <= temp_data;
						tx_done <= 1;
					end
					else
					begin
						state <= FIRST_BIT_BURST;
						temp_data <= temp_data+1;
						tx_done <= 0;
					end
				end
				else
				begin
					state <= READ_WAIT;
					temp_data <= temp_data;
					tx_done <= 1;
				end
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= tx_address;
				tx_data <= temp_data[count];
				burst_count <= burst_count;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
			
			else
			begin
				count <= count+1;
				state <= TRANSMIT_DATA;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;	
				tx_address <= tx_address;
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
		end
		

		//no use of this state
		TRANSMIT_ADDR:
		begin
			if (count >= ADDR_LEN-1)
			begin
				count <= 0;
				if (instruction[0]==0)
				begin
					if (burst_num==0)
					begin
						state <= FINISH;
						temp_data <= temp_data;
						tx_done <= 1;
					end
					else
					begin
						state <= FIRST_BIT_BURST;
						temp_data <= temp_data+1;
						tx_done <= 0;
					end
				end
				else
				begin
					state <= READ_WAIT;
					temp_data <= temp_data;
					tx_done <= 1;
				end
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= tx_data;
				burst_count <= burst_count;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
			
			else
			begin
				count <= count+1;
				state <= TRANSMIT_ADDR;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= address[count];
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
		end
		
		//if a burst operation, send the last bit of the address
		TRANSMIT_BURST_FIRST_BIT:
		begin
			//received lst bit of the burst address
			if (count2 >= BURST_LEN-1)
			begin
				count <= count+1;
				//if write instruction
				if (instruction[0]==0)
				begin
					state <= WAIT_HANDSHAKE_BURST;
					tx_done <= 0;
				end
				//if read instruction
				else
				begin
					state <= READ_WAIT;
					tx_done <= 1;
				end
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= tx_address;
				tx_data <= temp_data[count];
				temp_data <= temp_data;
				burst_count <= burst_count+1;
				tx_burst_num <= burst_num[count2];
				count2 <= count2;
			end
			
			//if not received last bit
			else
			begin
				count <= count;
				state <= TRANSMIT_BURST_FIRST_BIT;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= tx_address;
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= burst_num[count2];
				count2 <= count2+1;
			end
		end
		
		/* 
		
		Have to add TRANSMIT_BURST_WAIT_HANDSHAKE and TRANSMIT_BURST_TRANSMIT_DATA for this to work 
			when more than one burst bit is left to be sent out.
			
		*/
		
		FIRST_BIT_BURST:
		begin
			count <= count+1;
			state <=WAIT_HANDSHAKE_BURST;
			master_ready <= 0;
			approval_request <= 0;
			tx_slave_select <= tx_slave_select;
			master_valid <= 1;
			write_en <= write_en;
			read_en <= read_en;	
			tx_address <= tx_address;
			tx_data <= temp_data[count];
			tx_done <= 0;
			burst_count <= burst_count+1;
			temp_data <= temp_data;	
			tx_burst_num <= tx_burst_num;
			count2 <= count2;
		end
		

		//wait for handshake of the master and slave, first bit of the next data send while sending the first bit of the burst address
		WAIT_HANDSHAKE_BURST:
		begin
			//if handshake is done
			if (master_valid==1 && slave_ready==1)
			begin
				count <= count+1;
				state <=TRANSMIT_DATA_BURST;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= tx_address;
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
			
			else
			begin
				count <= count;
				state <= WAIT_HANDSHAKE_BURST;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;	
				tx_address <= tx_address;
				tx_data <= tx_data;
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
		end
		

		//transmit all the burst data 
		TRANSMIT_DATA_BURST:
		begin
			//if send all the data bits
			if (count >= DATA_LEN-1)
			begin
				count <= 0;
				//check whether there is more burst data to be send
				if (burst_count >= burst_num)
				//if no, then go to finish state
				begin
					state <= FINISH;
					temp_data <= temp_data;
					tx_done <= 1;
				end
				//otherwise go to send the first bit of the burst 
				else
				begin
					state <= FIRST_BIT_BURST;
					temp_data <= temp_data+1;
					tx_done <= 0;
				end
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;
				tx_address <= tx_address;
				tx_data <= temp_data[count];
				burst_count <= burst_count;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
			
			else
			begin
				count <= count+1;
				state <= TRANSMIT_DATA_BURST;
				master_ready <= 0;
				approval_request <= 0;
				tx_slave_select <= tx_slave_select;
				master_valid <= 1;
				write_en <= write_en;
				read_en <= read_en;	
				tx_address <= tx_address;
				tx_data <= temp_data[count];
				tx_done <= 0;
				burst_count <= burst_count;
				temp_data <= temp_data;
				tx_burst_num <= tx_burst_num;
				count2 <= count2;
			end
		end
		
		//reading 
		READ_WAIT:
		begin
			count <= 0;
			//if reading is finished go to idle state
			if (rx_done == 1)
				state <= IDLE;
				//otherwise, stay in the read state
			else
				state <= READ_WAIT;
			master_ready <= 1;
			approval_request <= 0;
			tx_slave_select <= tx_slave_select;
			master_valid <= 0;
			write_en <= 0;
			read_en <= 0;	
			tx_address <= tx_address;
			tx_data <= tx_data;
			tx_done <= 0;
			burst_count <= burst_count;
			temp_data <= temp_data;
			tx_burst_num <= tx_burst_num;
			count2 <= count2;
		end
		
		//after finishing writing, come to this state, next state is idle
		FINISH:
		begin
			count <= 0;
			state <=IDLE;
			master_ready <= 1;
			approval_request <= 0;
			tx_slave_select <= tx_slave_select;
			master_valid <= 0;
			write_en <= 0;
			read_en <= 0;	
			tx_address <= tx_address;
			tx_data <= tx_data;
			tx_done <= 0;
			burst_count <= burst_count;
			temp_data <= temp_data;
			tx_burst_num <= tx_burst_num;
			count2 <= count2;
		end
		
		//default case
		default:
		begin 
			count <= 0;
			state <= IDLE;
			master_ready <= 1;
			approval_request <= 0;
			tx_slave_select <= tx_slave_select;
			master_valid <= 0;
			write_en <= 0;
			read_en <= 0;
			tx_address <= tx_address;
			tx_data <= tx_data;
			tx_done <= 0;
			burst_count <= 0;
			temp_data <= 0;
			tx_burst_num <= tx_burst_num;
			count2 <= 0;
		end
		
		endcase
end

endmodule