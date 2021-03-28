/*
AJRColorUtilities.m
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

#import "AJRColorUtilities.h"

#import <AJRFoundation/AJRFoundation.h>

#pragma mark - Color Spaces

CGColorSpaceRef AJRGetSRGBColorSpace(void) {
    static CGColorSpaceRef sRGBColorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sRGBColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    });
    return sRGBColorSpace;
}

CGColorSpaceRef AJRGetCMYKColorSpace(void) {
    static CGColorSpaceRef sRGBColorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sRGBColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericCMYK);
    });
    return sRGBColorSpace;
}

CGColorSpaceRef AJRGetGrayColorSpace(void) {
    static CGColorSpaceRef grayColorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        grayColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceLinearGray);
    });
    return grayColorSpace;
}

CGColorSpaceRef AJRGetP3ColorSpace(void) {
    static CGColorSpaceRef p3ColorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        p3ColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceDCIP3);
    });
    return p3ColorSpace;
}

CGColorSpaceRef AJRGetRec2020ColorSpace(void) {
    static CGColorSpaceRef rec2020ColorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rec2020ColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceITUR_2020);
    });
    return rec2020ColorSpace;
}

#pragma mark - Utilities

static NSString *_AJRHTMLColorForName(NSString *name) {
    /* To generate the below, visit https://www.w3schools.com/colors/colors_names.ajrp, copy the table, and then run:
         pbpaste | awk 'BEGIN { printf("    static NSDictionary *colors = nil;\n    static dispatch_once_t onceToken;\n    dispatch_once(&onceToken, ^{\n        colors = @{\n") } {printf("                   @\"%s\":@\"%s\",\n", $1, $2 ) } END { printf("                   };\n    });\n");}' | pbcopy
     From the command line.
    */
    static NSDictionary *colors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colors = @{
                   @"AliceBlue":@"#F0F8FF",
                   @"AntiqueWhite":@"#FAEBD7",
                   @"Aqua":@"#00FFFF",
                   @"Aquamarine":@"#7FFFD4",
                   @"Azure":@"#F0FFFF",
                   @"Beige":@"#F5F5DC",
                   @"Bisque":@"#FFE4C4",
                   @"Black":@"#000000",
                   @"BlanchedAlmond":@"#FFEBCD",
                   @"Blue":@"#0000FF",
                   @"BlueViolet":@"#8A2BE2",
                   @"Brown":@"#A52A2A",
                   @"BurlyWood":@"#DEB887",
                   @"CadetBlue":@"#5F9EA0",
                   @"Chartreuse":@"#7FFF00",
                   @"Chocolate":@"#D2691E",
                   @"Coral":@"#FF7F50",
                   @"CornflowerBlue":@"#6495ED",
                   @"Cornsilk":@"#FFF8DC",
                   @"Crimson":@"#DC143C",
                   @"Cyan":@"#00FFFF",
                   @"DarkBlue":@"#00008B",
                   @"DarkCyan":@"#008B8B",
                   @"DarkGoldenRod":@"#B8860B",
                   @"DarkGray":@"#A9A9A9",
                   @"DarkGrey":@"#A9A9A9",
                   @"DarkGreen":@"#006400",
                   @"DarkKhaki":@"#BDB76B",
                   @"DarkMagenta":@"#8B008B",
                   @"DarkOliveGreen":@"#556B2F",
                   @"DarkOrange":@"#FF8C00",
                   @"DarkOrchid":@"#9932CC",
                   @"DarkRed":@"#8B0000",
                   @"DarkSalmon":@"#E9967A",
                   @"DarkSeaGreen":@"#8FBC8F",
                   @"DarkSlateBlue":@"#483D8B",
                   @"DarkSlateGray":@"#2F4F4F",
                   @"DarkSlateGrey":@"#2F4F4F",
                   @"DarkTurquoise":@"#00CED1",
                   @"DarkViolet":@"#9400D3",
                   @"DeepPink":@"#FF1493",
                   @"DeepSkyBlue":@"#00BFFF",
                   @"DimGray":@"#696969",
                   @"DimGrey":@"#696969",
                   @"DodgerBlue":@"#1E90FF",
                   @"FireBrick":@"#B22222",
                   @"FloralWhite":@"#FFFAF0",
                   @"ForestGreen":@"#228B22",
                   @"Fuchsia":@"#FF00FF",
                   @"Gainsboro":@"#DCDCDC",
                   @"GhostWhite":@"#F8F8FF",
                   @"Gold":@"#FFD700",
                   @"GoldenRod":@"#DAA520",
                   @"Gray":@"#808080",
                   @"Grey":@"#808080",
                   @"Green":@"#008000",
                   @"GreenYellow":@"#ADFF2F",
                   @"HoneyDew":@"#F0FFF0",
                   @"HotPink":@"#FF69B4",
                   @"IndianRed":@"#CD5C5C",
                   @"Indigo":@"#4B0082",
                   @"Ivory":@"#FFFFF0",
                   @"Khaki":@"#F0E68C",
                   @"Lavender":@"#E6E6FA",
                   @"LavenderBlush":@"#FFF0F5",
                   @"LawnGreen":@"#7CFC00",
                   @"LemonChiffon":@"#FFFACD",
                   @"LightBlue":@"#ADD8E6",
                   @"LightCoral":@"#F08080",
                   @"LightCyan":@"#E0FFFF",
                   @"LightGoldenRodYellow":@"#FAFAD2",
                   @"LightGray":@"#D3D3D3",
                   @"LightGrey":@"#D3D3D3",
                   @"LightGreen":@"#90EE90",
                   @"LightPink":@"#FFB6C1",
                   @"LightSalmon":@"#FFA07A",
                   @"LightSeaGreen":@"#20B2AA",
                   @"LightSkyBlue":@"#87CEFA",
                   @"LightSlateGray":@"#778899",
                   @"LightSlateGrey":@"#778899",
                   @"LightSteelBlue":@"#B0C4DE",
                   @"LightYellow":@"#FFFFE0",
                   @"Lime":@"#00FF00",
                   @"LimeGreen":@"#32CD32",
                   @"Linen":@"#FAF0E6",
                   @"Magenta":@"#FF00FF",
                   @"Maroon":@"#800000",
                   @"MediumAquaMarine":@"#66CDAA",
                   @"MediumBlue":@"#0000CD",
                   @"MediumOrchid":@"#BA55D3",
                   @"MediumPurple":@"#9370DB",
                   @"MediumSeaGreen":@"#3CB371",
                   @"MediumSlateBlue":@"#7B68EE",
                   @"MediumSpringGreen":@"#00FA9A",
                   @"MediumTurquoise":@"#48D1CC",
                   @"MediumVioletRed":@"#C71585",
                   @"MidnightBlue":@"#191970",
                   @"MintCream":@"#F5FFFA",
                   @"MistyRose":@"#FFE4E1",
                   @"Moccasin":@"#FFE4B5",
                   @"NavajoWhite":@"#FFDEAD",
                   @"Navy":@"#000080",
                   @"OldLace":@"#FDF5E6",
                   @"Olive":@"#808000",
                   @"OliveDrab":@"#6B8E23",
                   @"Orange":@"#FFA500",
                   @"OrangeRed":@"#FF4500",
                   @"Orchid":@"#DA70D6",
                   @"PaleGoldenRod":@"#EEE8AA",
                   @"PaleGreen":@"#98FB98",
                   @"PaleTurquoise":@"#AFEEEE",
                   @"PaleVioletRed":@"#DB7093",
                   @"PapayaWhip":@"#FFEFD5",
                   @"PeachPuff":@"#FFDAB9",
                   @"Peru":@"#CD853F",
                   @"Pink":@"#FFC0CB",
                   @"Plum":@"#DDA0DD",
                   @"PowderBlue":@"#B0E0E6",
                   @"Purple":@"#800080",
                   @"RebeccaPurple":@"#663399",
                   @"Red":@"#FF0000",
                   @"RosyBrown":@"#BC8F8F",
                   @"RoyalBlue":@"#4169E1",
                   @"SaddleBrown":@"#8B4513",
                   @"Salmon":@"#FA8072",
                   @"SandyBrown":@"#F4A460",
                   @"SeaGreen":@"#2E8B57",
                   @"SeaShell":@"#FFF5EE",
                   @"Sienna":@"#A0522D",
                   @"Silver":@"#C0C0C0",
                   @"SkyBlue":@"#87CEEB",
                   @"SlateBlue":@"#6A5ACD",
                   @"SlateGray":@"#708090",
                   @"SlateGrey":@"#708090",
                   @"Snow":@"#FFFAFA",
                   @"SpringGreen":@"#00FF7F",
                   @"SteelBlue":@"#4682B4",
                   @"Tan":@"#D2B48C",
                   @"Teal":@"#008080",
                   @"Thistle":@"#D8BFD8",
                   @"Tomato":@"#FF6347",
                   @"Turquoise":@"#40E0D0",
                   @"Violet":@"#EE82EE",
                   @"Wheat":@"#F5DEB3",
                   @"White":@"#FFFFFF",
                   @"WhiteSmoke":@"#F5F5F5",
                   @"Yellow":@"#FFFF00",
                   @"YellowGreen":@"#9ACD32",
                   };
    });
    return [colors objectForKey:name];
}

