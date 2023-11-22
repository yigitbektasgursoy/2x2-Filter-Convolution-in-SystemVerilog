// RISC-V Architecture & Processor Homework 1
// Yunus Emre Cakiroglu - 040190019
// cakiroglu19@itu.edu.tr

`timescale 1ns / 1ps

module convolution_tb;

  // Parameters
  localparam MAX_WIDTH = 640;
  localparam MAX_HEIGHT = 360;

  // Testbench Signals
  reg clk;
  reg rst_n;
  reg valid;
  reg [7:0] pixel;
  wire valid_o;
  wire [7:0] pixel_o;

  // Instantiate the Convolution Module
  Convolution #(
      .filter('{'{1, 0}, '{0, 1}})
  ) uut (
      .clk_i  (clk),
      .rst_ni (rst_n),
      .valid_i(valid),
      .pixel_i(pixel),
      .valid_o(valid_o),
      .pixel_o(pixel_o)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100 MHz Clock
  end

  // Reset
  initial begin
    rst_n = 0;
    valid = 0;
    pixel = 0;
    #100;  // Hold reset for 100 ns
    rst_n = 1;
  end

  // Test Stimulus
  initial begin
    @(posedge rst_n);


    valid = 1;
    @(posedge clk);
    // Apply test inputs
    for (int y = 0; y < MAX_HEIGHT; y++) begin
      for (int x = 0; x < MAX_WIDTH; x++) begin
        pixel = $random;  // Or specific values
      end
    end
    

    // Wait for processing to complete
    wait (valid_o);

    $finish;
  end

  // Monitor
  always @(posedge clk) begin
    if (valid_o) begin
      $display("Pixel: %d", pixel_o);
    end
  end

endmodule
