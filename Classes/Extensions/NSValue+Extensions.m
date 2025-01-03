/*
 NSValue+Extensions.m
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

#import "NSValue+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterfaceFoundation/AJRInterfaceFoundation-Swift.h>

typedef NS_ENUM(uint8_t, AJRValueType) {
    AJRValueTypeSize,
    AJRValueTypePoint,
    AJRValueTypeRect,
    AJRValueTypeRange,
    AJRValueTypeObjC,
};

@interface AJRValuePlaceHolder : NSObject <AJRXMLDecoding>

@property (nonatomic,assign) AJRValueType type;

@property (nonatomic,assign) NSSize size;
@property (nonatomic,assign) NSPoint point;
@property (nonatomic,assign) NSRect rect;
@property (nonatomic,assign) NSRange range;

@property (nonatomic,strong) NSString *objCType;
@property (nonatomic,assign) uint8_t *bytes;
@property (nonatomic,assign) NSUInteger length;

@end

@implementation NSValue (Extensions)

+ (id)valueWithBezierCurve:(AJRBezierCurve)curve {
   return [NSValue value:&curve withObjCType:@encode(AJRBezierCurve)];
}

- (AJRBezierCurve)bezierCurveValue {
   AJRBezierCurve curve;

   [self getValue:&curve];
   
   return curve;
}

+ (id)valueWithBezierRange:(AJRBezierRange)range {
   return [NSValue value:&range withObjCType:@encode(AJRBezierRange)];
}

- (AJRBezierRange)bezierRangeValue {
   AJRBezierRange range;

   [self getValue:&range];

   return range;
}

#pragma - mark AJRXMLCoding

+ (NSString *)ajr_nameForXMLArchiving {
    return @"value";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSValue class];
}

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRValuePlaceHolder alloc] init];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    const char *objCType = self.objCType;

    if (strncmp(objCType, "{CGSize=dd}", 11) == 0) {
        [coder encodeSize:self.sizeValue forKey:@"size"];
    } else if (strncmp(objCType, "{CGPoint=dd}", 11) == 0) {
        [coder encodePoint:self.pointValue forKey:@"point"];
    } else if (strncmp(objCType, "{CGRect={CGPoint=dd}{CGSize=dd}}", 11) == 0) {
        [coder encodeRect:self.rectValue forKey:@"rect"];
    } else if (strncmp(objCType, "{_NSRange=QQ}", 11) == 0) {
        [coder encodeRange:self.rangeValue forKey:@"range"];
    } else {
        NSUInteger length;
        NSUInteger alignment;
        uint8_t *bytes;

        NSGetSizeAndAlignment(self.objCType, &length, &alignment);
        bytes = (uint8_t *)calloc(length, sizeof(uint8_t));
        [self getValue:bytes size:length];

        [coder encodeCString:self.objCType forKey:@"objCType"];
        [coder encodeBytes:bytes length:length forKey:@"bytes"];

        free(bytes);
    }
}

@end

@implementation AJRValuePlaceHolder

- (void)dealloc {
    if (_bytes != NULL) {
        free(_bytes);
    }
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeSizeForKey:@"size" setter:^(CGSize size) {
        self->_type = AJRValueTypeSize;
        self->_size = size;
    }];
    [coder decodePointForKey:@"point" setter:^(CGPoint point) {
        self->_type = AJRValueTypePoint;
        self->_point = point;
    }];
    [coder decodeRectForKey:@"rect" setter:^(CGRect rect) {
        self->_type = AJRValueTypeRect;
        self->_rect = rect;
    }];
    [coder decodeRangeForKey:@"range" setter:^(NSRange range) {
        self->_type = AJRValueTypeRange;
        self->_range = range;
    }];
    [coder decodeStringForKey:@"objCType" setter:^(NSString *string) {
        self->_type = AJRValueTypeObjC;
        self->_objCType = string;
    }];
    [coder decodeBytesForKey:@"bytes" setter:^(uint8_t * _Nonnull bytes, NSUInteger length) {
        self->_type = AJRValueTypeObjC;
        self->_bytes = (uint8_t *)calloc(length, sizeof(uint8_t));
        memcpy(self->_bytes, bytes, length);
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable __autoreleasing *)error {
    NSValue *value = nil;

    switch (_type) {
        case AJRValueTypeSize:
            value = [NSValue valueWithSize:_size];
            break;
        case AJRValueTypePoint:
            value = [NSValue valueWithPoint:_point];
            break;
        case AJRValueTypeRect:
            value = [NSValue valueWithRect:_rect];
            break;
        case AJRValueTypeRange:
            value = [NSValue valueWithRange:_range];
            break;
        case AJRValueTypeObjC:
            if (_bytes != nil) {
                value = [NSValue valueWithBytes:_bytes objCType:[_objCType cStringUsingEncoding:NSUTF8StringEncoding]];
            }
    }

    return value;
}

@end
