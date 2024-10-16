`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/11/2024 08:04:02 PM
// Design Name:
// Module Name: pckg
// Project Name: Convolution
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


package pckg;

    parameter WIDTH = 64; // Width of the image
    parameter DEPTH = 36; // Depth of the image
    parameter DATA_WIDTH = 8;
    parameter FILTER_SIZE = 2;
    parameter STRIDE_NUMBER_COLUMN = WIDTH - FILTER_SIZE + 1;
    parameter STRIDE_NUMBER_ROW    = DEPTH - FILTER_SIZE + 1;


    typedef enum logic [1:0] {
        IDLE = 2'b00,
        LOAD = 2'b01,
        CONV = 2'b10,
        STORE = 2'b11
    } state_t;

    

endpackage