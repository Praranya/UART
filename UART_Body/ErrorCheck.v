`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2024 12:05:59 AM
// Design Name: 
// Module Name: ErrorCheck
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


module ErrorCheck(reset_n,recieved_flag,parity_bit,start_bit,stop_bit,parity_type,raw_data,error_flag);
input wire         reset_n,recieved_flag,parity_bit,start_bit,stop_bit;       //  Active low reset,enable from the sipo unit for the flags,The parity bit from the frame for comparison.
 //  The Start bit from the frame for comparison,  The Stop bit from the frame for comparison.
input wire  [1:0]  parity_type;   //  Parity type agreed upon by the Tx and Rx units.
input wire  [7:0]  raw_data;      //  The 8-bits data separated from the data frame.

    //  bus of three bits, each bit is a flag for an error
    //  error_flag[0] ParityError flag, error_flag[1] StartError flag,
    //  error_flag[2] StopError flag.
output reg [2:0]   error_flag;


//  Internal
reg error_parity;
reg parity_flag;
reg start_flag;
reg stop_flag;

//  Encoding for the 4 types of the parity
localparam ODD        = 2'b01,
           EVEN       = 2'b10,
           NOPARITY00 = 2'b00,
           NOPARITY11 = 2'b11;

//  Asynchronous Reset logic

//  Parity Check logic
always @(*) 
begin
    case (parity_type)
      NOPARITY00, NOPARITY11:
      begin
      error_parity <= 1'b1;      
      end

      ODD: 
      begin
        error_parity <= (^raw_data)? 1'b0 : 1'b1;
      end

      EVEN: 
      begin
        error_parity <= (^raw_data)? 1'b1 : 1'b0;
      end

      default: 
      begin
        error_parity <= 1'b1;      
        //  No Parity
      end
    endcase
end

always @(*) begin
  if (~reset_n) 
  begin
    parity_flag  <= 1'b0;
    start_flag   <= 1'b0;
    stop_flag    <= 1'b0;
  end
  else
  begin
    //  flag logic
    if(recieved_flag)
    begin
      parity_flag <= ~(error_parity && parity_bit);
      //  Equivalent to (error_parity != parity_bit)
      //  in order to avoid comparators/xors
      start_flag  <= (start_bit || 1'b0);
      //  Equivalent to (start_bit != 1'b0)
      //  in order to avoid comparators/xors
      stop_flag   <= ~(stop_bit && 1'b1);
      //  Equivalent to (stop_bit != 1'b1)
      //  in order to avoid comparators/xors
    end
    else
    begin
      parity_flag  <= 1'b0;
      start_flag   <= 1'b0;
      stop_flag    <= 1'b0;
    end
  end
end

//  Output logic
always @(*) 
begin
  error_flag = {stop_flag,start_flag,parity_flag};
end


    
endmodule
