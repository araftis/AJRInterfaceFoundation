//
//  AJRXMLCoder+Extensions.m
//  AJRInterface
//
//  Created by A.J. Raftis on 6/18/14.
//
//

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

