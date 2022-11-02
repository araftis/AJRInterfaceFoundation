/*
 AJRInset.m
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

#import "AJRInset.h"

#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSDictionary+Extensions.h>

AJRInset AJRInsetZero = (AJRInset){0, 0, 0, 0};

static NSNumberFormatter *AJRInsetNumberFormatter(void) {
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:@"0.#####"];
        [formatter setNegativeFormat:@"-0.#####"];
    });
    return formatter;
}

NSString *AJRStringFromInset(AJRInset inset) {
    NSNumberFormatter *formatter = AJRInsetNumberFormatter();
    return AJRFormat(@"{%@, %@, %@, %@}", [formatter stringFromNumber:@(inset.top)], [formatter stringFromNumber:@(inset.left)], [formatter stringFromNumber:@(inset.bottom)], [formatter stringFromNumber:@(inset.right)]);
}

AJRInset AJRInsetFromString(NSString *insetString) {
    AJRInset inset = AJRInsetZero;
    NSScanner *scanner = [[NSScanner alloc] initWithString:insetString];
    CGFloat value;
    
    if (![scanner scanString:@"{" intoString:NULL]) return AJRInsetZero;
    if (![scanner scanDouble:&value]) return AJRInsetZero;
    inset.top = value;
    if (![scanner scanString:@"," intoString:NULL]) return AJRInsetZero;
    if (![scanner scanDouble:&value]) return AJRInsetZero;
    inset.left = value;
    if (![scanner scanString:@"," intoString:NULL]) return AJRInsetZero;
    if (![scanner scanDouble:&value]) return AJRInsetZero;
    inset.bottom = value;
    if (![scanner scanString:@"," intoString:NULL]) return AJRInsetZero;
    if (![scanner scanDouble:&value]) return AJRInsetZero;
    inset.right = value;

    return inset;
}

NSDictionary *AJRDictionaryFromInset(AJRInset inset) {
    return @{@"top":@(inset.top),
             @"left":@(inset.left),
             @"bottom":@(inset.bottom),
             @"right":@(inset.right),
             };
}

AJRInset AJRInsetFromDictionary(NSDictionary *insetDictionary) {
    AJRInset inset = AJRInsetZero;
    
    inset.top = [insetDictionary doubleForKey:@"top" defaultValue:0.0];
    inset.left = [insetDictionary doubleForKey:@"left" defaultValue:0.0];
    inset.bottom = [insetDictionary doubleForKey:@"bottom" defaultValue:0.0];
    inset.right = [insetDictionary doubleForKey:@"right" defaultValue:0.0];
    
    return inset;
}

BOOL AJRInsetEqual(AJRInset left, AJRInset right) {
    return (left.top == right.top
            && left.right == right.right
            && left.bottom == right.bottom
            && left.left == right.left);
}

@implementation NSDictionary (AJRInset)

- (AJRInset)insetForKey:(NSString *)key defaultValue:(AJRInset)defaultInset {
    NSString *raw = AJRObjectIfKindOfClass([self objectForKey:key], NSString);
    AJRInset inset = defaultInset;
    if (raw) {
        inset = AJRInsetFromString(raw);
    }
    return inset;
}

@end

@implementation NSMutableDictionary (AJRInset)

- (void)setInset:(AJRInset)inset forKey:(NSString *)key {
    [self setObject:AJRStringFromInset(inset) forKey:key];
}

@end

@implementation NSUserDefaults (AJRInset)

- (void)setInset:(AJRInset)inset forKey:(NSString *)key {
    [self setObject:AJRStringFromInset(inset) forKey:key];
}

- (AJRInset)insetForKey:(NSString *)key defaultValue:(AJRInset)defaultInset {
    NSString *raw = [self stringForKey:key];
    AJRInset inset = defaultInset;
    if (raw) {
        inset = AJRInsetFromString(raw);
    }
    return inset;
}

@end

@implementation NSCoder (AJRInset)

- (void)encodeInset:(AJRInset)inset forKey:(NSString *)key {
    [self encodeObject:AJRDictionaryFromInset(inset) forKey:key];
}

- (AJRInset)decodeInsetForKey:(NSString *)key {
    return AJRInsetFromDictionary([self decodeObjectForKey:key]);
}

@end