static CGFloat _AJRHTMLColorComponentFromString(NSString *component, CGFloat maxValue) {
    CGFloat value = 1.0;
    if ([component hasSuffix:@"%"]) {
        value = [component floatValue] / 100.0;
    } else {
        value = [component floatValue] / maxValue;
    }
    return value;
}

static NSCharacterSet *_AJRGetHTMLParameterSeparatorSet(void) {
    static NSCharacterSet *characters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        characters = [NSCharacterSet characterSetWithCharactersInString:@" \t/,"];
    });
    return characters;
}

static NSArray<NSString *> *_AJRParseHTMLParameters(NSString *input) {
    NSCharacterSet *separatorCharacterSet = _AJRGetHTMLParameterSeparatorSet();
    NSMutableArray<NSString *> *parameters = [NSMutableArray array];
    NSScanner *scanner = [NSScanner scannerWithString:input];
    
    [scanner setCharactersToBeSkipped:nil];

    NSString *parameter;
    while ([scanner scanUpToCharactersFromSet:separatorCharacterSet intoString:&parameter]) {
        [parameters addObject:parameter];
        [scanner scanCharactersFromSet:separatorCharacterSet intoString:NULL];
    }
    
    return parameters;
}

static CGFloat _AJRGetComponentValueFromHexSubstring(NSString *htmlString, NSRange subrange) {
    return (CGFloat)strtol([[htmlString substringWithRange:subrange] UTF8String], NULL, 16);
}

