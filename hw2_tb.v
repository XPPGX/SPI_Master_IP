`timescale 1ns/10ps

module hw2_tb;

reg 	clk_50M;
reg 	reset_n;
reg 	write;
wire 	write_complete;
//reg  	write_complete;
reg 	read;
wire	read_complete;
//reg	read_complete;
reg 	[7:0] write_value;
wire 	[7:0] read_value;
wire	spi_csn;
wire	spi_sck;
wire	spi_do;
wire	spi_di;
hw2 u1 (
    .clk_50M(clk_50M),
    .reset_n(reset_n),    
    .write(write),
    .write_value(write_value),
    .write_complete(write_complete),    
    .read(read),
    .read_value(read_value),
    .read_complete(read_complete),   
    // spi bus
    .spi_csn(spi_csn),
    .spi_sck(spi_sck),
    .spi_do(spi_do),
    .spi_di(spi_di)
    );
    
M25AA010A u2(
    .SI(spi_do), 
    .SO(spi_di), 
    .SCK(spi_sck), 
    .CS_N(spi_csn), 
    .WP_N(1'b1), 
    .HOLD_N(1'b1), 
    .RESET(~reset_n)
    );

always
  #10 clk_50M = ~clk_50M;
  
initial
  begin
  reset_n = 0;    
  clk_50M = 0 ;
  write = 0;
  write_value = 8'h00;
  read = 0;  
  #30 reset_n = 1;
  
  spi_write(8'h06);  // set write enable
  
  #1_000_000;
  
  spi_write(8'h02);  // write cmd
  spi_write(8'h00);  // write addr
  spi_write(8'h78);  // write data
  
  #6_000_000;

  spi_write(8'h06);  // set write enable
  
  #1_000_000;
  
  spi_write(8'h02);  // write cmd
  spi_write(8'h01);  // write addr
  spi_write(8'h9A);  // write data
  
  #6_000_000;   
  
  spi_write(8'h06);  // set write enable
  
  #1_000_000;
  
  spi_write(8'h02);  // write cmd
  spi_write(8'h02);  // write addr
  spi_write(8'hBC);  // write data
  
  #6_000_000; 
  $finish;
  end
  
initial
  begin
  $monitor("time=%3d memory_00=0x%x memory_01=0x%x memory_02=0x%x ",$time,u2.MemoryByte00[7:0],u2.MemoryByte01[7:0],u2.MemoryByte02[7:0]);
  end

  
task spi_write; 
 input [7:0] data; 
 begin
  write_value = data;
  #1_000; // 
  write = 1;
  #1_000; // 
  write = 0;
  
  wait(write_complete == 1);
  $display("time=%3d write_date=0x%x ", $time,write_value);
 
 end
endtask 

task spi_read;    
 begin
  #1_000; // 
  read = 1;
  #1_000; // 
  read = 0;  
  wait(read_complete == 1);
  $display("time=%3d read_date=0x%x ", $time,read_value);
 end
endtask 
  
endmodule