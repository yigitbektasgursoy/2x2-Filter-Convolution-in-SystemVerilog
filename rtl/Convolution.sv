//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: YIGIT BEKTAS GURSOY
//
// Create Date: 10/07/2024 03:32:35 PM
// Design Name:
// Module Name: Convolution
// Project Name: VGG-16 BASED ON FPGA
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




//`define DEBUG 1
module Convolution import pckg::*;
    (
        input clk_i,                                // Input clock
        input rst_i,                                // Active-high synchronous reset
        input logic valid_i,                        // Asserted when pixels are loaded into the module
        input logic [DATA_WIDTH - 1:0] pixel_i,     // Pixel values
        input logic [DATA_WIDTH - 1:0] filter [0: FILTER_SIZE**2 - 1],
        output logic valid_o,                       // Asserted when the convolution is done
        output logic [DATA_WIDTH - 1:0] pixel_o     // Convolved pixel values
    );



    state_t state, next_state;

    logic [DATA_WIDTH-1:0] input_image_buffer [0:WIDTH*DEPTH-1];
    logic [DATA_WIDTH-1:0] convolved_image_block [0 : STRIDE_NUMBER_COLUMN * STRIDE_NUMBER_ROW - 1];
    logic load_done, conv_done, all_pixels_read;

    // Counters
    logic [$clog2(WIDTH*DEPTH)-1:0] load_counter;
    logic [$clog2(STRIDE_NUMBER_COLUMN * STRIDE_NUMBER_ROW)-1:0] conv_counter, store_counter, conv_index;

    `ifdef DEBUG
        integer debug_counter;
    `endif

    always @(posedge clk_i)begin
        if(rst_i)begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            valid_o <= '0;
            pixel_o <= '0;
            `ifdef DEBUG
                debug_counter <= '0;
            `endif
        end
        else begin
            case (state)
                IDLE: begin
                    conv_done <= 1'b0;
                    load_done <= 1'b0;
                    all_pixels_read <= 1'b0;

                    load_counter <= '0;
                    conv_counter <= '0;
                    store_counter <= '0;
                    conv_index <= '0;

                    valid_o <= 1'b0;
                end

                LOAD: begin
                    if (valid_i) begin
                        input_image_buffer[load_counter] <= pixel_i;
                        load_counter <= load_counter + 1;
                        load_done <= (load_counter == WIDTH*DEPTH - 1)? 1'b1: 1'b0;
                    end
                end

                CONV: begin
                    convolved_image_block[conv_index] <=
                        (input_image_buffer[conv_counter]             * filter[0]) +
                        (input_image_buffer[conv_counter + 1]         * filter[1]) +
                        (input_image_buffer[conv_counter + WIDTH]     * filter[FILTER_SIZE]) +
                        (input_image_buffer[conv_counter + WIDTH + 1] * filter[FILTER_SIZE + 1]);

                    conv_index <= conv_index + 1'b1;
                    conv_counter <= ((conv_counter + FILTER_SIZE) % WIDTH == 0 && conv_counter > (WIDTH - (FILTER_SIZE + 1)))? conv_counter + 2: conv_counter + 1;
                    conv_done <= (conv_index == (STRIDE_NUMBER_COLUMN * STRIDE_NUMBER_ROW - 2))? 1'b1: 1'b0;// Normally, this should end at STRIDE_NUMBER_COLUMN * STRIDE_NUMBER_ROW - 1,
                                                                                                            // but due to sequential processing, we finish one clock cycle earlier.
                    
                    `ifdef DEBUG
                        /* -------------------------------- DEBUG CODE BEGIN -------------------------------*/
                        $display("input_buffer[%0d]:   %0d ------ input_buffer[%0d]:   %0d ------ input_buffer[%0d]:  %0d ------ input_buffer[%0d]:   %0d ", 
                        conv_counter, input_image_buffer[conv_counter],
                        conv_counter + 1, input_image_buffer[conv_counter + 1], 
                        conv_counter + WIDTH, input_image_buffer[conv_counter + WIDTH ],
                        conv_counter + WIDTH + 1, input_image_buffer[conv_counter + WIDTH + 1]);
                    
                        $display("filter[%0d]: %0d ------ filter[%0d]: %0d ------ filter[%0d]: %0d ------ filter[%0d]: %0d ", 
                        0, filter[0],
                        1, filter[1],
                        FILTER_SIZE, filter[FILTER_SIZE],
                        FILTER_SIZE + 1, filter[FILTER_SIZE + 1]);
                    
                    
                        #1 debug_counter <= debug_counter + 1;
                        $display("#%0t CONV RESULT ******* convolved_image_block[%0d]: %0d \n", $time, debug_counter, convolved_image_block[debug_counter]);
                    /* -------------------------------- DEBUG CODE END -------------------------------*/
                    `endif
                end

                STORE: begin
                    store_counter <= (!all_pixels_read)? (store_counter + 1): store_counter;
                    pixel_o <= convolved_image_block[store_counter];
                    valid_o <= (store_counter >= STRIDE_NUMBER_COLUMN * STRIDE_NUMBER_ROW)? 1'b0: 1'b1;
                    all_pixels_read <= (store_counter == STRIDE_NUMBER_COLUMN * STRIDE_NUMBER_ROW - 1)? 1'b1: 1'b0;    
                end
            endcase
        end
    end
    

    always_comb begin
        case(state)
            IDLE:   next_state = valid_i ? LOAD : IDLE;
            LOAD:   next_state = load_done ? CONV : LOAD;
            CONV:   next_state = conv_done ? STORE : CONV;
            STORE:  next_state = all_pixels_read ? IDLE : STORE;
            default: next_state = IDLE;
        endcase
    end
endmodule