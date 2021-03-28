/*
AJRBezierPath+AJRIntersection.m
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
/*%*%*%*%*
 Copyright (C) 1995-2004 A. J. Raftis
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 Or, contact the author,
 
 A. J. Raftis
 359 Melanie Lane
 Nipomo, CA 93444
 alex@raftis.net
 
 *%*%*%*%*/

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

- (id)pathByUnioningWithPath:(id)path {
    return path;
}

- (id)pathByIntersectingWithPath:(id)path {
    return path;
}

- (id)pathBySubtractingPath:(id)path {
    return path;
}

- (id)pathByExclusivelyIntersectingPath:(id)path {
    return path;
}

@end
