
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
