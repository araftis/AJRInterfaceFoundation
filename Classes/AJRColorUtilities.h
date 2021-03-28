/*
AJRColorUtilities.h
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
* Neither the name of AJRFoundation nor the names of its contributors may be 
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

#ifndef AJRColorUtilities_h
#define AJRColorUtilities_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 Converts HSV to RGB.

 @param hue Color's hue from 0-360. Will be clamped if out of range.
 @param saturation Color's saturation in range of 0-1.
 @param brightness Color's brightness in range of 0-1.
 @param red The returned red component, in the range of 0-1.
 @param green The returned blue component, in the range of 0-1.
 @param blue The returned green component, in the range of 0-1.
*/
extern void AJRHSBToRGB(CGFloat hue, CGFloat saturation, CGFloat brightness, CGFloat *red, CGFloat *green, CGFloat *blue);
extern void AJRRGBToHSB(CGFloat rp, CGFloat gp, CGFloat bp, CGFloat *r_h, CGFloat *r_s, CGFloat *r_v);

/*!
 Create and return a color in the sRGB colorspace. Note that while HSB colors are often expressed with the hue being in terms of 0.0 - 360.0, Apple's specifies it as 0.0-1.0, so this functions follows that convention. Note that larger or smaller values are clamped to between 0..1. 
 */
extern CGColorRef AJRColorCreateFromHSB(CGFloat hue, CGFloat saturation, CGFloat brightness, CGFloat alpha);

/*! Parses the string as HTML and produces a CGColorRef, usually in the sRGB colorspace. */
extern _Nullable CGColorRef AJRColorCreateFromHTMLString(NSString *string);

#pragma mark - Color Spaces

extern CGColorSpaceRef AJRGetSRGBColorSpace(void) CF_RETURNS_NOT_RETAINED;
extern CGColorSpaceRef AJRGetCMYKColorSpace(void) CF_RETURNS_NOT_RETAINED;
extern CGColorSpaceRef AJRGetGrayColorSpace(void) CF_RETURNS_NOT_RETAINED;
extern CGColorSpaceRef AJRGetP3ColorSpace(void) CF_RETURNS_NOT_RETAINED;
extern CGColorSpaceRef AJRGetRec2020ColorSpace(void) CF_RETURNS_NOT_RETAINED;

extern CGColorRef __nullable AJRColorCreateCopyByMatchingToColorSpaceNamed(CGColorRef color, CFStringRef colorSpaceName);

#pragma mark - Color Components

extern CGFloat AJRColorGetRedComponent(CGColorRef color);
extern CGFloat AJRColorGetGreenComponent(CGColorRef color);
extern CGFloat AJRColorGetBlueComponent(CGColorRef color);
extern CGFloat AJRColorGetAlphaComponent(CGColorRef color);

extern CGFloat AJRColorGetHueComponent(CGColorRef color);
extern CGFloat AJRColorGetSaturationComponent(CGColorRef color);
extern CGFloat AJRColorGetBrightnessComponent(CGColorRef color);

#pragma mark - Creating Color

extern CGColorRef AJRCreateSRGBColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRCreateP3Color(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRCreateLinearGrayColor(CGFloat white, CGFloat alpha) CF_RETURNS_NOT_RETAINED;

#pragma mark - Standard Colors

extern CGColorRef AJRColorBlack(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorBlue(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorBrown(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorCyan(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorGreen(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorMagenta(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorOrange(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorPurple(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorRed(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorYellow(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorGray(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorDarkGray(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorLightGray(void) CF_RETURNS_NOT_RETAINED;
extern CGColorRef AJRColorWhite(void) CF_RETURNS_NOT_RETAINED;

#pragma mark - Gradients

extern CGGradientRef AJRGradientCreateWithColorsAndLocations(CGColorRef color, CGFloat location, ...);

NS_ASSUME_NONNULL_END

#endif /* AJRColorUtilities_h */