extern void AJRHSBToRGB(CGFloat hueIn, CGFloat saturationIn, CGFloat brightnessIn, CGFloat *red, CGFloat *green, CGFloat *blue) {
    CGFloat hue = fmod(hueIn, 360.0);
    CGFloat saturation = saturationIn >= 0.0 ? (saturationIn <= 1.0 ? saturationIn : 1.0) : 0.0;
    CGFloat brightness = brightnessIn >= 0.0 ? (brightnessIn <= 1.0 ? brightnessIn : 1.0) : 0.0;
    CGFloat P, Q, T;
    CGFloat fract;
    
    // FYI, we don't have to worry about the 360.0 case, because we fmod above.
    hue /= 60.0;
    fract = hue - floor(hue);
    
    P = brightness * (1.0 - saturation);
    Q = brightness * (1.0 - saturation * fract);
    T = brightness * (1.0 - saturation * (1.0 - fract));
    
    if (0.0 <= hue && hue < 1.0) {
        *red = brightness;
        *green = T;
        *blue = P;
    } else if (1.0 <= hue && hue < 2.0) {
        *red = Q;
        *green = brightness;
        *blue = P;
    } else if (2.0 <= hue && hue < 3.0) {
        *red = P;
        *green = brightness;
        *blue = T;
    } else if (3.0 <= hue && hue < 4.0) {
        *red = P;
        *green = Q;
        *blue = brightness;
    } else if (4.0 <= hue && hue < 5.0) {
        *red = T;
        *green = P;
        *blue = brightness;
    } else if (5.0 <= hue && hue < 6.0) {
        *red = brightness;
        *green = P;
        *blue = Q;
    }
}

