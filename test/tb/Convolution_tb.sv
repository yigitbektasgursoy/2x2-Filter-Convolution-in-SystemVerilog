`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: YIGIT BEKTAS GURSOY
//
// Create Date: 10/07/2024 03:32:35 PM
// Design Name:
// Module Name: Convolution_tb
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
import pckg::*;

class rand_num_gen;
    randc logic [DATA_WIDTH - 1:0]rand_pixel_i;
    randc logic [DATA_WIDTH - 1:0]rand_filter;


    constraint c_pixel_i {rand_pixel_i < 10;
        1 < rand_pixel_i;}

    constraint c_filter {rand_filter < 5;
        0 < rand_filter;
    }
endclass


module Convolution_tb();

    logic clk_i;                          // Input clock
    logic rst_i;                          // Active-high synchronous reset
    logic valid_i;                        // Asserted when pixels are loaded into the module
    logic [DATA_WIDTH - 1:0] pixel_i;     // Pixel values
    logic [DATA_WIDTH - 1:0] filter [0: FILTER_SIZE**2 - 1];
    logic valid_o;                       // Asserted when the convolution is done
    logic [DATA_WIDTH - 1:0] pixel_o;    // Convolved pixel values
    integer CLK_PERIOD = 10ns;

    integer load_counter;
    integer fd; //File descriptor
    
    // CREATE CLASS OBJECTS BEGIN
    rand_num_gen num_gen;
    // CREATE CLASS OBJECTS END

    Convolution DUT (clk_i, rst_i, valid_i, pixel_i, filter, valid_o, pixel_o);

    initial begin
        clk_i = 0;
        forever begin
            #(CLK_PERIOD) clk_i = ~clk_i;
        end
    end

    task automatic initialize(ref logic reset, valid);
        reset = 1;
        valid = 0;
        @(negedge clk_i);
        reset = 0;
        @(negedge clk_i);
    endtask


    task automatic import_filter();
        integer j = 0;
        fd = $fopen("filter.txt","w");
        if (fd == 0)begin
            $display("Error: Unable to open filter.txt file.");
        end
        for(integer i = 0; i < FILTER_SIZE**2; i++)begin
            assert(num_gen.randomize())begin
                j++;
                filter[i] = num_gen.rand_filter;
                $fwrite(fd, filter[i]);
                if(j == FILTER_SIZE)begin
                    $fwrite(fd, "\n");
                end
                //$display("Randomization successful filter[%0d] = %0d", i, filter[i]);
                @(negedge clk_i);
            end
            else begin
                $error("Filter randomization is fail");
            end
        end

        $display("ALL INPUT FILTERS ARE IMPORTED");
    endtask


    task automatic import_pixel(ref logic valid_in, ref logic [7:0]pixel_in);
        integer i = 0;
        valid_in = 1;
        fd = $fopen("input.txt","w");
        if(fd == 0)begin
            $display("Error: Unable to open input.txt file.");
        end
        @(negedge clk_i);
        for(load_counter = 0; load_counter <= WIDTH*DEPTH - 1; load_counter++)begin
            assert (num_gen.randomize()) begin
                i++;
                pixel_in = num_gen.rand_pixel_i;
                // $display("Pixel randomization is successful pixel_i = %0d", pixel_in);
                $fwrite(fd,pixel_in);
                if(i % WIDTH == 0)begin
                    $fwrite(fd,"\n");
                end
                @(negedge clk_i);
            end
            else begin
                $error("Pixel randomization is fail");
            end
        end
        @(negedge clk_i);
        $display("ALL INPUT PIXELS ARE IMPORTED");
        valid_in = 0;
    endtask

    task delay(integer CYCLE);
        repeat(CYCLE)begin
            @(negedge clk_i);
        end
    endtask
    
    task automatic write_txt();
        integer i = 0;
        fd = $fopen("actual_results.txt","w");
        if(fd == 0)begin
            $display("Error: Unable to open actual_results.txt file.");
        end
        wait(valid_o);
        @(negedge clk_i);
        while(pixel_o !== 8'bx)begin
            i++;
            $fwrite(fd, pixel_o);
            if(i % (WIDTH - 1) == 0 && i > WIDTH - 2)begin
                $fwrite(fd, "\n");
            end
            $display("#%0t pixel_o: %0d", $time, pixel_o);
            @(negedge clk_i);
        end
        $fclose(fd);
        $display("Actual results successfully are wrote");
    endtask

    initial begin
        num_gen = new();
        initialize(rst_i, valid_i);
        import_filter() ;
        import_pixel(valid_i, pixel_i);
        //delay( ((WIDTH * DEPTH - 1) - ((FILTER_SIZE - 1)*WIDTH -1) - (FILTER_SIZE - 1)) ); //CONVOLUTION AND STORE OPERATION
        write_txt();
        
        $finish;
    end


endmodule