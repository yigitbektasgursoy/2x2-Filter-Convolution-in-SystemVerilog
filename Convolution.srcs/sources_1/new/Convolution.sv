`timescale 1ns / 1ps


module Convolution #(parameter WIDTH = 640, DEPTH = 360, logic filter [0:1][0:1] = '{'{1, 0},'{0,1}})
    (
    input clk_i, // input clock
    input rst_ni, // logic-0 asserted asynch reset
    input logic valid_i, // asserted when pixels are loaded into the module
    input logic [7:0] pixel_i, // pixel values loaded
    output logic valid_o, // asserted when the convolution are done 
    output logic [7:0] pixel_o // convolved pixel values 
    );
    
    logic [7:0]mem_image[0:DEPTH-1][0:WIDTH-1]; //memory block for input image
    logic [7:0]conv_result[0:(DEPTH/2)-1][0:(WIDTH/2)-1] = '{default: '0}; //memory block for convelted_image - all elements are zero in default case
    logic img_loaded; // image is loaded
    int row_counter , column_counter ,conv_sum ;
    logic conv_done; //


//first - 11.11.2023
    
    // Load picture
//    always @(posedge clk_i or negedge rst_ni)begin
//        if (!rst_ni)begin
//            row_counter <= 0;
//            column_counter <= 0;
//            img_loaded <= 0;
//        end

//        else if (valid_i || !img_loaded)begin
//            mem_image[row_counter][column_counter] <= pixel_i;
//            if (row_counter < DEPTH)begin
//                if (column_counter < WIDTH)begin
//                    column_counter <= column_counter+1;                        
//                end
//                else begin
//                    row_counter <= row_counter+1;
//                    column_counter <= 0;
//                end
//            end
//            else begin
//                row_counter <= 0;
//            end
//        end
//        if ( (row_counter == DEPTH-1) && column_counter == WIDTH-1)begin
//            img_loaded <=1;
//            row_counter <=0;
//            column_counter <=0;
//        end         
//    end
    
//    //convolution block
//    always @(posedge clk_i or negedge rst_ni)begin
//        if (!rst_ni)begin
//            row <= 0;
//            column <=0;
//            valid_o <= 0;
//        end
//        else if(img_loaded)begin
//            if (row < DEPTH)begin
//                if(column < WIDTH)begin
//                    conv_result = conv_result + (mem_image[row][column]*filter[0][0]) >> 2;     
//                    conv_result = conv_result + (mem_image[row][column+1]*filter[0][1]) >> 2;
//                    conv_result = conv_result + (mem_image[row+1][column]*filter[1][0]) >> 2;
//                    conv_result = conv_result + (mem_image[row+1][column+1]*filter[1][1]) >> 2;
//                    cnvltd_image[row/2][column/2] = conv_result;
//                    column = column+2; // slide frame
//                    conv_result = 0; //Reset     
//                end
//                else begin
//                    row <= row+2;
//                    column <= 0;
//                end
//            end
//        end
//        else if (row == DEPTH-1 && column == WIDTH-1)begin
//            valid_o <=1;
//            row <=0;
//            column <=0;
//        end         
//    end
    
//    //display convolved pixel values
    
//    always @(posedge clk_i or negedge rst_ni)begin
//        if (!rst_ni)begin
//            row <= 0;
//            column <= 0;
//            pixel_o <= 0;
//        end
//        else if (valid_o)begin
//            pixel_o <= cnvltd_image[row][column];
//            if (row < DEPTH)begin
//                if (column < WIDTH)begin
//                    column <= column+1;                        
//                end
//                else begin
//                    row <= row+1;
//                    column <= 0;
//                end
//            end
//            else begin
//                row <= 0;
//            end
//        end
//        else if (row == DEPTH-1 && column == WIDTH-1)begin
//            cnvltd_pixel_done <= 1;
//            row <=0;
//            column <=0;
//        end         
//    end
//endmodule




//16.11.2023 - updating
    // row and column counter - image load block
    always_ff @(posedge clk_i or negedge rst_ni)begin
        if (!rst_ni)begin
            row_counter <= 0;
            column_counter <= 0;
            img_loaded <= 0;
        end
        else if (valid_i && !img_loaded)begin
            if (row_counter == DEPTH-1 && column_counter == WIDTH-1)begin
                row_counter <= 0;
                column_counter <=0;
                img_loaded <=1;
            end
            else if (row_counter < DEPTH)begin
                mem_image[row_counter][column_counter] <= pixel_i;
                if(column_counter < WIDTH)begin
                    column_counter <= column_counter+1;
                end
                else begin
                    column_counter <= 0;
                    row_counter <= row_counter+1;
                end
            end
        end
    end
    
//    //process block - conv - display
    always @(posedge clk_i or negedge rst_ni)begin
        if(!rst_ni)begin
            conv_done <= 0;
            conv_sum <= 0;
            pixel_o <= 0;
        end
        else if(img_loaded)begin
            if(row_counter == DEPTH && column_counter == 0)begin
                valid_o <= 1;
                row_counter <= 0;
                column_counter <= 0;
                img_loaded <= 0;
            end
            if(row_counter < DEPTH)begin
                if(column_counter < WIDTH)begin
                    conv_sum = (((mem_image[row_counter][column_counter]*filter[0][0]) >> 2)+((mem_image[row_counter][column_counter+1]*filter[0][1]) >> 2) +
                               ((mem_image[row_counter+1][column_counter]*filter[1][0]) >> 2)+((mem_image[row_counter+1][column_counter+1]*filter[1][1]) >> 2));
                    conv_result[row_counter/2][column_counter/2] = conv_sum;
                    conv_sum = 0;
                    column_counter <= column_counter + 2;
                end
                else begin
                    row_counter <= row_counter + 2;
                    column_counter <= 0;
                end
            end
        end
        else if(valid_o)begin
            pixel_o <= conv_result[row_counter][column_counter];
            if(row_counter < DEPTH/2)begin
                if(column_counter < WIDTH/2)begin
                    column_counter <= column_counter+1;
                end
                else begin
                    column_counter <= 0;
                    row_counter <= row_counter+1;
                end
            end
            if ((row_counter/2 == DEPTH) && (column_counter/2 == WIDTH))begin
                valid_o <= 0;
            end
        end
    end
endmodule