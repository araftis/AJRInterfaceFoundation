//
//  AJRColorUtilities.h
//  AJRInterfaceFoundation
//
//  Created by A.J. Raftis on 6/12/18.
//  Copyright © 2018 A.J. Raftis. All rights reserved.
//

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
