Written for fun and practice over a day and a half.
Useful for converting JPG and PNG into RGB 565 format directly without having to feed in a bitmap.
It also has the ability to interpolate if you are resizing the image, but for best results the images should be square or cropped to be a square.
If images are not square, they can be resized but they will be stretched.

The negative and ppm preview were for debugging purposes and the negative was left in temporarily, but will be removed eventually.

When compiled, this does make a command line utility. 
So, although files cannot be directly dragged onto the binary they can easily be dragged into the terminal window to perform a batch conversion.

# objc_rgb565
Converts a JPG or PNG into a RGB565 suitable for use with a ST7789 display (probably used with an arduino compatible microcontroller).
USAGE: convertTo565 [-i] [-p] [-h height] [-w width] [-o path] imageFile1 imageFile2...
    -----------------------------------------------------------------------------------
    -h height    height in pixels
    -w width     width in pixels
    -o outDir    directory to output to
    -i           interpolate for a smoother image
    -n           make image a negative (just for fun, was used to test)
    -p           make ppm preview
    -?           this help message
