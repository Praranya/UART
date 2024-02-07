`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2024 12:01:33 AM
// Design Name: 
// Module Name: SIPO
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


module SIPO(reset_n,data_tx,baud_clk,active_flag,recieved_flag,data_parll);
input  wire         reset_n,data_tx,baud_clk;        //  Active low reset,  Serial Data recieved from the transmitter, The clocking input comes from the sampling unit.
output reg          active_flag,recieved_flag;    //  outputs logic 1 when data is in progress, outputs a signal enables the deframe unit. 
output reg  [10:0]  data_parll;      //  outputs the 11-bit parallel frame.

//  Internal
reg [3:0]  frame_counter;
reg [3:0]  stop_count;
reg [1:0]  next_state;

//  Encoding the states of the reciever
//  Every State captures the corresponding bit from the frame
localparam IDLE   = 2'b00,
           CENTER = 2'b01,
           FRAME  = 2'b10,
           HOLD   = 2'b11;

//  FSM with Asynchronous Reset logic
always @(posedge baud_clk, negedge reset_n) 
begin
  if (~reset_n) 
  begin
    next_state        <= IDLE;
  end
  else
  begin
    case (next_state)
      //  Idle case waits untill start bit
      IDLE : 
      begin
        data_parll    <= {11{1'b1}};
        stop_count    <= 4'd0;
        frame_counter <= 4'd0;
        recieved_flag <= 1'b0;
        active_flag   <= 1'b0;
        //  waits till sensing the start bit which is low
        if(~data_tx)
        begin
          next_state  <= CENTER;
          active_flag <= 1'b1;
        end
        else
        begin
          next_state  <= IDLE;
          active_flag <= 1'b0;
        end
      end

      //  shifts the sampling to the Center of the recieved bit
      //  due to the protocol, thus the bit is stable.
      CENTER : 
      begin
        if(&stop_count[2:0])
        //  This is an equivalent condition to (stop_count == 7)
        //  in order to avoid comparators/xors
        begin
          //  Captures the start bit
          data_parll[0]  <= data_tx;
          stop_count     <= 4'd0;
          next_state     <= FRAME;
        end
        else
        begin
          stop_count  <= stop_count + 4'b1;
          next_state  <= CENTER;
        end
      end

      //  shifts the remaining 10-bits of the frame,
      //  then returns to the idle case.
      FRAME :
      begin
        if(frame_counter[1] && frame_counter[3])
        //  This is an equivalent condition to (frame_counter == 4'd10)
        //  in order to avoid comparators/xors
        begin
          frame_counter <= 4'd0;
          recieved_flag <= 1'b1;
          next_state    <= HOLD;
          active_flag   <= 1'b0;
        end
        else
        begin
          if(&stop_count[3:0])
          //  This is an equivalent condition to (stop_count == 4'd15)
          //  in order to avoid comparators/xors
          begin
            data_parll[frame_counter + 4'd1]    <= data_tx;
            frame_counter                       <= frame_counter + 4'b1;
            stop_count                          <= 4'd0; 
            next_state                          <= FRAME;
          end
          else 
          begin
            stop_count <= stop_count + 4'b1;
            next_state <= FRAME;
          end
        end
      end

      //  Holds the data recieved for a 16 baud cycles
      HOLD :
      begin
        if(&stop_count[3:0])
          //  This is an equivalent condition to (stop_count == 4'd15)
          //  in order to avoid comparators/xors
          begin
            data_parll    <= data_parll;
            frame_counter <= 4'd0;
            stop_count    <= 4'd0; 
            recieved_flag <= 1'b0;
            next_state    <= IDLE;
          end
          else 
          begin
            stop_count <= stop_count + 4'b1;
            next_state <= HOLD;
          end
      end

      //  Automatically directs to the IDLE state
      default : 
      begin
        next_state <= IDLE;
      end
    endcase
  end
end

    
endmodule