#define HUE_ANGLE 60.0
void AJRRGBToHSB(CGFloat rp, CGFloat gp, CGFloat bp, CGFloat *r_h, CGFloat *r_s, CGFloat *r_v) {
    CGFloat cmax, cmin, delta;
    NSInteger cmaxwhich, cminwhich;
    
    //debug ("rgb=%d,%d,%d rgbprime=%f,%f,%f", r, g, b, rp, gp, bp);
    
    cmax = rp;
    cmaxwhich = 0; /* faster comparison afterwards */
    if (gp > cmax) { cmax = gp; cmaxwhich = 1; }
    if (bp > cmax) { cmax = bp; cmaxwhich = 2; }
    cmin = rp;
    cminwhich = 0;
    if (gp < cmin) { cmin = gp; cminwhich = 1; }
    if (bp < cmin) { cmin = bp; cminwhich = 2; }
    
    //debug ("cmin=%f,cmax=%f", cmin, cmax);
    delta = cmax - cmin;
    
    /* HUE */
    if (delta == 0) {
        *r_h = 0;
    } else {
        switch (cmaxwhich) {
            case 0: /* cmax == rp */
                *r_h = HUE_ANGLE * (fmod ((gp - bp) / delta, 6));
                break;
                
            case 1: /* cmax == gp */
                *r_h = HUE_ANGLE * (((bp - rp) / delta) + 2);
                break;
                
            case 2: /* cmax == bp */
                *r_h = HUE_ANGLE * (((rp - gp) / delta) + 4);
                break;
        }
        if (*r_h < 0)
            *r_h += 360;
    }
    
    /* LIGHTNESS/VALUE */
    //l = (cmax + cmin) / 2;
    *r_v = cmax;
    
    /* SATURATION */
    /*if (delta == 0) {
     *r_s = 0;
     } else {
     *r_s = delta / (1 - fabs (1 - (2 * (l - 1))));
     }*/
    if (cmax == 0) {
        *r_s = 0;
    } else {
        *r_s = delta / cmax;
    }
}

#pragma mark - Color Creation

extern CGColorRef AJRColorCreateFromHSB(CGFloat hue, CGFloat saturation, CGFloat brightness, CGFloat alpha) {
    CGFloat components[4] = {0.0, 0.0, 0.0, alpha};
    AJRHSBToRGB(hue * 360.0, saturation, brightness, &components[0], &components[1], &components[2]);
    return CGColorCreate(AJRGetSRGBColorSpace(), components);
}

static _Nullable CGColorRef _AJRColorCreateFromHTMLHexString(NSString * _Nullable htmlInput) {
    CGColorRef color = NULL;
    
    if (htmlInput) {
        NSString *html = [htmlInput hasPrefix:@"#"] ? [htmlInput substringFromIndex:1] : htmlInput;
        CGFloat components[4] = { 0.0, 0.0, 0.0, 1.0 };

        if ([html length] == 3) {
            components[0] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){0, 1}) / 15.0;
            components[1] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){1, 1}) / 15.0;
            components[2] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){2, 1}) / 15.0;
        } else if ([html length] == 4) {
            components[0] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){0, 1}) / 15.0;
            components[1] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){1, 1}) / 15.0;
            components[2] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){2, 1}) / 15.0;
            components[3] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){3, 1}) / 15.0;
        } else if ([html length] == 6) {
            components[0] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){0, 2}) / 255.0;
            components[1] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){2, 2}) / 255.0;
            components[2] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){4, 2}) / 255.0;
        } else if ([html length] == 8) {
            components[0] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){0, 2}) / 255.0;
            components[1] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){2, 2}) / 255.0;
            components[2] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){4, 2}) / 255.0;
            components[3] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){6, 2}) / 255.0;
        } else if ([html length] == 9) {
            components[0] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){0, 3}) / 4095.0;
            components[1] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){3, 3}) / 4095.0;
            components[2] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){6, 3}) / 4095.0;
        } else if ([html length] == 12) {
            components[0] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){0, 3}) / 4095.0;
            components[1] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){3, 3}) / 4095.0;
            components[2] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){6, 3}) / 4095.0;
            components[3] = _AJRGetComponentValueFromHexSubstring(html, (NSRange){9, 3}) / 4095.0;
        }
        
        color = CGColorCreate(AJRGetSRGBColorSpace(), components);
    }
    
    return color;
}

