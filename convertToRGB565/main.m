//
//  main.m
//  convertToRGB565
//
//  Created by ジャスティン　フレシャワー on 2021/04/11.
//  Copyright © 2021年 ジャスティン　フレシャワー. All rights reserved.
//


//image data acquisition from
// https://stackoverflow.com/questions/8189180/how-can-i-get-the-underlying-pixel-data-from-a-uiimage-or-cgimage

//file acquisition from (unused tho)
// https://www.cocoanetics.com/2011/12/command-line-tools-tutorial-1/

#import <Foundation/Foundation.h>

//Global variables? In my christian minecraft server?
uint       outImageHeight    = 240;
uint       outImageWidth     = 240;
bool       makePPMPreview    = NO;
bool       shouldInterpolate = NO;
bool       shouldNegative    = NO;    //Make negative of image for funzies
NSString * outputDirectory   = NULL;

void writeOutFileToBinaryPPM(void * data, NSString * filename, unsigned int width, unsigned int height, unsigned int dataLength){
    NSLog(@"Data: %p, %@, %u, %u, %u", data, filename, height, width, dataLength);
    
    if(filename == NULL){
        NSLog(@"Having a bad time: filename is NULL");
        return;
    }
    
    NSString * ppmFilename = [filename stringByAppendingString:@"-edit.ppm"];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:ppmFilename contents:NULL attributes:NULL];
    
    NSString * header    = [NSString stringWithFormat:@"P6\n%d %d\n%d\n", width, height, 255];
    NSData   * pixelData = [NSData dataWithBytesNoCopy:data length:dataLength freeWhenDone:NO];
    NSError *theError;
    
    
    [header writeToFile:ppmFilename atomically:YES encoding:NSUTF8StringEncoding error:&theError];
    //[pixelData writeToFile:path atomically:YES]; //XXXX NO, this will clobber the file
    
    NSFileHandle * handle = [NSFileHandle fileHandleForUpdatingAtPath:ppmFilename];
    [handle seekToEndOfFile];
    [handle writeData:pixelData];
    [handle closeFile];
    
}


void writeOutFileToBinary565(void * data, NSString * filename, unsigned int width, unsigned int height, unsigned int dataLength){
    NSLog(@"Data: %p, %@, %u, %u, %u", data, filename, height, width, dataLength);
    
    if(filename == NULL){
        NSLog(@"Having a bad time: filename is NULL");
        return;
    }
    
    NSString * suffix = [NSString stringWithFormat:@"-rgb565_%dx%d",width, height];
    
    NSString * rgbFilename = [filename stringByAppendingString:suffix];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:rgbFilename contents:NULL attributes:NULL];
    
    NSData   * pixelData = [NSData dataWithBytesNoCopy:data length:dataLength freeWhenDone:NO];
    
    
    [pixelData writeToFile:rgbFilename atomically:YES]; //XXXX NO, this will clobber the file
}


