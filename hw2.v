`timescale 1ns/10ps
module hw2(
	input clk_50M,
	input reset_n,
	input write,
	input read,
	input [7:0] write_value,
	output [7:0] read_value,
	output write_complete,
	output read_complete,
	output spi_csn,
	output spi_sck,
	output spi_do,
	output spi_di
	);
reg fflag;
reg sended;
reg [13:0]freq = 13'd0;
reg w_complete;
reg s_csn;
reg s_clk;
reg [4:0]i = 4'd0;
reg [2:0]wflag = 2'd0;
reg [3:0]num = 3'd0;
reg s_do = 1'b0;
reg zen = 1'b0;
wire w_pos;
wire w_neg;


edge_detect write1(.clk(clk_50M),.rst_n(reset_n),.data_in(write),.pos_edge(w_pos),.neg_edge(w_neg)); 

assign write_complete = w_complete;
assign spi_csn = s_csn;
assign spi_sck = s_clk;
assign spi_do = s_do;
assign ii = i;
always@(posedge clk_50M or negedge reset_n)
begin
	if(!reset_n)
		freq <= 1'd0;
	else if(freq == 13'd50)
		freq <= 1'd0;
	else
		freq <= freq + 1'd1;
end

always@(posedge clk_50M or negedge reset_n)
begin
	if(!reset_n)
	begin
		w_complete = 1'b1;
		s_csn = 1'b1;
		s_clk = 1'b0;
		fflag = 1'b0;
		sended = 1'b0;
	end
	else
	begin
		if(w_pos == 1'b1)
		begin
			w_complete = 1'b0;
			s_csn = 1'b0;
			fflag = 1'b0;
		end
		if(write_value == 8'h06)
		begin
			wflag = 1'd1;
		end
		else if (write_value == 8'h02)
		begin
			wflag = 2'd2;
		end
		if(w_complete == 1'b0 && s_csn == 1'b0 && write==1'b0)
		begin
			if(freq == 0)
			begin
				fflag = 1'b1;
				zen = 1'b0;
				if(i < 4'd8)
				begin
					if(s_clk == 1'b0 && sended == 1'b0)
			begin
						s_do = write_value[7-i];
						sended = 1'b1;
						i = i + 1'd1;
					end
				end
				else if( i == 4'd8)
				begin
					i = i + 1'd1;
					zen = 1'b1;
				end
				else if(i == 4'd9 && zen == 1'b0)
				begin
					i = 4'd0;
					w_complete = 1'b1;
					if(wflag == 2'd2)
						num = num + 1'd1;
				end
			end
			if(fflag == 1'b1 && freq ==50)
			begin
				s_clk = ~s_clk;
				sended = 1'b0;
				fflag = 1'b0;
			end
		end
		else if(w_complete == 1'b1 && write == 1'b0 && wflag == 1'd1)
			s_csn = 1'b1;
		else if(w_complete == 1'b1 && write == 1'b0 && wflag == 2'd2 && num == 3'd3)
		begin
			s_csn = 1'b1;
			num = 3'd0;
		end
	end
end

endmodule 