static _Nullable CGColorRef _AJRColorCreateFromHTMLColorName(NSString *colorName) {
    CGColorRef color = NULL;
    NSString *rawColor = _AJRHTMLColorForName(colorName);
    
    if (rawColor) {
        color = _AJRColorCreateFromHTMLHexString(rawColor);
    }

    
    return color;
}

static CGColorRef _AJRColorCreateRGBColorFromArguments(NSArray<NSString *> *arguments) {
    CGFloat components[4];
    NSInteger argumentsCount = [arguments count];
    
    components[0] = argumentsCount >= 1 ? _AJRHTMLColorComponentFromString(arguments[0], 255.0) : 0.0;
    components[1] = argumentsCount >= 2 ? _AJRHTMLColorComponentFromString(arguments[1], 255.0) : 0.0;
    components[2] = argumentsCount >= 3 ? _AJRHTMLColorComponentFromString(arguments[2], 255.0) : 0.0;
    components[3] = argumentsCount >= 4 ? _AJRHTMLColorComponentFromString(arguments[3], 1.0) : 1.0;
    
    return CGColorCreate(AJRGetSRGBColorSpace(), components);
}

static CGColorRef _AJRColorCreateGrayColorFromArguments(NSArray<NSString *> *arguments) {
    CGFloat components[2];
    NSInteger argumentsCount = [arguments count];
    
    components[0] = argumentsCount >= 1 ? _AJRHTMLColorComponentFromString(arguments[0], 255.0) : 0.0;
    components[1] = argumentsCount >= 2 ? _AJRHTMLColorComponentFromString(arguments[1], 1.0) : 1.0;
    
    return CGColorCreate(AJRGetGrayColorSpace(), components);
}

static CGColorRef _AJRColorCreateHSBColorFromArguments(NSArray<NSString *> *arguments) {
    CGFloat hue, saturation, brightness;
    CGFloat components[4];
    NSInteger argumentsCount = [arguments count];
    
    hue        = argumentsCount >= 1 ? _AJRHTMLColorComponentFromString(arguments[0], 1.0) : 0.0;
    saturation = argumentsCount >= 2 ? _AJRHTMLColorComponentFromString(arguments[1], 1.0) : 0.0;
    brightness = argumentsCount >= 3 ? _AJRHTMLColorComponentFromString(arguments[2], 1.0) : 0.0;
    AJRHSBToRGB(hue, saturation, brightness, &components[0], &components[1], &components[2]);
    components[3] = argumentsCount >= 4 ? _AJRHTMLColorComponentFromString(arguments[3], 1.0) : 1.0;
    
    return CGColorCreate(AJRGetSRGBColorSpace(), components);
}

static CGColorRef _AJRColorCreateRGBColorWithColorSpaceFromArguments(NSArray<NSString *> *argumentsIn) {
    NSString *colorSpaceName = [argumentsIn firstObject];
    NSArray<NSString *> *arguments = [argumentsIn count] > 1 ? [argumentsIn subarrayWithRange:(NSRange){1, [argumentsIn count] - 1}] : @[];
    CGColorSpaceRef colorSpace = NULL;
    
    if ([colorSpaceName isEqualToString:@"p3"] || [colorSpaceName isEqualToString:@"dci-p3"]) {
        colorSpace = AJRGetP3ColorSpace();
    } else if ([colorSpaceName isEqualToString:@"rec2020"]) {
        colorSpace = AJRGetRec2020ColorSpace();
    } else {
        if (colorSpaceName) {
            AJRLogWarning(@"Unknown color-space: %@", colorSpaceName);
        }
        colorSpace = AJRGetSRGBColorSpace();
    }
    
    CGFloat components[4];
    NSInteger argumentsCount = [arguments count];
    
    components[0] = argumentsCount >= 1 ? _AJRHTMLColorComponentFromString(arguments[0], 255.0) : 0.0;
    components[1] = argumentsCount >= 2 ? _AJRHTMLColorComponentFromString(arguments[1], 255.0) : 0.0;
    components[2] = argumentsCount >= 3 ? _AJRHTMLColorComponentFromString(arguments[2], 255.0) : 0.0;
    components[3] = argumentsCount >= 4 ? _AJRHTMLColorComponentFromString(arguments[3], 1.0) : 1.0;

    return CGColorCreate(colorSpace, components);
}

