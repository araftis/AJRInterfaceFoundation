/*
 AJRBezierPath+AJRIntersection.m
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

#import "AJRBezierPath.h"

#import "AJRGeometry.h"
#import "AJRIntersection.h"
#import "NSValue+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>


@implementation NSArray (_AJRBezierPathExtensions)

- (AJRBezierRange)bezierRangeAtIndex:(NSUInteger)index {
    return [[self objectAtIndex:index] bezierRangeValue];
}

@end


@implementation NSMutableArray (_AJRBezierPathExtensions)

- (void)addBezierRange:(AJRBezierRange)range {
    [self addObject:[NSValue valueWithBezierRange:range]];
}

- (void)replaceBezierRangeAtIndex:(NSUInteger)index withRange:(AJRBezierRange)range {
    [self replaceObjectAtIndex:index withObject:[NSValue valueWithBezierRange:range]];
}

- (void)unionBezierRangeAtIndex:(NSUInteger)index withRange:(AJRBezierRange)newRange {
    AJRBezierRange    range;
    
    range = [self bezierRangeAtIndex:index];
    AJRInlineUnionBezierRanges(&range, newRange);
    [self replaceBezierRangeAtIndex:index withRange:range];
}

@end


@implementation AJRBezierPath (AJRIntersection)

- (NSArray *)intersectionsWithLine:(AJRLine)line error:(double)error {
    NSMutableArray *intersections;
    NSArray *subintersections;
    AJRIntersection *subintersection;
    NSInteger x, y;
    NSInteger coordinateIndex = 2;
    CGPoint moveTo = CGPointZero, currentPoint, lastPoint = CGPointZero, where;
    AJRBezierCurve curve;
    
    if (error == 0.0) {
        error = [self flatness];
    }
    
    intersections = [[NSMutableArray allocWithZone:nil] initWithCapacity:8];
    
    @autoreleasepool {
    
        for (x = 1; x < _elementCount; x++) {
            
            switch (_elements[x]) {
                    
                case AJRBezierPathElementSetBoundingBox:
                    break;
                    
                case AJRBezierPathElementMoveTo:
                    moveTo = _points[coordinateIndex];
                    coordinateIndex++;
                    lastPoint = moveTo;
                    break;
                    
                case AJRBezierPathElementLineTo:
                    currentPoint = _points[coordinateIndex];
                    coordinateIndex++;
                    subintersection = [AJRIntersection intersectionForLine:line withLine:(AJRLine){lastPoint, currentPoint}];
                    if (subintersection) {
                        where = [subintersection point];
                        [subintersection setSegment:x - 1];
                        [intersections addObject:subintersection];
                    }
                    lastPoint = currentPoint;
                    break;
                    
                case AJRBezierPathElementCurveTo:
                    curve.start = lastPoint;
                    curve.handle1 = _points[coordinateIndex + 0];
                    curve.handle2 = _points[coordinateIndex + 1];
                    curve.end = _points[coordinateIndex + 2];
                    coordinateIndex += 3;
                    subintersections = [AJRIntersection intersectionsForCurve:curve withLine:line error:error];
                    if (subintersections) {
                        for (y = 0; y < (const NSInteger)[subintersections count]; y++) {
                            subintersection = [subintersections objectAtIndex:y];
                            [subintersection setSegment:x - 1];
                            [intersections addObject:subintersection];
                        }
                    }
                    lastPoint = curve.end;
                    break;
                    
                case AJRBezierPathElementClose:
                    subintersection = [AJRIntersection intersectionForLine:line withLine:(AJRLine){lastPoint, moveTo}];
                    if (subintersection) {
                        [subintersection setSegment:x - 1];
                        [intersections addObject:subintersection];
                    }
                    lastPoint = moveTo;
                    break;
            }
        }
    
    }
    
    if (![intersections count]) {
        return nil;
    }
    
    return intersections;
}

- (BOOL)isRectangular {
    if (((_pointCount == 6) && (_elementCount == 4)) ||
        ((_pointCount == 6) && (_elementCount == 5))) {
        if ((_points[2].x == _points[3].x) &&
            (_points[3].y == _points[4].y) &&
            (_points[4].x == _points[5].x) &&
            (_points[5].y == _points[2].y)) {
            return YES;
        } else if ((_points[2].y == _points[3].y) &&
                   (_points[3].x == _points[4].x) &&
                   (_points[4].y == _points[5].y) &&
                   (_points[5].x == _points[2].x)) {
            return YES;
        }
        return NO;
    } else if (((_pointCount == 7) && (_elementCount == 5)) ||
               ((_pointCount == 7) && (_elementCount == 6))) {
        if ((_points[2].x == _points[3].x) &&
            (_points[3].y == _points[4].y) &&
            (_points[4].x == _points[5].x) &&
            (_points[5].y == _points[2].y) &&
            (_points[6].x == _points[2].x) &&
            (_points[6].y == _points[2].y)) {
            return YES;
        } else if ((_points[2].y == _points[3].y) &&
                   (_points[3].x == _points[4].x) &&
                   (_points[4].y == _points[5].y) &&
                   (_points[5].x == _points[2].x) &&
                   (_points[6].y == _points[2].y) &&
                   (_points[6].x == _points[2].x)) {
            return YES;
        }
        return NO;
    }
    
    return NO;
}

- (NSArray *)subrectanglesContainedInRect:(CGRect)proposedRect error:(CGFloat)error lineSweep:(NSLineSweepDirection)sweepDirection minimumSize:(CGFloat)minSize {
    return [NSArray array];
}

- (AJRBezierPath *)pathByUnioningWithPath:(id <AJRBezierPathProtocol>)path {
    return (AJRBezierPath *)AJRBezierPathByUnioningPaths(@[self, path]);
}

- (AJRBezierPath *)pathByIntersectingWithPath:(id <AJRBezierPathProtocol>)path {
    return (AJRBezierPath *)AJRBezierPathByIntersectingPaths(@[self, path]);
}

- (AJRBezierPath *)pathBySubtractingPath:(id <AJRBezierPathProtocol>)path {
    return (AJRBezierPath *)AJRBezierPathBySubtractingPaths(@[self, path]);
}

- (AJRBezierPath *)pathByExclusivelyIntersectingPath:(id <AJRBezierPathProtocol>)path {
    return (AJRBezierPath *)AJRBezierPathBySubtractingPaths(@[self, path]);
}

- (AJRBezierPath *)pathByNormalizingPath {
    return (AJRBezierPath *)AJRBezierPathByNormalizingPath(self);
}

- (NSArray<AJRBezierPath *> *)separateComponents {
    return (NSArray<AJRBezierPath *> *)AJRBezierPathGetSubcomponents(self);
}

@end

static id <AJRBezierPathProtocol> _AJRBezierPathUsingOperation(NSArray<id <AJRBezierPathProtocol>> *paths, CGPathRef (^block)(CGPathRef path1, CGPathRef _Nullable path2)) {
    if (paths.count == 0) {
        return nil;
    } else if (paths.count == 1) {
        // This happens when we're doing an operation on a single path, like when normalizing.
        CGPathRef intermediate = block(paths[0].CGPath, NULL);
        id <AJRBezierPathProtocol> result = [[paths[0] class] bezierPathWithCGPath:intermediate];
        CGPathRelease(intermediate);
        return result;
    } else {
        CGPathRef leftPath = CGPathRetain(paths[0].CGPath);
        Class finalClass = paths[0].class;

        for (NSInteger x = 1; x < paths.count; x++) {
            CGPathRef intermediate = block(leftPath, paths[x].CGPath);
            CGPathRelease(leftPath);
            leftPath = intermediate;
        }

        id <AJRBezierPathProtocol> result = [finalClass bezierPathWithCGPath:leftPath];
        CGPathRelease(leftPath);

        return result;
    }
}


id <AJRBezierPathProtocol> AJRBezierPathByUnioningPaths(NSArray<id <AJRBezierPathProtocol>> *paths) {
    if (paths.count) {
        NSWindingRule rule = paths[0].windingRule;
        return _AJRBezierPathUsingOperation(paths, ^CGPathRef(CGPathRef path1, CGPathRef path2) {
            return CGPathCreateCopyByUnioningPath(path1, path2, rule == AJRWindingRuleEvenOdd);
        });
    }
    return nil;
}

id <AJRBezierPathProtocol> AJRBezierPathByIntersectingPaths(NSArray<id <AJRBezierPathProtocol>> *paths) {
    if (paths.count) {
        NSWindingRule rule = paths[0].windingRule;
        return _AJRBezierPathUsingOperation(paths, ^CGPathRef(CGPathRef path1, CGPathRef path2) {
            return CGPathCreateCopyByIntersectingPath(path1, path2, rule == AJRWindingRuleEvenOdd);
        });
    }
    return nil;
}

id <AJRBezierPathProtocol> AJRBezierPathBySubtractingPaths(NSArray<id <AJRBezierPathProtocol>> *paths) {
    if (paths.count) {
        NSWindingRule rule = paths[0].windingRule;
        return _AJRBezierPathUsingOperation(paths, ^CGPathRef(CGPathRef path1, CGPathRef path2) {
            return CGPathCreateCopyBySubtractingPath(path1, path2, rule == AJRWindingRuleEvenOdd);
        });
    }
    return nil;
}

id <AJRBezierPathProtocol> AJRBezierPathBySymmetricDifferenceOfPaths(NSArray<id <AJRBezierPathProtocol>> *paths) {
    if (paths.count) {
        NSWindingRule rule = paths[0].windingRule;
        return _AJRBezierPathUsingOperation(paths, ^CGPathRef(CGPathRef path1, CGPathRef path2) {
            return CGPathCreateCopyBySymmetricDifferenceOfPath(path1, path2, rule == AJRWindingRuleEvenOdd);
        });
    }
    return nil;
}

id <AJRBezierPathProtocol> AJRBezierPathByNormalizingPath(id <AJRBezierPathProtocol> path) {
    return _AJRBezierPathUsingOperation(@[path], ^CGPathRef(CGPathRef path1, CGPathRef path2) {
        return CGPathCreateCopyByNormalizing(path1, path.windingRule == NSWindingRuleEvenOdd);
    });
    return nil;
}

NSArray *AJRBezierPathGetSubcomponents(id <AJRBezierPathProtocol> path) {
    NSMutableArray<AJRBezierPath *> *components = [NSMutableArray array];
    CFArrayRef subpaths = CGPathCreateSeparateComponents(path.CGPath, path.windingRule == NSWindingRuleEvenOdd);

    for (NSInteger x = 0; x < CFArrayGetCount(subpaths); x++) {
        [components addObject:[path.class bezierPathWithCGPath:CFArrayGetValueAtIndex(subpaths, x)]];
    }
    CFRelease(subpaths);

    return components;
}
