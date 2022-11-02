/*
 AJRImageUtilitiesTests.m
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

#import <XCTest/XCTest.h>
#import <AJRInterfaceFoundation/AJRInterfaceFoundation.h>
#import <AJRFoundation/AJRFoundation.h>

@interface AJRImageUtilitiesTests : XCTestCase

@end

@implementation AJRImageUtilitiesTests

- (void)assertData:(NSData *)data isType:(NSString *)type {
    XCTAssert(data);
    CGImageSourceRef verifier = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    XCTAssert(verifier != nil);
    if (verifier) {
        XCTAssert([(__bridge NSString *)CGImageSourceGetType(verifier) isEqualToString:type], @"type was: %@, expected: %@", CGImageSourceGetType(verifier), type);
        CFRelease(verifier);
    }
}

- (void)testImageCreation {
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:@"/System/Library/Frameworks//SecurityInterface.framework/Versions/A/Resources/Lock_Open Anim 02.png"], NULL);
    
    XCTAssert(imageSource != nil);
    if (imageSource) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
        XCTAssert(image);
        if (image) {
            [self assertData:AJRBMPDataFromCGImage(image) isType:@"com.microsoft.bmp"];
            [self assertData:AJRPNGDataFromCGImage(image, NO) isType:@"public.png"];
            [self assertData:AJRJPEGDataFromCGImage(image, 0.8) isType:@"public.jpeg"];
            [self assertData:AJRGIFDataFromCGImage(image, YES) isType:@"com.compuserve.gif"];

            CGImageRelease(image);
        }
        CFRelease(imageSource);
    }
}

@end
