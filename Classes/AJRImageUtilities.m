/*
AJRImageUtilities.m
AJRInterfaceFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRInterfaceFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AJRImageUtilities.h"

#import "AJRColorUtilities.h"
#import "AJRGraphicsUtilities.h"

#pragma mark - Generating Image Data

NSData *AJRPNGDataFromCGImage(CGImageRef image, BOOL interlace) {
    NSMutableData *result = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)result, kUTTypePNG, 1, NULL);
    if (destination) {
        CGImageDestinationAddImage(destination, image, (__bridge CFDictionaryRef)@{(__bridge NSString *)kCGImagePropertyPNGInterlaceType:@(YES)});
        if (!CGImageDestinationFinalize(destination)) {
            result = nil;
        }
        CFRelease(destination);
    }
    return result;
}

NSData *AJRJPEGDataFromCGImage(CGImageRef image, CGFloat compression) {
    NSMutableData *result = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)result, kUTTypeJPEG, 1, NULL);
    if (destination) {
        CGImageDestinationAddImage(destination, image, (__bridge CFDictionaryRef)@{(__bridge NSString *)kCGImageDestinationLossyCompressionQuality:@(compression)});
        if (!CGImageDestinationFinalize(destination)) {
            result = nil;
        }
        CFRelease(destination);
    }
    return result;
}

NSData * _Nullable AJRGIFDataFromCGImage(CGImageRef image, BOOL ditherTransparency) {
    NSMutableData *result = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)result, kUTTypeGIF, 1, NULL);
    if (destination) {
        CGImageDestinationAddImage(destination, image, (__bridge CFDictionaryRef)@{(__bridge NSString *)kCGImagePropertyHasAlpha:@(ditherTransparency)});
        if (!CGImageDestinationFinalize(destination)) {
            result = nil;
        }
        CFRelease(destination);
    }
    return result;
}

NSData * _Nullable AJRBMPDataFromCGImage(CGImageRef image) {
    NSMutableData *result = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)result, kUTTypeBMP, 1, NULL);
    if (destination) {
        CGImageDestinationAddImage(destination, image, NULL);
        if (!CGImageDestinationFinalize(destination)) {
            result = nil;
        }
        CFRelease(destination);
    }
    return result;
}

#pragma mark - Creating Images

extern void CGContextSetBaseCTM(CGContextRef context, CGAffineTransform transform);

CGImageRef AJRCreateImage(CGSize size, CGFloat scale, BOOL flipped, CGColorSpaceRef _Nullable colorSpaceIn, void (^commands)(CGContextRef context)) CF_RETURNS_RETAINED {
    CGImageRef  image = NULL;
    NSUInteger pixelsWide = size.width * scale;
    NSUInteger pixelsHigh = size.height * scale;
    CGColorSpaceRef colorSpace = colorSpaceIn ? CGColorSpaceRetain(colorSpaceIn) : CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    CGContextRef context = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, 0, colorSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    
    // Scale and flip if needed
    CGContextScaleCTM(context, pixelsWide / size.width, pixelsHigh / size.height);
    if (flipped) {
        CGContextTranslateCTM(context, 0.0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
    }
    
    AJRDrawWithSavedGraphicsState(context, ^(CGContextRef context) {
        CGContextSetBaseCTM(context, CGContextGetCTM(context));
        commands(context);
    });
    
    image = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return image;
}

CGImageRef AJRCreateInverseMask(CGImageRef input) CF_RETURNS_RETAINED {
    CGRect rect = (CGRect){CGPointZero, {CGImageGetWidth(input), CGImageGetHeight(input)}};
    return AJRCreateImage(rect.size,
                          1.0,
                          NO,
                          NULL, ^(CGContextRef context) {
                              CGContextSetFillColorWithColor(context, AJRColorWhite());
                              CGContextFillRect(context, rect);
                              CGContextClipToMask(context, rect, input);
                              CGContextClearRect(context, rect);
                          });
}
