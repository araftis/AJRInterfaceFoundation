/*
AJRXMLCoder+Extensions.m
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

#import "AJRXMLCoder+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRXMLCoder (Extensions)

- (void)encodePoint:(CGPoint)point forKey:(NSString *)key {
}

- (void)encodeSize:(CGSize)size forKey:(NSString *)key {
}

- (void)encodeRect:(CGRect)rect forKey:(NSString *)key {
}

- (void)decodePointForKey:(NSString *)key setter:(void (^)(CGPoint))setter {
}

- (void)decodeSizeForKey:(NSString *)key setter:(void (^)(CGSize))setter {
}

- (void)decodeRectForKey:(NSString *)key setter:(void (^)(CGRect))setter {
}

@end

@implementation AJRXMLArchiver (Extensions)

- (void)encodePoint:(CGPoint)point forKey:(NSString *)key {
    [self encodeGroupForKey:key usingBlock:^{
        [self encodeDouble:point.x forKey:@"x"];
        [self encodeDouble:point.y forKey:@"y"];
    }];
}

- (void)encodeSize:(CGSize)size forKey:(NSString *)key {
    [self encodeGroupForKey:key usingBlock:^{
        [self encodeDouble:size.width forKey:@"width"];
        [self encodeDouble:size.height forKey:@"height"];
    }];
}

- (void)encodeRect:(CGRect)rect forKey:(NSString *)key {
    [self encodeGroupForKey:key usingBlock:^{
        [self encodeDouble:rect.origin.x forKey:@"x"];
        [self encodeDouble:rect.origin.y forKey:@"y"];
        [self encodeDouble:rect.size.width forKey:@"width"];
        [self encodeDouble:rect.size.height forKey:@"height"];
    }];
}

@end


@implementation AJRXMLUnarchiver (AJRInterfaceExtensions)

- (void)decodePointForKey:(NSString *)key setter:(void (^)(CGPoint))setter {
    __block CGPoint point = NSZeroPoint;
    
    [self decodeGroupForKey:key usingBlock:^{
        [self decodeDoubleForKey:@"x" setter:^(double value) {
            point.x = value;
        }];
        [self decodeDoubleForKey:@"y" setter:^(double value) {
            point.y = value;
        }];
    } setter:^{
        setter(point);
    }];
}

- (void)decodeSizeForKey:(NSString *)key setter:(void (^)(CGSize))setter {
    __block CGSize size = NSZeroSize;
    
    [self decodeGroupForKey:key usingBlock:^{
        [self decodeDoubleForKey:@"width" setter:^(double value) { size.width = value; }];
        [self decodeDoubleForKey:@"height" setter:^(double value) { size.height = value; }];
    } setter:^{
        setter(size);
    }];
}

- (void)decodeRectForKey:(NSString *)key setter:(void (^)(CGRect))setter {
    __block CGRect rect = NSZeroRect;
    
    [self decodeGroupForKey:key usingBlock:^{
        [self decodeDoubleForKey:@"x" setter:^(double value) { rect.origin.x = value; }];
        [self decodeDoubleForKey:@"y" setter:^(double value) { rect.origin.y = value; }];
        [self decodeDoubleForKey:@"width" setter:^(double value) { rect.size.width = value; }];
        [self decodeDoubleForKey:@"height" setter:^(double value) { rect.size.height = value; }];
    } setter:^{
        setter(rect);
    }];
}

@end

