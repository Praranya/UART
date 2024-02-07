`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/06/2024 11:26:44 PM
// Design Name: 
// Module Name: BaudGenTx
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


module BaudGenTx(reset_n,clock,baud_rate,baud_clk);
input wire         reset_n,clock;           //  Active low reset,The System's main clock.
input wire  [1:0]  baud_rate;         //  Baud Rate agreed upon by the Tx and Rx units.
output reg         baud_clk;           //  Clocking output for the other modules.


//  Internal declarations
reg [13 : 0] clock_ticks;
reg [13 : 0] final_val;

//  Encoding for the Baud Rates states
localparam BAUD24  = 2'b00,
           BAUD48  = 2'b01,
           BAUD96  = 2'b10,
           BAUD192 = 2'b11;

//  BaudRate 4-1 Mux
always @(baud_rate)
begin
    case (baud_rate)
        //  All these ratio ticks are calculated for 50MHz Clock,
        //  The values shall change with the change of the clock frequency.
        BAUD24 : final_val = 14'd10417;  //  ratio ticks for the 2400 BaudRate.
        BAUD48 : final_val = 14'd5208;   //  ratio ticks for the 4800 BaudRate.
        BAUD96 : final_val = 14'd2604;   //  ratio ticks for the 9600 BaudRate.
        BAUD192 : final_val = 14'd1302;  //  ratio ticks for the 19200 BaudRate.
        default: final_val = 14'd0;      //  The systems original Clock.
    endcase
end

//  Timer logic
always @(negedge reset_n, posedge clock)
begin
    if(~reset_n)
    begin
        clock_ticks <= 14'd0; 
        baud_clk    <= 14'd0; 
    end
    else
    begin
        //  Ticks whenever reaches its final value,
        //  Then resets and starts all over again.
        if (clock_ticks == final_val)
        begin
            clock_ticks <= 14'd0; 
            baud_clk    <= ~baud_clk; 
        end 
        else
        begin
            clock_ticks <= clock_ticks + 1'd1;
            baud_clk    <= baud_clk;
        end
    end 
end

endmodule

    