CGColorRef AJRColorCreateFromHTMLString(NSString *string) {
    NSString *html = [[string lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; // Because this just makes the logic below easier.
    CGColorRef color = nil;
    
    if ([html hasPrefix:@"#"]) {
        color = _AJRColorCreateFromHTMLHexString(html);
    } else {
        NSRange range = [html rangeOfString:@"("];
        if (range.location != NSNotFound) {
            // We likely have a color function, so treat it as such.
            NSString *functionName = [html substringToIndex:range.location];
            NSRange argumentsRange = {NSMaxRange(range), [html length] - NSMaxRange(range)};
            NSRange close = [html rangeOfString:@")" options:0 range:argumentsRange];
            NSArray<NSString *> *arguments;
            if (close.location != NSNotFound) {
                argumentsRange.length = close.location - NSMaxRange(range);
                // Punt by ajrsuming the arguments are still present, but not terminated.
            }
            arguments = _AJRParseHTMLParameters([html substringWithRange:argumentsRange]);
            if ([functionName isEqualToString:@"rgb"] || [functionName isEqualToString:@"rgba"]) {
                color = _AJRColorCreateRGBColorFromArguments(arguments);
            } else if ([functionName isEqualToString:@"hsl"] || [functionName isEqualToString:@"hsla"]) {
                color = _AJRColorCreateHSBColorFromArguments(arguments);
            } else if ([functionName isEqualToString:@"gray"]) {
                color = _AJRColorCreateGrayColorFromArguments(arguments);
            } else if ([functionName isEqualToString:@"color"]) {
                color = _AJRColorCreateRGBColorWithColorSpaceFromArguments(arguments);
            }
        } else {
            color = _AJRColorCreateFromHTMLColorName(string);
        }
    }
    
    return color;
}

#pragma mark - Color Spaces

CGColorRef AJRColorCreateCopyByMatchingToColorSpaceNamed(CGColorRef color, CFStringRef colorSpaceName) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(colorSpaceName);
    CGColorRef returnColor = NULL;
    if (colorSpace) {
        returnColor = CGColorCreateCopyByMatchingToColorSpace(colorSpace, kCGRenderingIntentPerceptual, color, NULL);
        CGColorSpaceRelease(colorSpace);
    }
    return returnColor;
}

#pragma mark - Color Components

static CGFloat _AJRColorGetRGBComponentAtIndex(CGColorRef colorIn, NSUInteger index, BOOL ajrHSV) {
    NSCAssert(index >= 0 && index <= 3, @"index must be [0..3]");
    CGColorRef color = colorIn;
    // See if we need to convert the color space
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(color);
    if (CGColorSpaceGetModel(colorSpace) != kCGColorSpaceModelRGB) {
        color = CGColorCreateCopyByMatchingToColorSpace(AJRGetSRGBColorSpace(), kCGRenderingIntentDefault, colorIn, NULL);
    }
    
    if (ajrHSV) {
        const CGFloat *components = CGColorGetComponents(color);
        CGFloat hsbComponents[4] = { 0.0, 0.0, 0.0, components[3] };
        AJRRGBToHSB(components[0], components[1], components[2], &hsbComponents[0], &hsbComponents[1], &hsbComponents[2]);
        hsbComponents[0] /= 360.0;
        return hsbComponents[index];
    }
    
    return color ? CGColorGetComponents(color)[index] : 0.0;
}

CGFloat AJRColorGetRedComponent(CGColorRef color) {
    return _AJRColorGetRGBComponentAtIndex(color, 0, NO);
}

CGFloat AJRColorGetGreenComponent(CGColorRef color) {
    return _AJRColorGetRGBComponentAtIndex(color, 1, NO);
}

CGFloat AJRColorGetBlueComponent(CGColorRef color) {
    return _AJRColorGetRGBComponentAtIndex(color, 2, NO);
}

CGFloat AJRColorGetAlphaComponent(CGColorRef color) {
    return _AJRColorGetRGBComponentAtIndex(color, 3, NO);
}

CGFloat AJRColorGetHueComponent(CGColorRef color) {
    return _AJRColorGetRGBComponentAtIndex(color, 0, YES);
}

CGFloat AJRColorGetSaturationComponent(CGColorRef color) {
    return _AJRColorGetRGBComponentAtIndex(color, 1, YES);
}

CGFloat AJRColorGetBrightnessComponent(CGColorRef color) {
    return _AJRColorGetRGBComponentAtIndex(color, 2, YES);
}

#pragma mark - Creating Color

CGColorRef AJRCreateSRGBColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    CGFloat components[] = {red, green, blue, alpha};
    return CGColorCreate(AJRGetSRGBColorSpace(), components);
}

