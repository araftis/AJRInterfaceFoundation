/*
 AJRColorUtilitiesTests.m
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

#import <AJRInterfaceFoundation/AJRColorUtilities.h>

@interface AJRColorUtilitiesTest : XCTestCase

@end

@implementation AJRColorUtilitiesTest

static inline BOOL AJRFloatEqual(double a, double b) {
    return ((long long)(a * 100000.0) == (long long)(b * 100000.0));
}

- (void)_testString:(NSString *)input red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    CGColorRef color;
    
    color = AJRColorCreateFromHTMLString(input);
    XCTAssert(color != NULL);
    if (color) {
        XCTAssert(AJRFloatEqual(AJRColorGetRedComponent(color), red), @"input: %@, expected: %f, output: %f", input, red, AJRColorGetRedComponent(color));
        XCTAssert(AJRFloatEqual(AJRColorGetGreenComponent(color), green), @"input: %@, expected: %f, output: %f", input, green, AJRColorGetGreenComponent(color));
        XCTAssert(AJRFloatEqual(AJRColorGetBlueComponent(color), blue), @"input: %@, expected: %f, output: %f", input, blue, AJRColorGetBlueComponent(color));
        XCTAssert(AJRFloatEqual(AJRColorGetAlphaComponent(color), alpha), @"input: %@, expected: %f, output: %f", input, alpha, AJRColorGetAlphaComponent(color));
        CGColorRelease(color);
    }
    
}

- (void)_testString:(NSString *)input hue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha {
    CGColorRef color;
    
    color = AJRColorCreateFromHTMLString(input);
    XCTAssert(color != NULL);
    if (color) {
        XCTAssert(AJRFloatEqual(AJRColorGetHueComponent(color), hue), @"input: %@, expected: %f, output: %f", input, hue, AJRColorGetHueComponent(color));
        XCTAssert(AJRFloatEqual(AJRColorGetSaturationComponent(color), saturation), @"input: %@, expected: %f, output: %f", input, saturation, AJRColorGetSaturationComponent(color));
        XCTAssert(AJRFloatEqual(AJRColorGetBrightnessComponent(color), brightness), @"input: %@, expected: %f, output: %f", input, brightness, AJRColorGetBrightnessComponent(color));
        XCTAssert(AJRFloatEqual(AJRColorGetAlphaComponent(color), alpha), @"input: %@, expected: %f, output: %f", input, alpha, AJRColorGetAlphaComponent(color));
        CFRelease(color);
    }
    
}

- (void)testHTMLColors {
    [self _testString:@"#BCD" red:11.0/15.0 green:12.0/15.0 blue:13.0/15.0 alpha:1.0];
    [self _testString:@"#BCDE" red:11.0/15.0 green:12.0/15.0 blue:13.0/15.0 alpha:14.0/15.0];
    [self _testString:@"#BBCCDD" red:0xBB/255.0 green:0xCC/255.0 blue:0xDD/255.0 alpha:1.0];
    [self _testString:@"#BBCCDDEE" red:0xBB/255.0 green:0xCC/255.0 blue:0xDD/255.0 alpha:0xEE/255.0];
    [self _testString:@"#BBBCCCDDD" red:0xBBB/4095.0 green:0xCCC/4095.0 blue:0xDDD/4095.0 alpha:1.0];
    [self _testString:@"#BBBCCCDDDEEE" red:0xBBB/4095.0 green:0xCCC/4095.0 blue:0xDDD/4095.0 alpha:0xEEE/4095.0];
    [self _testString:@"rgb(100, 150, 200)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:1.0];
    [self _testString:@"rgb(100, 150, 200, 0.9)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:0.9];
    [self _testString:@"rgba(100, 150, 200)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:1.0];
    [self _testString:@"rgba(100, 150, 200, 0.9)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:0.9];
    [self _testString:@"rgb(100 150 200)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:1.0];
    [self _testString:@"rgb(100 150 200 / 0.9)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:0.9];
    [self _testString:@"rgba(100 150 200)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:1.0];
    [self _testString:@"rgba(100 150 200 0.9)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:0.9];
    [self _testString:@"hsl(0, 100%, 100%)" red:1.0 green:0.0 blue:0.0 alpha:1.0];
    [self _testString:@"hsl(60, 100%, 100%)" red:1.0 green:1.0 blue:0.0 alpha:1.0];
    [self _testString:@"hsl(120, 100%, 100%)" red:0.0 green:1.0 blue:0.0 alpha:1.0];
    [self _testString:@"hsl(180, 100%, 100%)" red:0.0 green:1.0 blue:1.0 alpha:1.0];
    [self _testString:@"hsl(240, 100%, 100%)" red:0.0 green:0.0 blue:1.0 alpha:1.0];
    [self _testString:@"hsl(300, 100%, 100%)" red:1.0 green:0.0 blue:1.0 alpha:1.0];
    [self _testString:@"hsl(360, 100%, 100%)" red:1.0 green:0.0 blue:0.0 alpha:1.0];
    [self _testString:@"hsl(420, 120%, 120%)" red:1.0 green:1.0 blue:0.0 alpha:1.0];
    [self _testString:@"hsl(480, -20%, -20%)" red:0.0 green:0.0 blue:0.0 alpha:1.0];
    [self _testString:@"hsl(120, 75%, 85%)" hue:120.0 / 360.0 saturation:0.75 brightness:0.85 alpha:1.0];
    [self _testString:@"hsl(120, 75%, 85%, 0.9)" hue:120.0 / 360.0 saturation:0.75 brightness:0.85 alpha:0.9];
    [self _testString:@"AliceBlue" red:0xF0 / 255.0 green:0xF8 / 255.0 blue:0xFF / 255.0 alpha:1.0];
    [self _testString:@"color(p3, 100, 150, 200)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:1.0];
    [self _testString:@"color(dci-p3, 100, 150, 200)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:1.0];
    [self _testString:@"color(rec2020, 100, 150, 200)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:1.0];
    [self _testString:@"gray(100, 90%)" red:100.0 / 255.0 green:100.0 / 255.0 blue:100 / 255.0 alpha:0.9];
    [self _testString:@"color()" red:0.0 green:0.0 blue:0.0 alpha:1.0];
    [self _testString:@"color(squid, 100, 150, 200, 0.9)" red:100.0 / 255.0 green:150.0 / 255.0 blue:200 / 255.0 alpha:0.9];
    [self _testString:@"rgb()" red:0.0 green:0.0 blue:0.0 alpha:1.0];
    [self _testString:@"gray()" red:0.0 green:0.0 blue:0.0 alpha:1.0];
    [self _testString:@"hsl()" red:0.0 green:0.0 blue:0.0 alpha:1.0];
    [self _testString:@"hsl(-60, 75%, 85%)" hue: 60.0 / 360.0 saturation:0.75 brightness:0.85 alpha:1.0];
    [self _testString:@"hsl(  0, 75%, 85%)" hue:  0.0 / 360.0 saturation:0.75 brightness:0.85 alpha:1.0];
    [self _testString:@"hsl( 60, 75%, 85%)" hue: 60.0 / 360.0 saturation:0.75 brightness:0.85 alpha:1.0];
    [self _testString:@"hsl(120, 75%, 85%)" hue:120.0 / 360.0 saturation:0.75 brightness:0.85 alpha:1.0];
    [self _testString:@"hsl(180, 75%, 85%)" hue:180.0 / 360.0 saturation:0.75 brightness:0.85 alpha:1.0];
    [self _testString:@"hsl(240, 75%, 85%)" hue:240.0 / 360.0 saturation:0.75 brightness:0.85 alpha:1.0];
    [self _testString:@"hsl(300, 75%, 85%)" hue:300.0 / 360.0 saturation:0.75 brightness:0.85 alpha:1.0];
    [self _testString:@"hsl(360, 75%, 85%)" hue:  0.0 / 360.0 saturation:0.75 brightness:0.85 alpha:1.0];
    [self _testString:@"hsl(420, 75%, 85%)" hue: 60.0 / 360.0 saturation:0.75 brightness:0.85 alpha:1.0];
}

- (void)testColorComponents {
    CGColorRef color = CGColorCreateGenericCMYK(1.0, 0.0, 0.0, 0.0, 1.0);
    
    XCTAssert(AJRFloatEqual(AJRColorGetRedComponent(color), 0.0), @"got: %f, expected:  %f", AJRColorGetRedComponent(color), 0.0);
    XCTAssert(AJRFloatEqual(AJRColorGetGreenComponent(color), 0.64053), @"got: %f, expected:  %f", AJRColorGetGreenComponent(color), 1.0);
    XCTAssert(AJRFloatEqual(AJRColorGetBlueComponent(color), 0.85589), @"got: %f, expected:  %f", AJRColorGetBlueComponent(color), 1.0);
    XCTAssert(AJRFloatEqual(AJRColorGetAlphaComponent(color), 1.0), @"got: %f, expected:  %f", AJRColorGetAlphaComponent(color), 0.0);
}

- (void)testHSBColors {
    CGColorRef color = AJRColorCreateFromHSB(60.0 / 360.0, 1.0, 1.0, 1.0);
    XCTAssert(AJRFloatEqual(AJRColorGetRedComponent(color), 1.0));
    XCTAssert(AJRFloatEqual(AJRColorGetGreenComponent(color), 1.0));
    XCTAssert(AJRFloatEqual(AJRColorGetBlueComponent(color), 0.0));
    XCTAssert(AJRFloatEqual(AJRColorGetAlphaComponent(color), 1.0));
    XCTAssert(AJRFloatEqual(AJRColorGetHueComponent(color), 60 / 360.0));
    XCTAssert(AJRFloatEqual(AJRColorGetSaturationComponent(color), 1.0));
    XCTAssert(AJRFloatEqual(AJRColorGetBrightnessComponent(color), 1.0));
    CGColorRelease(color);
}

@end