CGContextRef CreateARGBBitmapContext (CGImageRef inImage){
    NSLog(@"CreateARGBBitmapContext");
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapBytesCount;
    int             bitmapBytesPerRow;
    
    //get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    NSLog(@"\npixelsWide: %zu, \npixelsHigh %zu", pixelsWide, pixelsHigh);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this example
    //   is represented by 4 bytes; 8 bits each of r, g, b, and alpha.
    //bitmapBytesPerRow   = (pixelsWide * 4);
    //bitmapBytesCount    = (bitmapBytesPerRow * pixelsHigh);
    
    bitmapBytesPerRow   = (outImageWidth * 4);
    bitmapBytesCount    = (bitmapBytesPerRow * outImageHeight);
    
    NSLog(@"\nbitmapBytesPerRow: %d,\nbitmapBytesCount %d", bitmapBytesPerRow, bitmapBytesCount);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (colorSpace == NULL) {
        NSLog(@"color space not allocated");
        fprintf(stderr, "color space not allocated");
        
    }
    bitmapData = malloc(bitmapBytesCount);
    if (bitmapData == NULL){
        NSLog(@"Memory not allocated");
        fprintf(stderr, "Memory not allocated");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    NSLog(@"Memory allocated");
    
    // Create teh bitmap context. We want pre-multiplied ARGB 8-bits per component.
    //   Regardless of what the source image format is (CMYK, Grayscale, and so on) it will
    //   it will be converted over to the format specified here in the CGBitmapContextCreate.
    /*context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh,
                                    8, //bits percomponent
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedFirst);*/
    context = CGBitmapContextCreate(bitmapData,
                                    outImageWidth,
                                    outImageHeight,
                                    8, //bits percomponent
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedFirst);
    NSLog(@"Context possibly allocated");
    
    if (context == NULL){
        NSLog(@"context not created");
        free (bitmapData);
        fprintf (stderr, "context not created");
    }
    NSLog(@"Context allocated");
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease(colorSpace);
    NSLog(@"Color space released");
    
    return context;
}

void manipulateImagePixelData(CGImageRef inImage, NSString * outFile){
    NSLog(@"manipulateImagePixelData");
    //Create the bitmap context
    CGContextRef cgctx = CreateARGBBitmapContext(inImage);
    if (cgctx == NULL) {
        //error creating context
        return;
    }
    NSLog(@"context supposedly created");
    
    //get image width, height. We'll use the entire image.
    size_t w = outImageWidth; // CGImageGetWidth(inImage);
    size_t h = outImageHeight; //CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    NSLog(@"\nw: %zu, \nh %zu", w, h);
    NSLog(@"rect origin x:%f, rect origin y:%f", rect.origin.x, rect.origin.x );
    NSLog(@"rect  size  x:%f, rect  size  y:%f", rect.size.width, rect.size.height );
    
    NSLog(@"inImage%@",inImage);
    NSLog(@"cgctx pointer %p", &cgctx);
    //Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rednigng will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    NSLog(@"cgctx %@",cgctx);
    
    //Now we can get a pointer to the image data associated with the bitmap context.
    void *data = CGBitmapContextGetData(cgctx);
    
    NSLog(@"POINTER GET? %p", data);
    
    if (data != NULL){
        //have pointer to data, do stuff to data here.
        //presumably making a bunch of 16 bit integers in an array and then writing them out the data to the array
        unsigned int maxX    = outImageWidth; //CGImageGetWidth(inImage);
        unsigned int maxY    = outImageHeight; //CGImageGetHeight(inImage);
        void *ppmData    = NULL;
        void *rgb565Data = NULL;
        
        if (makePPMPreview) {
          ppmData    = malloc(maxX * maxY * 3 * sizeof(unsigned char));
        }
        if(1){ //currently the main purpose of the program but we might add other types.
          rgb565Data = malloc(maxX * maxY * 2 * sizeof(unsigned char));
        }
        NSLog(@"\nmaxX: %u, \nmaxY %u", maxX, maxY);
        
        if(shouldNegative){
            for (int yPos = 0; yPos < maxY; ++yPos){
                for (int xPos = 0; xPos < maxX; ++xPos){
                    ((unsigned char*)data)[((yPos*maxX)+(xPos))*4+1]=0xFF-((unsigned char*)data)[((yPos*maxX)+(xPos))*4+1];
                    ((unsigned char*)data)[((yPos*maxX)+(xPos))*4+2]=0xFF-((unsigned char*)data)[((yPos*maxX)+(xPos))*4+2];
                    ((unsigned char*)data)[((yPos*maxX)+(xPos))*4+3]=0xFF-((unsigned char*)data)[((yPos*maxX)+(xPos))*4+3];
                }
            }
        }
        
        if(makePPMPreview){
            for (int yPos = 0; yPos < maxY; ++yPos){
                for (int xPos = 0; xPos < maxX; ++xPos){
                    ((unsigned char*)ppmData)[((yPos*maxX)+(xPos))*3+0]=((unsigned char*)data)[((yPos*maxX)+(xPos))*4+1];
                    ((unsigned char*)ppmData)[((yPos*maxX)+(xPos))*3+1]=((unsigned char*)data)[((yPos*maxX)+(xPos))*4+2];
                    ((unsigned char*)ppmData)[((yPos*maxX)+(xPos))*3+2]=((unsigned char*)data)[((yPos*maxX)+(xPos))*4+3];
                }
            }
            NSLog(@"You get that thing I sent ya? (calling writeOutFileToBinaryPPM)");
            writeOutFileToBinaryPPM(ppmData, outFile, maxX, maxY, maxX*maxY*3);
        }
        
        if(1){  //make 565 currently the only purpose therefore, always done.
            for (int yPos = 0; yPos < maxY; ++yPos){
                for (int xPos = 0; xPos < maxX; ++xPos){
                    unsigned char r = ((unsigned char*)data)[((yPos*maxX)+(xPos))*4+1];
                    unsigned char g = ((unsigned char*)data)[((yPos*maxX)+(xPos))*4+2];
                    unsigned char b = ((unsigned char*)data)[((yPos*maxX)+(xPos))*4+3];
                    unsigned char top = 0x00;
                    unsigned char btm = 0x00;
                    
                    r >>= 3;  //leaves 5 bits
                    g >>= 2;  //leaves 6 bits
                    b >>= 3;  //leaves 5 bits //blue is setup.
                    
                    r <<= 3;  //red is setup.
                    
                    top |= (g >> 3); //6 bits shift right 3 leaves the top 3
                    btm |= (g << 5); //6 bits shift left 5  leaves the bottom 3 bits   //green is done
                    
                    top |= r;        //or 5 highest bits of red into top 5 bits of top //red is done
                    
                    btm |= b;        //or 5 highest bits of blue into bottom bottom 5  //blue is done
                    
                    ((unsigned char*)rgb565Data)[((yPos*maxX)+(xPos))*2+0]=btm;
                    ((unsigned char*)rgb565Data)[((yPos*maxX)+(xPos))*2+1]=top;
                }
            }
            NSLog(@"You get that thing I sent ya? (calling writeOutFileToBinary565)");
            writeOutFileToBinary565(rgb565Data, outFile, maxX, maxY, maxX*maxY*2);
        }

        if (makePPMPreview && ppmData){
            free(ppmData);
        }

    }
    
    NSLog(@"CGContextRelease(cgctx);");
    //When finished release the context
    CGContextRelease(cgctx);
    
    NSLog(@"if (data){free(data)};");
    //Free image data memory for the context
    if (data){
        free(data);
    }
    
    
}

CGImageRef getImageRefFromFile(const char* filename){
    NSLog(@"getImageRefFromFile");
    
    
    NSString * filenameNSstr = [NSString stringWithCString:filename encoding:NSUTF8StringEncoding];
    NSURL * filenameNSurl = [NSURL fileURLWithPath:filenameNSstr];
    NSData * dataBytes = [NSData dataWithContentsOfURL:filenameNSurl];
    unsigned char * charBytes = (unsigned char *)[dataBytes bytes];
    
    
    //JPEG magic numbers
    unsigned char jpgMagicNumbers[6][4] =
    {
        {0xFF, 0xD8, 0xFF, 0xDB},
        {0xFF, 0xD8, 0xFF, 0xE0},
        {0xFF, 0xD8, 0xFF, 0xE1},
        {0xFF, 0xD8, 0xFF, 0xE2},
        {0xFF, 0xD8, 0xFF, 0xE3},
        {0xFF, 0xD8, 0xFF, 0xEE}
    };
    
    //PNG magic numbers
    unsigned char pngMagicNumbers[4] =
    {0x89, 0x50, 0x4E, 0x47};
    
    bool isJpg = !((charBytes[0]^jpgMagicNumbers[0][0]) | (charBytes[1]^jpgMagicNumbers[0][1]) | (charBytes[2]^jpgMagicNumbers[0][2]))&&
    ((jpgMagicNumbers[0][0]==charBytes[3])||(jpgMagicNumbers[1][3]==charBytes[3])||(jpgMagicNumbers[2][3]==charBytes[3])||(jpgMagicNumbers[3][3]==charBytes[3])||(jpgMagicNumbers[4][3]==charBytes[3])||(jpgMagicNumbers[5][3]==charBytes[3]));
    bool isPng = !((charBytes[0]^pngMagicNumbers[0]) | (charBytes[1]^pngMagicNumbers[1]) | (charBytes[2]^pngMagicNumbers[2])| (charBytes[3]^pngMagicNumbers[3]));
    
    NSLog(@"JPG  TEST: 0x%02X, 0x%02X, 0x%02X", jpgMagicNumbers[0][0], jpgMagicNumbers[0][1], jpgMagicNumbers[0][2]);
    NSLog(@"PNG  TEST: 0x%02X, 0x%02X, 0x%02X", pngMagicNumbers[0], pngMagicNumbers[1], pngMagicNumbers[2]);
    NSLog(@"DATA TEST: 0x%02X, 0x%02X, 0x%02X, 0x%02X, 0x%02X", charBytes[0], charBytes[1], charBytes[2], charBytes[3], charBytes[4]);
    
    
    
    CGDataProviderRef   imageDataProvider = CGDataProviderCreateWithFilename(filename);
    CGImageRef theImage; //= CGImageCreateWithJPEGDataProvider(imageDataProvider, NULL, NO, kCGRenderingIntentPerceptual);
    
    if (isJpg) {
        NSLog(@"IDENTIFIED: Jpeg");
        theImage = CGImageCreateWithJPEGDataProvider(imageDataProvider, NULL, shouldInterpolate, kCGRenderingIntentPerceptual);
    }
    else if (isPng){
        NSLog(@"IDENTIFIED: Png");
        theImage = CGImageCreateWithPNGDataProvider(imageDataProvider, NULL, shouldInterpolate, kCGRenderingIntentPerceptual);
    }
    else {
        unsigned char binPPMMagic[2] = {0x50, 0x36};
        unsigned char gifMagicNum[3] = {0x47, 0x49, 0x46};
        bool isPPM = !((charBytes[0]^binPPMMagic[0]) | (charBytes[1]^binPPMMagic[1]));
        bool isGIF = !((charBytes[0]^gifMagicNum[0]) | (charBytes[1]^gifMagicNum[1]) | (charBytes[2]^gifMagicNum[2]));
        
        if (isPPM) {
            NSLog(@"UNSUPPORTED TYPE ERROR: Binary PPM file found. \nPlease use PNG or JPEG.");
        }
        else if (isGIF) {
            NSLog(@"UNSUPPORTED TYPE ERROR: GIF file found. \nPlease use PNG or JPEG.");
        }
        else {
            NSLog(@"UNSUPPORTED TYPE ERROR.\nPlease use PNG or JPEG.");
        }
        
        return NULL;
    }
    return theImage;
}

/*
 void getPathAndFilename(const char * filename, NSString * pathToSaveTo, NSString * filenameWithoutExtension){
 NSString *path = [NSString stringWithUTF8String:filename];
 //NSFileManager *fileManager = [NSFileManager defaultManager];
 
 filenameWithoutExtension = [[path lastPathComponent] stringByDeletingPathExtension]; //[fileManager displayNameAtPath:path];
 pathToSaveTo = [[path stringByDeletingLastPathComponent] stringByAppendingString:@"/"];
 NSLog(@"%@", filenameWithoutExtension);
 NSLog(@"%@", pathToSaveTo);
 NSLog(@"%@", [path stringByExpandingTildeInPath]);
 }
 */

NSString * getPathAndFilename(const char * filename){
    NSString * path = [NSString stringWithUTF8String:filename];
    NSString * filenameWithoutExtension = [[path lastPathComponent] stringByDeletingPathExtension];
    NSString * pathToSaveTo = [path stringByDeletingLastPathComponent];
    if (outputDirectory != NULL) {
        pathToSaveTo = outputDirectory;                //swap out directory after filename get
    }
    pathToSaveTo = [pathToSaveTo stringByAppendingString:@"/"];
    
    return [pathToSaveTo stringByAppendingString:filenameWithoutExtension];
}

int parseOption(const char* argv[], int optionToParse) {
    int argumentCountUsed = 1;
    //NSLog(@"PARSING ARGUMENT \"%s\"", argv[optionToParse]);
    
    if(argv[optionToParse][2] != 0){
        NSLog(@"invalid option format for %s", argv[optionToParse]);
        return 1;
    }
    
    
    NSString * programName = [[NSString stringWithCString:argv[0] encoding:NSUTF8StringEncoding]  lastPathComponent];
    NSString * usageString = [NSString stringWithFormat:@"\n \
    USAGE: %@ [-i] [-p] [-h height] [-w width] [-o path] imageFile1 imageFile2...\n\
    -----------------------------------------------------------------------------------\n\
    -h height    height in pixels\n\
    -w width     width in pixels\n\
    -o outDir    directory to output to(not implemented yet)\n\
    -i           possibly interpolate\n\
    -n           make image a negative\n\
    -p           make ppm preview\n\
    -?           this help message" , programName];
    
    NSString * tentativeOutputDirectory = NULL; //I got an error when I declared it in the switch/case
    
    switch (argv[optionToParse][1]){
        case 'H':
        case 'h':
            outImageHeight = abs([[NSString stringWithCString:argv[optionToParse + 1] encoding:NSUTF8StringEncoding] intValue]);
            argumentCountUsed = 2;
        break;
        case 'I':
        case 'i':
            shouldInterpolate = YES;
            argumentCountUsed = 1;
        break;
        case 'N':  //Undocumented cause it's silly. lol.
        case 'n':
            shouldNegative = YES;
            argumentCountUsed = 1;
        break;
        case 'O':
        case 'o':
            tentativeOutputDirectory = [NSString stringWithCString:argv[optionToParse + 1] encoding:NSUTF8StringEncoding];
            if (argv[optionToParse + 1][0] == '~') {
                [tentativeOutputDirectory stringByExpandingTildeInPath];
            }
            outputDirectory = tentativeOutputDirectory;
            argumentCountUsed = 2;
        break;
        case 'M':  //It's officially P for (P)pm(P)review, but my stupid self will probably type an M
        case 'm':  // for (M)ake PPM preview
        case 'P':
        case 'p':
            makePPMPreview = YES;
        break;
        case 'W':
        case 'w':
            outImageWidth = abs([[NSString stringWithCString:argv[optionToParse + 1] encoding:NSUTF8StringEncoding] intValue]);
            argumentCountUsed = 2;
        break;
        default:
            NSLog(@"%@", usageString);
            argumentCountUsed = 1;
        break;
    }
    return argumentCountUsed;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Displaying command line parameters before anything else:");
        
        for (int i = 0; i < argc; ++i) {
            NSLog(@"%s", argv[i]);
        }
        
        NSLog(@"ARGC: %d", argc);
        
        
        if( argc < 2) return 1;
        NSLog(@"More than 1 arg passed in");
        //manipulateImagePixelData(getImageRefFromFile(argv[1]));
        for (int i = 1 ; i < argc ; ++i){
            NSLog(@"ARGV: %s", argv[i]);
            
            //If the first character is a - then we have an parameter for this argument
            if (argv[i][0] == '-'){
                int argumentsUsed = (parseOption(argv, i) - 1);
                i += argumentsUsed;
            }
            //not a parameter, hopefully an image, display current parameters here
            else {
                NSLog(@"Current parameters: \nHeight    = %u \nWidth     = %u \nInterpolt = %d \nMake PPM  = %d \nOutput    = %@", outImageHeight, outImageWidth, shouldInterpolate, makePPMPreview,  outputDirectory);
                
                NSString * saveLocationMinusExtension = getPathAndFilename(argv[i]);
                
                CGImageRef inImage = getImageRefFromFile(argv[i]);
                if (inImage) {
                    manipulateImagePixelData(inImage, saveLocationMinusExtension);
                }
                else {
                    NSLog(@"UH OH AN ERROR HAVE STARTED TO MOVE.");
                }
            }
            
        }
        
        
                // */
    }
    return 0;
}
