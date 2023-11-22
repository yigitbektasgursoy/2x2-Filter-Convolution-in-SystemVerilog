# ** 2*2 Filter Convolution using SystemVerilog**

**Description**

This project implements a convolution module using SystemVerilog. The module takes an 8-bit grayscale image of size 640x360 pixels as input, and applies a 2x2 filter to it. The filter coefficients are defined as a parameter, and can be changed as needed. The module outputs an 8-bit grayscale image of size 320x180 pixels, which is the result of the convolution operation. The module uses a valid signal to indicate when the input image is loaded and when the output image is ready.

**Specifications and Requirements**

- The module should use a memory block to store the input image, and another memory block to store the output image.
- The module should use counters to iterate over the pixels and perform the convolution operation.
- The module should use a valid signal to indicate when the input image is loaded and when the output image is ready.
- The module should use a parameter to define the filter coefficients, and another parameter to define the pixel width.

**Design and Implementation**

The module consists of three main parts: the image load block, the convolution block, and the display block.

- The image load block is responsible for loading the input image into the memory block. It uses a valid input signal to indicate when the pixels are available, and a pixel input signal to provide the pixel values. It also uses a row counter and a column counter to store the pixels in the correct location in the memory block. It sets an image loaded signal to high when the whole image is loaded.
- The convolution block is responsible for performing the convolution operation on the input image. It uses the image loaded signal to start the convolution process, and the filter parameter to apply the filter coefficients. It also uses a row counter and a column counter to access the pixels in the memory block, and a conv sum variable to store the intermediate results. It stores the convolved pixels in another memory block, and sets a valid output signal to high when the convolution is done.
- The display block is responsible for displaying the output image. It uses the valid output signal to indicate when the output image is ready, and a pixel output signal to provide the pixel values. It also uses a row counter and a column counter to access the pixels in the memory block. It resets the counters and the signals when the whole image is displayed.

The module uses a clock input signal and a reset input signal to synchronize and initialize the operations. The module uses a parameter to define the image size, and another parameter to define the pixel width. The module uses an interface to connect to other modules or devices.

**Simulation and Testing**

A testbench was created to provide the random input integers, the filter coefficients, the clock signal, and the reset signal. The testbench also monitored the output image, the valid signals, and the pixel signals. The testbench used random inputs to generate the input image, and a predefined filter to perform the convolution. The testbench also displayed the input image and the output image on a waveform viewer.

The simulation and testing results showed that the module performed the convolution operation correctly, and produced the expected output image. 


![waveform](https://github.com/grsyigit/ConvolutionModuleusingSystemVerilog/assets/92864598/a64cec25-d51b-4b7c-a7ca-7ca2043f1ed3)
![scope](https://github.com/grsyigit/ConvolutionModuleusingSystemVerilog/assets/92864598/e3cdee32-4cdf-4c2c-bb5a-b05390683201)
