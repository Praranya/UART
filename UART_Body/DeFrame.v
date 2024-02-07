`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2024 12:12:24 AM
// Design Name: 
// Module Name: DeFrame
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


module DeFrame(reset_n,recieved_flag,data_parll,parity_bit,start_bit,stop_bit,done_flag,raw_data); 
input wire          reset_n,recieved_flag;        //  Active low reset, enable indicates when data is in progress.
input wire  [10:0]  data_parll;     //  Data frame passed from the sipo unit.
output reg          parity_bit,start_bit,stop_bit,done_flag;     //  The parity bit separated from the data frame,  The Start bit separated from the data frame.
 //  The Stop bit separated from the data frame, Indicates that the data is recieved and ready for another data packet.
output reg  [7:0]   raw_data;        //  The 8-bits data separated from the data frame.


//  -Deframing- Output Data & parity bit logic with Asynchronous Reset 
always @(*) 
begin
  if (~reset_n) 
  begin
    //  Idle
    raw_data     <= {8{1'b1}};
    parity_bit   <= 1'b1;
    start_bit    <= 1'b0;
    stop_bit     <= 1'b1;
    done_flag    <= 1'b1;
  end
  else
  begin
    if (recieved_flag)
    begin
      start_bit  <= data_parll[0];
      raw_data   <= data_parll[8:1];
      parity_bit <= data_parll[9];
      stop_bit   <= data_parll[10];
      done_flag  <= 1'b1;
    end
    else 
    begin
      //  Idle
      raw_data   <= {8{1'b1}};
      parity_bit <= 1'b1;
      start_bit  <= 1'b0;
      stop_bit   <= 1'b1;
      done_flag  <= 1'b0;
    end
  end
end

    
endmodule
