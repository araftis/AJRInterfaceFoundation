//
//  AJRImageUtilities.m
//  AJRInterfaceFoundation
//
//  Created by A.J. Raftis on 5/16/18.
//  Copyright © 2018 A.J. Raftis. All rights reserved.
//

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
