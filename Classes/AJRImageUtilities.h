//
//  AJRImageUtilities.h
//  AJRInterfaceFoundation
//
//  Created by A.J. Raftis on 5/16/18.
//  Copyright © 2018 A.J. Raftis. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Generating Image Data

extern NSData * _Nullable AJRPNGDataFromCGImage(CGImageRef image, BOOL interlace);
extern NSData * _Nullable AJRJPEGDataFromCGImage(CGImageRef image, CGFloat compression);
extern NSData * _Nullable AJRGIFDataFromCGImage(CGImageRef image, BOOL ditherTransparency);
extern NSData * _Nullable AJRBMPDataFromCGImage(CGImageRef image);

#pragma mark - Creating Images

extern CGImageRef AJRCreateImage(CGSize size, CGFloat scale, BOOL flipped, CGColorSpaceRef _Nullable colorSpace, void (^commands)(CGContextRef context)) CF_RETURNS_RETAINED;
extern CGImageRef AJRCreateInverseMask(CGImageRef input) CF_RETURNS_RETAINED;

NS_ASSUME_NONNULL_END
