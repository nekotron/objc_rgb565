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
