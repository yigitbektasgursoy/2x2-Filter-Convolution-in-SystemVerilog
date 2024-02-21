module Convolution #(
    parameter WIDTH = 640, // Width of the image
    parameter DEPTH = 360, // Depth of the image
    logic filter [0:1][0:1] = '{'{1, 0},'{0,1}} // 2x2 convolution filter
)
(
    input clk_i,       // Input clock
    input rst_ni,      // Active-low asynchronous reset
    input logic valid_i,    // Asserted when pixels are loaded into the module
    input logic [7:0] pixel_i,  // Pixel values loaded
    output logic valid_o,   // Asserted when the convolution is done
    output logic [7:0] pixel_o  // Convolved pixel values
);

    // Counters for image loading
    int row_counter1, column_counter1;
    
    // Counters for convolution on the loaded image
    int row_counter2, column_counter2;
    
    // Counters for transferring convolved pixels
    int row_counter3, column_counter3;
    
    int conv_sum; // Variable to store convolution sum
    
    logic img_loaded = 0, img_loaded_triggered = 0, valid_o_reg = 0, valid_o_triggered = 0;
    
    // Arrays to store convolution results and input image
    logic [7:0] conv_result[0:(DEPTH/2)-1][0:(WIDTH/2)-1];
    logic [7:0] mem_image[0:DEPTH-1][0:WIDTH-1];
    
    assign valid_o = valid_o_reg; // Output valid signal
    
    // Image loading and convolution completion detection logic
    always_comb begin
        if ((row_counter1 == DEPTH-1) && (column_counter1 == WIDTH-1) && !img_loaded_triggered) begin
            img_loaded = 1'b1;
            img_loaded_triggered = 1'b1;
        end
        if ((row_counter2 == DEPTH-2) && (column_counter2 == WIDTH-2) && !valid_o_triggered) begin
            valid_o_reg = 1'b1;
            valid_o_triggered = 1'b1;
        end
    end 
    
    // Image loading logic using counter1
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            row_counter1 <= 0;
            column_counter1 <= 0;        
        end
        else if (!img_loaded && valid_i) begin
            mem_image[row_counter1][column_counter1] <= pixel_i; // Load pixel values
            if (row_counter1 < DEPTH) begin
                if (column_counter1 < WIDTH) begin
                    column_counter1 <= column_counter1 + 1;
                end
                else begin
                    column_counter1 <= 0;
                    row_counter1 <= row_counter1 + 1;
                end
            end
        end
    end
    
    // Convolution logic using counter2
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            conv_sum <= 0;
            column_counter2 <= 0;
            row_counter2 <= 0;
        end
        else if (img_loaded && !valid_o) begin
            if (row_counter2 < DEPTH) begin
                if (column_counter2 < WIDTH) begin
                    // 2x2 convolution operation
                    conv_sum = (((mem_image[row_counter2][column_counter2] * filter[0][0]) >> 2) +
                                ((mem_image[row_counter2][column_counter2+1] * filter[0][1]) >> 2) +
                                ((mem_image[row_counter2+1][column_counter2] * filter[1][0]) >> 2) +
                                ((mem_image[row_counter2+1][column_counter2+1] * filter[1][1]) >> 2));
                    conv_result[row_counter2/2][column_counter2/2] = conv_sum; // Store convolution result
                    conv_sum = 0;
                    column_counter2 <= column_counter2 + 2;
                end
                else begin
                    column_counter2 <= 0;
                    row_counter2 <= row_counter2 + 2;               
                end
            end
        end
    end
    
    // Convolved pixel transfer logic using counter3
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pixel_o <= 8'h00;
            column_counter3 <= 0;
            row_counter3 <= 0;
        end
        else if (valid_o) begin
            pixel_o <= conv_result[row_counter3][column_counter3];
            if (row_counter3 < DEPTH/2) begin
                if (column_counter3 < WIDTH/2) begin
                    column_counter3 <= column_counter3 + 1;
                end
                else begin
                    column_counter3 <= 0;
                    row_counter3 <= row_counter3 + 1;
                end
            end
        end
    end

endmodule
