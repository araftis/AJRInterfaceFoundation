/*
 AJRImageUtilities.m
 AJRInterfaceFoundation

 Copyright © 2022, AJ Raftis and AJRInterfaceFoundation authors
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

#import <ImageIO/ImageIO.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#pragma mark - Generating Image Data

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
        // This may seem strange, but without this, shadows in flipped image contexts will not render correctly. If the fact that we're using private API becomes an issue with the App Store, we could probably work around this by rendering the image in non-flipped space and then flipping the resulting image when done. This would cause a slight performance hit for flipped images, but would avoid using private API.
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