CGColorRef AJRCreateP3Color(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    CGFloat components[] = {red, green, blue, alpha};
    return CGColorCreate(AJRGetP3ColorSpace(), components);
}

CGColorRef AJRCreateLinearGrayColor(CGFloat white, CGFloat alpha) {
    CGFloat components[] = {white, alpha};
    return CGColorCreate(AJRGetGrayColorSpace(), components);
}

#pragma mark - Standard Colors

CGColorRef AJRColorBlack(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {0.0, 1.0};
        color = CGColorCreate(AJRGetGrayColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorBlue(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {0.055, 0.231, 0.961, 1.0};
        color = CGColorCreate(AJRGetSRGBColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorBrown(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {0.639, 0.482, 0.294, 1.0};
        color = CGColorCreate(AJRGetSRGBColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorCyan(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {0.463, 0.976, 0.992, 1.0};
        color = CGColorCreate(AJRGetSRGBColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorGreen(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {0.459, 0.957, 0.290, 1.0};
        color = CGColorCreate(AJRGetSRGBColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorMagenta(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {0.918, 0.341, 0.969, 1.0};
        color = CGColorCreate(AJRGetSRGBColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorOrange(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {0.941, 0.592, 0.216, 1.0};
        color = CGColorCreate(AJRGetSRGBColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorPurple(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {0.529, 0.180, 0.553, 1.0};
        color = CGColorCreate(AJRGetSRGBColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorRed(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {0.914, 0.251, 0.145, 1.0};
        color = CGColorCreate(AJRGetSRGBColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorYellow(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {1.0, 0.980, 0.325, 1.0};
        color = CGColorCreate(AJRGetSRGBColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorDarkGray(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {1.0 / 3.0, 1.0};
        color = CGColorCreate(AJRGetGrayColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorGray(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {0.5, 1.0};
        color = CGColorCreate(AJRGetGrayColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorLightGray(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {2.0 / 3.0, 1.0};
        color = CGColorCreate(AJRGetGrayColorSpace(), components);
    });
    return color;
}

CGColorRef AJRColorWhite(void) {
    static CGColorRef color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat components[] = {1.0, 1.0};
        color = CGColorCreate(AJRGetGrayColorSpace(), components);
    });
    return color;
}

#pragma mark - Gradients

CGGradientRef AJRGradientCreateWithColorsAndLocations(CGColorRef color, CGFloat location, ...) {
    CGGradientRef gradient = NULL;
    NSMutableArray *colors;
    CGFloat *locations;
    va_list ap;
    
    colors = [NSMutableArray array];
    
    va_start(ap, location);
    CGColorRef nextColor = color;
    while (nextColor) {
        [colors addObject:(__bridge id)AJRColorCreateCopyByMatchingToColorSpaceNamed(nextColor, kCGColorSpaceDCIP3)];
        nextColor = va_arg(ap, CGColorRef);
        va_arg(ap, CGFloat);
    }
    va_end(ap);
    
    if ([colors count]) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSInteger index = 0;
        
        locations = NSZoneCalloc(NULL, [colors count], sizeof(CGFloat));
        
        locations[index] = location;
        va_start(ap, location);
        for (index = 1; index < [colors count]; index++) {
            locations[index] = va_arg(ap, CGFloat);
        }
        
        gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
        
        CGColorSpaceRelease(colorSpace);
        NSZoneFree(NULL, locations);
    }
    
    return gradient;
}
