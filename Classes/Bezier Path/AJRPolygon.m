/*
 AJRPolygon.m
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

#import <AJRInterfaceFoundation/AJRPolygon.h>

#import <AJRInterfaceFoundation/AJRVertex.h>

@implementation AJRPolygon
{
	__strong AJRVertex **_contours;
	NSUInteger _contourCount;
	NSUInteger _maxContours;
}

- (id)init {
    if ((self = [super init])) {
        _maxContours = 10;
        _contourCount = 0;
        _contours = (__strong AJRVertex **)calloc(sizeof(AJRVertex *), _maxContours);
    }
    return self;
}

- (void)dealloc {
    free(_contours);
}

#pragma mark - Path Construction

- (void)moveToPoint:(CGPoint)point {
    if (_contourCount == _maxContours) {
        __strong AJRVertex **newContours;
        
        _maxContours += 10;
        newContours = (__strong AJRVertex **)calloc(sizeof(AJRVertex *), _maxContours);
        for (NSInteger x = 0; x < _contourCount; x++) {
            newContours[x] = _contours[x];
        }
        free(_contours);
        _contours = newContours;
    }
    
    _contours[_contourCount] = [AJRVertex vertexWithPoint:point];
    [_contours[_contourCount] setNext:_contours[_contourCount]];
    [_contours[_contourCount] setPrevious:_contours[_contourCount]];
    _contourCount++;
}

- (void)lineToPoint:(CGPoint)point {
    AJRVertex    *new = [AJRVertex vertexWithPoint:point];
    AJRVertex    *previous = [_contours[_contourCount - 1] previous];
    
    [new setPrevious:previous];
    [new setNext:[previous next]];
    [previous setNext:new];
}

- (void)curveToPoint:(CGPoint)point controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2 {
}

#pragma mark - Drawing

#define TRANSFORM(p) (_transform ? _transform(p) : p)

- (NSBezierPath *)path {
    NSBezierPath    *path = [[NSBezierPath alloc] init];
    
    for (NSInteger x = 0; x < _contourCount; x++) {
        AJRVertex    *first = _contours[x];
        AJRVertex    *current = first;
        BOOL        didSomething = NO;
        
        do {
            CGPoint    point = TRANSFORM([current point]);
            
            if (current == first) {
                [path moveToPoint:point];
            } else {
                [path lineToPoint:point];
                didSomething = YES;
            }
            current = [current next];
        } while (current != first);
        if (didSomething) {
            [path closePath];
        }
    }
    
    return path;
}

- (void)draw {
    NSBezierPath    *path = [self path];
    CGContextRef    context = [[NSGraphicsContext currentContext] CGContext];
    
    [_color set];
    
    CGContextSetAlpha(context, 0.10);
    CGContextBeginTransparencyLayer(context, NULL);
    [path fill];
    CGContextEndTransparencyLayer(context);
    
    CGContextSetAlpha(context, 1.0);
    [path stroke];
}

- (void)drawPoints {
    NSBezierPath    *path = [[NSBezierPath alloc] init];

    [_color set];
    
    for (NSInteger x = 0; x < _contourCount; x++) {
        AJRVertex    *first = _contours[x];
        AJRVertex    *current = first;
        
        do {
            CGPoint    point = [current point];
            
            [path removeAllPoints];
            [path appendBezierPathWithOvalInRect:NSInsetRect((CGRect){point, NSZeroSize}, -3.0, -3.0)];
            [path stroke];
            
            current = [current next];
        } while (current != first);
    }
}

#pragma mark - NSObject

- (NSString *)description {
    NSMutableString     *string = [[NSMutableString alloc] init];
    
    for (NSInteger x = 0; x < _contourCount; x++) {
        AJRVertex    *first = _contours[x];
        AJRVertex    *current = first;
        BOOL        didSomething = NO;
        
        do {
            CGPoint    point = [current point];
            
            if (current == first) {
                [string appendFormat:@"%.1f %.1f moveto\n", point.x, point.y];
            } else {
                [string appendFormat:@"%.1f %.1f lineto\n", point.x, point.y];
                didSomething = YES;
            }
            current = [current next];
        } while (current != first);
        if (didSomething) {
            [string appendFormat:@"closepath\n"];
        }
    }
    
    return string;
}

@end
