/*
AJRBezierPath+AJRExtensions.m
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

#import "AJRBezierPathP.h"

#import "AJRBezierPathFunctions.h"
#import "AJRIntersection.h"
#import "AJRPathEnumerator.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRBezierPath (AJRExtensions)

- (id)initWithRect:(CGRect)aRect {
    if ((self = [self init])) {
        [self appendBezierPathWithRect:aRect];
    }
    return self;
}

- (instancetype)initWithPolygonInRect:(CGRect)rect sides:(NSInteger)sides starPercent:(CGFloat)starPercent offset:(CGFloat)offset {
    if ((self = [self init])) {
        [self appendBezierPathWithPolygonInRect:rect sides:sides starPercent:starPercent offset:offset];
    }
    return self;
}

+ (instancetype)bezierPathWithPolygonInRect:(CGRect)rect sides:(NSInteger)sides starPercent:(CGFloat)starPercent offset:(CGFloat)offset NS_SWIFT_NAME(bezierPathWithPolygon(in:sides:starPercent:offset:)) {
    AJRBezierPath *path = [[self alloc] init];
    [path appendBezierPathWithPolygonInRect:rect sides:sides starPercent:starPercent offset:offset];
    return path;
}

- (void)setStrokePointTransform:(AJRBezierPathPointTransform)strokeTransform {
    _strokePointTransform = [strokeTransform copy];
}

- (AJRBezierPathPointTransform)strokePointTransform {
    return _strokePointTransform;
}

- (void)setFillPointTransform:(AJRBezierPathPointTransform)fillTransform {
    _fillPointTransform = [fillTransform copy];
}

- (AJRBezierPathPointTransform)fillPointTransform {
    return _fillPointTransform;
}

- (void)_clockwiseArcBoundedByRect:(CGRect)arcBounds
                        startAngle:(CGFloat)startAngle
                          endAngle:(CGFloat)endAngle {
    AJRBezierCurve bezier;
    NSInteger wedgeCount;
    CGFloat workEndAngle;
    CGFloat angle;
    BOOL first = YES;
    NSInteger offset = 0;
    
    if ([self isClosed]) {
        offset = -1;
        _moveToOffset = _elementToPointIndex[_elementCount - 1];
    }
    
    if (endAngle > startAngle) {
        workEndAngle = endAngle - 360.0;
    } else {
        workEndAngle = endAngle;
    }
    angle = ceil(startAngle / 90.0) * 90.0;
    wedgeCount = (angle - startAngle) > 0.0 ? 1 : 0;
    while (angle > workEndAngle) {
        wedgeCount++;
        angle -= 90.0;
    }
    
    [self _increaseCoordinateCountBy:1 + (3 * wedgeCount)];
    [self _increaseOperationCountBy:1 + wedgeCount];
    
    angle = ceil(startAngle / 90.0) * 90.0;
    while (angle > workEndAngle - 90.0) {
        
        if (startAngle == angle) {
            angle -= 90.0;
            continue;
        }
        
        if (first && (angle != startAngle)) {
            if (angle > workEndAngle) {
                bezier = AJRBezierFromArc(arcBounds, startAngle, angle);
            } else {
                bezier = AJRBezierFromArc(arcBounds, startAngle, workEndAngle);
            }
        } else {
            if (angle > workEndAngle) {
                bezier = AJRBezierFromArc(arcBounds, angle + 90.0, angle);
            } else {
                bezier = AJRBezierFromArc(arcBounds, angle + 90.0, workEndAngle);
            }
        }
        
        if (first) {
            _elements[_elementCount + offset] = AJRBezierPathElementLineTo;
            _elementToPointIndex[_elementCount + offset] = _pointCount;
            _points[_pointCount] = bezier.start;
            [self _intersectPointWithBounds:bezier.start forMoveTo:NO];
            _elementCount++;
            _pointCount++;
        }
        
        first = NO;
        
        _elements[_elementCount + offset] = AJRBezierPathElementCurveTo;
        _elementToPointIndex[_elementCount + offset] = _pointCount;
        
        _points[_pointCount + 0] = bezier.handle1;
        [self _intersectPointWithBounds:bezier.handle1 forMoveTo:NO];
        _points[_pointCount + 1] = bezier.handle2;
        [self _intersectPointWithBounds:bezier.handle2 forMoveTo:NO];
        _points[_pointCount + 2] = bezier.end;
        [self _intersectPointWithBounds:bezier.end forMoveTo:NO];
        
        _elementCount++;
        _pointCount += 3;
        
        angle -= 90.0;
    }
    
    if (offset) {
        _elements[_elementCount - 1] = AJRBezierPathElementClose;
        _elementToPointIndex[_elementCount - 1] = _moveToOffset;
    }
    
    [self setBoundsAreValid:NO];
}

- (void)_counterclockwiseArcBoundedByRect:(CGRect)arcBounds
                               startAngle:(CGFloat)startAngle
                                 endAngle:(CGFloat)endAngle {
    AJRBezierCurve bezier;
    NSInteger wedgeCount;
    CGFloat workEndAngle;
    CGFloat angle;
    BOOL first = YES;
    NSInteger offset = 0;
    
    if ([self isClosed]) {
        offset = -1;
        _moveToOffset = _elementToPointIndex[_elementCount - 1];
    }
    
    if (endAngle < startAngle) {
        workEndAngle = endAngle + 360.0;
    } else {
        workEndAngle = endAngle;
    }
    angle = ceil(startAngle / 90.0) * 90.0;
    wedgeCount = (angle - startAngle) > 0.0 ? 1 : 0;
    while (angle < workEndAngle) {
        wedgeCount++;
        angle += 90.0;
    }
    
    [self _increaseCoordinateCountBy:1 + (3 * wedgeCount)];
    [self _increaseOperationCountBy:1 + wedgeCount];
    
    angle = ceil(startAngle / 90.0) * 90.0;
    while (angle < workEndAngle + 90.0) {
        
        if (startAngle == angle) {
            angle += 90.0;
            continue;
        }
        
        if (first && (angle != startAngle)) {
            if (angle < workEndAngle) {
                bezier = AJRBezierFromArc(arcBounds, startAngle, angle);
            } else {
                bezier = AJRBezierFromArc(arcBounds, startAngle, workEndAngle);
            }
        } else {
            if (angle < workEndAngle) {
                bezier = AJRBezierFromArc(arcBounds, angle - 90.0, angle);
            } else {
                bezier = AJRBezierFromArc(arcBounds, angle - 90.0, workEndAngle);
            }
        }
        
        if (first) {
            _elements[_elementCount + offset] = AJRBezierPathElementLineTo;
            _elementToPointIndex[_elementCount + offset] = _pointCount;
            _points[_pointCount] = bezier.start;
            [self _intersectPointWithBounds:bezier.start forMoveTo:NO];
            _elementCount++;
            _pointCount++;
        }
        
        first = NO;
        
        _elements[_elementCount + offset] = AJRBezierPathElementCurveTo;
        _elementToPointIndex[_elementCount + offset] = _pointCount;
        
        _points[_pointCount + 0] = bezier.handle1;
        [self _intersectPointWithBounds:bezier.handle1 forMoveTo:NO];
        _points[_pointCount + 1] = bezier.handle2;
        [self _intersectPointWithBounds:bezier.handle2 forMoveTo:NO];
        _points[_pointCount + 2] = bezier.end;
        [self _intersectPointWithBounds:bezier.end forMoveTo:NO];
        
        _elementCount++;
        _pointCount += 3;
        
        angle += 90.0;
    }
    
    if (offset) {
        _elements[_elementCount - 1] = AJRBezierPathElementClose;
        _elementToPointIndex[_elementCount - 1] = _moveToOffset;
    }
    
    [self setBoundsAreValid:NO];
}

- (void)appendBezierPathWithArcBoundedByRect:(CGRect)arcBounds
                                  startAngle:(CGFloat)startAngle
                                    endAngle:(CGFloat)endAngle
                                   clockwise:(BOOL)flag {
    if (flag) {
        [self _clockwiseArcBoundedByRect:arcBounds
                              startAngle:startAngle
                                endAngle:endAngle];
    } else {
        [self _counterclockwiseArcBoundedByRect:arcBounds
                                     startAngle:startAngle
                                       endAngle:endAngle];
    }
}

- (void)lineToAngle:(CGFloat)degree length:(CGFloat)length {
    CGPoint        current = [self currentPoint];
    
    [self lineToPoint:(CGPoint){current.x + (AJRCos(degree) * length), current.y + (AJRSin(degree) * length)}];
    
    [self setBoundsAreValid:NO];
}

- (double)_lastSegmentAngle {
    if ([self lastDrawingElementType] == AJRBezierPathElementMoveTo) {
        return 0.0;
    }
    
    return AJRArctan(_points[_pointCount - 2].y - _points[_pointCount - 1].y,
                     _points[_pointCount - 2].x - _points[_pointCount - 1].x);
}

- (void)relativeLineToAngle:(CGFloat)degree length:(CGFloat)length {
    [self lineToAngle:[self _lastSegmentAngle] + degree length:length];
    
    [self setBoundsAreValid:NO];
}

- (void)moveToAngle:(CGFloat)degree length:(CGFloat)length {
    CGPoint current = [self currentPoint];
    
    [self moveToPoint:(CGPoint){current.x + (AJRCos(degree) * length), current.y + (AJRSin(degree) * length)}];
    
    [self setBoundsAreValid:NO];
}

- (void)relativeMoveToAngle:(CGFloat)degree length:(CGFloat)length {
    [self lineToAngle:[self _lastSegmentAngle] + degree length:length];
    
    [self setBoundsAreValid:NO];
}

- (void)openPath {
    if ([self isClosed]) {
        _elementCount--;
    }
}

- (BOOL)isClosed {
    return _elements[_elementCount - 1] == AJRBezierPathElementClose;
}

- (void)insertMoveToPoint:(CGPoint)point atIndex:(NSUInteger)elementIndex {
    if (elementIndex == _elementCount) {
        // This is the simplest case.
        [self moveToPoint:point];
    } else {
        BOOL        closePath;
        NSUInteger    startingPointIndex;
        NSInteger    x;
        
        // Because publically, the zeroth element is the moveto, but internally, it's the bounding box.
        elementIndex++;
        
        closePath = [self isElementAtIndexInClosedSubpath:elementIndex];
        startingPointIndex = _elementToPointIndex[elementIndex];
        
        [self _increaseCoordinateCountBy:1];
        [self _increaseOperationCountBy:closePath ? 2 : 1];
        
        memmove(_points + startingPointIndex + 1, _points + startingPointIndex, sizeof(CGPoint) * ((_pointCount - startingPointIndex) + 0));
        memmove(_elements + elementIndex + (closePath ? 2 : 1), _elements + elementIndex, sizeof(AJRBezierPathElementType) * (_elementCount - elementIndex));
        memmove(_elementToPointIndex + elementIndex + (closePath ? 2 : 1), _elementToPointIndex + elementIndex, sizeof(NSUInteger) * (_elementCount - elementIndex));
        
        if (elementIndex == 1) {
            _points[startingPointIndex] = point;
            _elements[elementIndex] = AJRBezierPathElementMoveTo;
            _elementToPointIndex[elementIndex] = startingPointIndex;
            if (closePath) {
                _elements[elementIndex + 1] = AJRBezierPathElementClose;
            }
        } else {
            if (closePath) {
                _elements[elementIndex] = AJRBezierPathElementClose;
                _points[startingPointIndex] = point;
                _elements[elementIndex + 1] = AJRBezierPathElementMoveTo;
                _elementToPointIndex[elementIndex + 1] = startingPointIndex;
            } else {
                _points[startingPointIndex] = point;
                _elements[elementIndex] = AJRBezierPathElementMoveTo;
                _elementToPointIndex[elementIndex] = startingPointIndex;
            }
        }
        
        _elementCount += (closePath ? 2 : 1);
        _pointCount += 1;
        
        for (x = elementIndex + (closePath ? 2 : 1); x < _elementCount; x++) {
            if (_elementToPointIndex[x] >= startingPointIndex) {
                _elementToPointIndex[x] += 1;
            }
        }
        [self _intersectPointWithBounds:point forMoveTo:NO];
        [self setBoundsAreValid:NO];
    }
}

- (void)insertLineToPoint:(CGPoint)point atIndex:(NSUInteger)elementIndex {
    NSUInteger startingPointIndex;
    NSInteger x;
    
    elementIndex += 1;
    
    if (elementIndex == 1) {
        [NSException raise:NSInvalidArgumentException format:@"You cannot insert a line segment before the first move to."];
    }
    
    if ((elementIndex <= 1) || (elementIndex > _elementCount)) {
        [NSException raise:NSInvalidArgumentException format:@"Index %ld out of range [%lu..%ld]", elementIndex, 0L, _elementCount];
    }
    
    if (_elements[elementIndex] == AJRBezierPathElementClose) {
        if (_elements[elementIndex - 1] == AJRBezierPathElementCurveTo) {
            startingPointIndex = _elementToPointIndex[elementIndex - 1] + 3;
        } else {
            startingPointIndex = _elementToPointIndex[elementIndex - 1] + 1;
        }
    } else {
        startingPointIndex = _elementToPointIndex[elementIndex];
    }
    
    [self _increaseCoordinateCountBy:1];
    [self _increaseOperationCountBy:1];
    
    memmove(_points + startingPointIndex + 1, _points + startingPointIndex, sizeof(CGPoint) * ((_pointCount - startingPointIndex) + 0));
    memmove(_elements + elementIndex + 1, _elements + elementIndex, sizeof(AJRBezierPathElementType) * ((_elementCount - elementIndex) + 0));
    memmove(_elementToPointIndex + elementIndex + 1, _elementToPointIndex + elementIndex, sizeof(NSUInteger) * ((_elementCount - elementIndex) + 0));
    
    _points[startingPointIndex] = point;
    _elements[elementIndex] = AJRBezierPathElementLineTo;
    _elementToPointIndex[elementIndex] = startingPointIndex;
    
    _elementCount++;
    _pointCount++;
    
    for (x = elementIndex + 1; x < _elementCount; x++) {
        if (_elementToPointIndex[x] >= startingPointIndex) {
            _elementToPointIndex[x] += 1;
        }
    }
    [self _intersectPointWithBounds:point forMoveTo:NO];
    
    [self setBoundsAreValid:NO];
}

- (void)insertCurveToPoint:(CGPoint)point controlPoint1:(CGPoint)control1 controlPoint2:(CGPoint)control2 atIndex:(NSUInteger)elementIndex {
    NSUInteger startingPointIndex;
    NSInteger x;
    
    elementIndex += 1;
    
    if (elementIndex == 1) {
        [NSException raise:NSInvalidArgumentException format:@"You cannot insert a curve segment before the first move to."];
    }
    
    if ((elementIndex <= 1) || (elementIndex > _elementCount)) {
        [NSException raise:NSRangeException format:@"Index %ld out of range [%ld..%ld]", elementIndex, 0L, _elementCount];
    }
    
    if (_elements[elementIndex] == AJRBezierPathElementClose) {
        if (_elements[elementIndex - 1] == AJRBezierPathElementCurveTo) {
            startingPointIndex = _elementToPointIndex[elementIndex - 1] + 3;
        } else {
            startingPointIndex = _elementToPointIndex[elementIndex - 1] + 1;
        }
    } else {
        startingPointIndex = _elementToPointIndex[elementIndex];
    }
    
    [self _increaseCoordinateCountBy:3];
    [self _increaseOperationCountBy:1];
    
    memmove(_points + startingPointIndex + 3, _points + startingPointIndex, sizeof(CGPoint) * (_pointCount - startingPointIndex));
    memmove(_elements + elementIndex + 1, _elements + elementIndex, sizeof(AJRBezierPathElementType) * (_elementCount - elementIndex));
    memmove(_elementToPointIndex + elementIndex + 1, _elementToPointIndex + elementIndex, sizeof(NSUInteger) * (_elementCount - elementIndex));
    
    _points[startingPointIndex] = control1;
    _points[startingPointIndex + 1] = control2;
    _points[startingPointIndex + 2] = point;
    _elements[elementIndex] = AJRBezierPathElementCurveTo;
    _elementToPointIndex[elementIndex] = startingPointIndex;
    
    _elementCount++;
    _pointCount += 3;
    
    for (x = elementIndex + 1; x < _elementCount; x++) {
        if (_elementToPointIndex[x] >= startingPointIndex) {
            _elementToPointIndex[x] += 3;
        }
    }
    [self _intersectPointWithBounds:point forMoveTo:NO];
    [self _intersectPointWithBounds:control1 forMoveTo:NO];
    [self _intersectPointWithBounds:control2 forMoveTo:NO];
    
    [self setBoundsAreValid:NO];
}

- (void)splitElementAtIndex:(NSUInteger)elementIndex atTValue:(CGFloat)t {
    CGPoint point1, point2;
    AJRBezierCurve curve, left, right;
    
    elementIndex++;
    
    switch (_elements[elementIndex]) {
        case AJRBezierPathElementSetBoundingBox:
        case AJRBezierPathElementMoveTo:
            [NSException raise:NSInvalidArgumentException format:@"You can only split _elements of type AJRBezierPathElementLineTo, AJRBezierPathElementCurveTo, or AJRBezierPathElementClose."];
            break;
        case AJRBezierPathElementLineTo:
        case AJRBezierPathElementClose:
            point1 = _points[_elementToPointIndex[elementIndex]];
            point2 = _points[_elementToPointIndex[elementIndex - 1]];
            [self insertLineToPoint:(CGPoint){(point1.x + point2.x) / 2.0, (point1.y + point2.y) / 2.0} atIndex:elementIndex - 1];
            break;
        case AJRBezierPathElementCurveTo:
            curve.start = _points[_elementToPointIndex[elementIndex] - 1];
            curve.handle1 = _points[_elementToPointIndex[elementIndex] + 0];
            curve.handle2 = _points[_elementToPointIndex[elementIndex] + 1];
            curve.end = _points[_elementToPointIndex[elementIndex] + 2];
            AJRSplitBezierCurveAtT(curve, &left, &right, t);
            _points[_elementToPointIndex[elementIndex] + 0] = left.handle1;
            _points[_elementToPointIndex[elementIndex] + 1] = left.handle2;
            _points[_elementToPointIndex[elementIndex] + 2] = left.end;
            [self insertCurveToPoint:right.end controlPoint1:right.handle1 controlPoint2:right.handle2 atIndex:elementIndex /* This is really plus 1 */];
            break;
    }
    
    [self setBoundsAreValid:NO];
}

- (CGPoint)lastPoint {
    return _points[_pointCount - 1];
}

- (void)movePointAtIndex:(NSInteger)index byDelta:(CGPoint)aDelta {
    if (index + 2 < _pointCount) {
        _points[index + 2].x += aDelta.x;
        _points[index + 2].y += aDelta.y;
        [self _updateBoundingBox];
    } else {
        [NSException raise:NSRangeException format:@"Index %ld is out of range [0..%lu]", index, _pointCount - 2];
    }
    
    [self setBoundsAreValid:NO];
}

- (NSInteger)lastDrawingElementIndex {
    return _elementCount - ([self isClosed] ? 3 : 2);
}

- (AJRBezierPathElementType)elementTypeAtIndex:(NSInteger)index ajrsociatedLineSegment:(AJRLine *)lineSegment {
    if (index + 1 >= _elementCount) {
        [NSException raise:NSRangeException format:@"Index %ld is out of range [0..%lu]", index, _elementCount - 1];
    }
    
    switch (_elements[index]) {
        case AJRBezierPathElementSetBoundingBox:
            lineSegment->start = (CGPoint){0.0, 0.0};
            break;
        case AJRBezierPathElementMoveTo:
            lineSegment->start = _points[_elementToPointIndex[index]];
            break;
        case AJRBezierPathElementLineTo:
            lineSegment->start = _points[_elementToPointIndex[index]];
            break;
        case AJRBezierPathElementCurveTo:
            lineSegment->start = _points[_elementToPointIndex[index] + 2];
            break;
        case AJRBezierPathElementClose:
            lineSegment->start = _points[_elementToPointIndex[index]];
            break;
    }
    
    switch (_elements[index + 1]) {
        case AJRBezierPathElementSetBoundingBox:
            lineSegment->end = (CGPoint){0.0, 0.0};
            break;
        case AJRBezierPathElementMoveTo:
            lineSegment->end = (CGPoint){0.0, 0.0};
            break;
        case AJRBezierPathElementLineTo:
            lineSegment->end = _points[_elementToPointIndex[index + 1]];
            break;
        case AJRBezierPathElementCurveTo:
            lineSegment->end = _points[_elementToPointIndex[index + 1]];
            break;
        case AJRBezierPathElementClose:
            lineSegment->end = _points[_elementToPointIndex[index + 1]];
            break;
    }
    
    return _elements[index + 1];
}

- (AJRBezierPathElementType)lastElementType {
    return _elements[_elementCount - 1];
}

- (AJRBezierPathElementType)lastDrawingElementType {
    if (_elements[_elementCount - 1] == AJRBezierPathElementClose) {
        return _elements[_elementCount - 2];
    }
    return _elements[_elementCount - 1];
}

- (NSUInteger)moveToIndexForElementAtIndex:(NSInteger)index {
    if (index + 1 >= _elementCount) {
        [NSException raise:NSRangeException format:@"Index %ld is out of range [0..%lu]", index, _elementCount - 1];
    }
    
    index += 1;
    while (index > 1) {
        index--;
        if (_elements[index] == AJRBezierPathElementMoveTo) return index - 1;
    }
    
    return NSNotFound;
}

- (BOOL)isElementAtIndexInClosedSubpath:(NSInteger)elementIndex {
    for (NSInteger x = elementIndex + 1; x < _elementCount; x++) {
        switch (_elements[x]) {
            case AJRBezierPathElementSetBoundingBox:
                break;
            case AJRBezierPathElementMoveTo:
                if (x != elementIndex + 1) {
                    return NO;
                }
                break;
            case AJRBezierPathElementLineTo:
            case AJRBezierPathElementCurveTo:
                break;
            case AJRBezierPathElementClose:
                return YES;
            default:
                break;
        }
    }
    return NO;
}

- (void)translateByDelta:(CGPoint)delta {
    for (NSInteger x = 0; x < _pointCount; x++) {
        _points[x].x += delta.x;
        _points[x].y += delta.y;
    }
    
    if (_strokeBoundsValid) {
        _strokeBounds.origin.x += delta.x;
        _strokeBounds.origin.y += delta.y;
    }
    if (_boundsValid) {
        _bounds.origin.x += delta.x;
        _bounds.origin.y += delta.y;
    }
}

- (void)rotateByDegrees:(CGFloat)degrees aroundPoint:(CGPoint)origin {
    NSAffineTransform    *transform = [[NSAffineTransform allocWithZone:nil] init];
    
    [transform translateXBy:origin.x yBy:origin.y];
    [transform rotateByDegrees:degrees];
    [transform translateXBy:-origin.x yBy:-origin.y];
    
    [self transformUsingAffineTransform:transform];
    
    
    [self setBoundsAreValid:NO];
}

- (void)setControlPointBounds:(CGRect)newBounds; {
    CGRect someBounds = [self controlPointBounds];
    BOOL flipX, flipY;
    
    flipX = newBounds.size.width < 0;
    flipY = newBounds.size.height < 0;
    
    newBounds = AJRNormalizeRectWithNonzeroArea(newBounds);
    someBounds = AJRNormalizeRectWithNonzeroArea(someBounds);
    
    if (NSEqualSizes(someBounds.size, newBounds.size)) {
        [self translateByDelta:(CGPoint){newBounds.origin.x - someBounds.origin.x, newBounds.origin.y - someBounds.origin.y}];
        if (flipX || flipY) {
            NSInteger        x;
            
            someBounds = [self controlPointBounds];
            for (x = 2; x < _pointCount; x++) {
                if (flipX) {
                    _points[x].x = (newBounds.origin.x + newBounds.size.width) - (_points[x].x - someBounds.origin.x);
                }
                if (flipY) {
                    _points[x].y = (newBounds.origin.y + newBounds.size.height) - (_points[x].y - someBounds.origin.y);
                }
            }
        }
    } else {
        CGFloat cw, ch;
        NSInteger x;
        
        cw = newBounds.size.width / someBounds.size.width;
        ch = newBounds.size.height / someBounds.size.height;
        
        for (x = 0; x < _pointCount; x++) {
            if (flipX && (x >= 2)) {
                _points[x].x = (newBounds.origin.x + newBounds.size.width) - ((_points[x].x - someBounds.origin.x) * cw);
            } else {
                _points[x].x = ((_points[x].x - someBounds.origin.x) * cw) + newBounds.origin.x;
            }
            if (flipY && (x >= 2)) {
                _points[x].y = (newBounds.origin.y + newBounds.size.height) - ((_points[x].y - someBounds.origin.y) * ch);
            } else {
                _points[x].y = ((_points[x].y - someBounds.origin.y) * ch) + newBounds.origin.y;
            }
        }
    }
    
    [self setBoundsAreValid:NO];
}

- (NSString *)psDescription {
    return [self psDescriptionWithFill:YES];
}

- (NSString *)psDescriptionWithFill:(BOOL)flag; {
    NSMutableString *string;
    NSInteger x;
    CGPoint moveTo = CGPointZero, currentPoint;
    
    string = [NSMutableString stringWithFormat:@"    newpath\n"];
    
    for (x = 1; x < _elementCount; x++) {
        switch (_elements[x]) {
            case AJRBezierPathElementSetBoundingBox:
                [string appendFormat:@"        %.3f %.3f %.3f %.3f setbbox\n",
                 _points[_elementToPointIndex[x] + 0].x,
                 _points[_elementToPointIndex[x] + 0].y,
                 _points[_elementToPointIndex[x] + 1].x,
                 _points[_elementToPointIndex[x] + 1].y];
                break;
            case AJRBezierPathElementMoveTo:
                //[string appendFormat:@"        gsave /Times-Roman 12 selectfont 0 setgray %.6f %.6f moveto (%d) dup stringwidth pop 2 div neg 0 rmoveto show grestore\n", _points[_elementToPointIndex[x] + 0].x, _points[_elementToPointIndex[x] + 0].y, x - 1];
                [string appendFormat:@"        %.3f %.3f moveto\n",
                 _points[_elementToPointIndex[x] + 0].x,
                 _points[_elementToPointIndex[x] + 0].y];
                currentPoint = _points[_elementToPointIndex[x] + 0];
                moveTo = currentPoint;
                break;
            case AJRBezierPathElementLineTo:
                //[string appendFormat:@"        gsave /Times-Roman 12 selectfont 0 setgray %.6f %.6f moveto (%d) dup stringwidth pop 2 div neg 0 rmoveto show grestore\n", _points[_elementToPointIndex[x] + 0].x, _points[_elementToPointIndex[x] + 0].y, x - 1];
                [string appendFormat:@"        %.3f %.3f lineto\n",
                 _points[_elementToPointIndex[x] + 0].x,
                 _points[_elementToPointIndex[x] + 0].y];
                currentPoint = _points[_elementToPointIndex[x] + 0];
                break;
            case AJRBezierPathElementCurveTo:
                //[string appendFormat:@"        gsave /Times-Roman 12 selectfont 0 setgray %.6f %.6f moveto (%d) dup stringwidth pop 2 div neg 0 rmoveto show grestore\n", _points[_elementToPointIndex[x] + 2].x, _points[_elementToPointIndex[x] + 2].y, x - 1];
                [string appendFormat:@"        %.3f %.3f %.3f %.3f %.3f %.3f curveto\n",
                 _points[_elementToPointIndex[x] + 0].x,
                 _points[_elementToPointIndex[x] + 0].y,
                 _points[_elementToPointIndex[x] + 1].x,
                 _points[_elementToPointIndex[x] + 1].y,
                 _points[_elementToPointIndex[x] + 2].x,
                 _points[_elementToPointIndex[x] + 2].y];
                currentPoint = _points[_elementToPointIndex[x] + 2];
                break;
            case AJRBezierPathElementClose:
                //[string appendFormat:@"        gsave /Times-Roman 12 selectfont 0 setgray %.6f 11 add %.6f moveto ((%d)) dup stringwidth pop 2 div neg 0 rmoveto show grestore\n", moveTo.x, moveTo.y, x - 1];
                [string appendFormat:@"    closepath\n"];
                currentPoint = moveTo;
                break;
        }
    }
    
    if (flag) {
        [string appendFormat:@"    gsave 13 15 div setgray %@ grestore stroke", self.windingRule == AJRWindingRuleNonZero ? @"fill" : @"eofill"];
    } else {
        [string appendFormat:@"    stroke"];
    }
    
    return string;
}

- (void)changeToLineToElementAtIndex:(NSUInteger)elementIndex {
}

- (void)_insertPoints:(NSUInteger)count atElementIndex:(NSUInteger)elementIndex {
    NSInteger x;
    NSUInteger pointIndex = _elementToPointIndex[elementIndex];
    
    [self _increaseCoordinateCountBy:count];
    memmove(_points + pointIndex + count, _points + pointIndex, sizeof(CGPoint) * (_pointCount - pointIndex));
    _pointCount += count;
    
    for (x = elementIndex + 1; x < _elementCount; x++) {
        if (_elementToPointIndex[x] > pointIndex) {
            _elementToPointIndex[x] += count;
        }
    }
    
    [self setBoundsAreValid:NO];
}

- (void)changeToCurveToWithControlPoint1:(CGPoint)control1 controlPoint2:(CGPoint)control2 elementAtIndex:(NSUInteger)elementIndex {
    elementIndex++;
    
    switch (_elements[elementIndex]) {
        case AJRBezierPathElementSetBoundingBox:
            break;
        case AJRBezierPathElementMoveTo:
            [NSException raise:NSInvalidArgumentException format:@"Cannot change a moveTo to a curveTo"];
            break;
        case AJRBezierPathElementLineTo:
            _elements[elementIndex] = AJRBezierPathElementCurveTo;
            [self _insertPoints:2 atElementIndex:elementIndex];
            _points[_elementToPointIndex[elementIndex] + 0] = control1;
            _points[_elementToPointIndex[elementIndex] + 1] = control2;
            break;
        case AJRBezierPathElementCurveTo:
            _points[_elementToPointIndex[elementIndex] + 0] = control1;
            _points[_elementToPointIndex[elementIndex] + 1] = control2;
            break;
        case AJRBezierPathElementClose:
            [self insertCurveToPoint:_points[_elementToPointIndex[elementIndex]] controlPoint1:control1 controlPoint2:control2 atIndex:elementIndex - 1];
            break;
    }
    
    [self setBoundsAreValid:NO];
}

- (void)removeElementAtIndex:(NSUInteger)elementIndex {
    NSInteger pointsToRemove = 0;
    NSInteger startingPointIndex = 0;
    NSInteger x;
    BOOL promoteMoveTo = NO;
    
    elementIndex += 1;
    
    if (elementIndex >= _elementCount) {
        [NSException raise:NSInvalidArgumentException format:@"%lu is out of element range of [0..%lu]", elementIndex - 1, _elementCount - 1];
    }
    
    switch (_elements[elementIndex]) {
        case AJRBezierPathElementMoveTo:
            if ((elementIndex + 1 < _elementCount) && (_elements[elementIndex + 1] == AJRBezierPathElementCurveTo)) {
                pointsToRemove = 3;
            } else {
                pointsToRemove = 1;
            }
            startingPointIndex = _elementToPointIndex[elementIndex];
            promoteMoveTo = YES;
            break;
        case AJRBezierPathElementLineTo:
            pointsToRemove = 1;
            startingPointIndex = _elementToPointIndex[elementIndex];
            break;
        case AJRBezierPathElementCurveTo:
            pointsToRemove = 3;
            startingPointIndex = _elementToPointIndex[elementIndex];
            if (_elements[elementIndex + 1] == AJRBezierPathElementCurveTo) {
                startingPointIndex++;
            }
            break;
        case AJRBezierPathElementClose:
            pointsToRemove = 0;
            startingPointIndex = 0;
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Cannot delete point at index %lu, because it's not a drawing element.", elementIndex - 1];
            break;
    }
    
    if (pointsToRemove > 0) {
        memmove(_points + startingPointIndex, _points + startingPointIndex + pointsToRemove, sizeof(CGPoint) * (_pointCount - (startingPointIndex + pointsToRemove)));
        _pointCount -= pointsToRemove;
    }
    memmove(_elements + elementIndex, _elements + elementIndex + 1, sizeof(AJRBezierPathElementType) * (_elementCount - (elementIndex + 1)));
    memmove(_elementToPointIndex + elementIndex, _elementToPointIndex + elementIndex + 1, sizeof(NSUInteger) * (_elementCount - (elementIndex + 1)));
    
    _elementCount--;
    
    if (pointsToRemove > 0) {
        for (x = elementIndex; x < _elementCount; x++) {
            if (_elementToPointIndex[x] > startingPointIndex) {
                _elementToPointIndex[x] -= pointsToRemove;
            }
        }
        [self _updateBoundingBox];
    }
    
    if (promoteMoveTo) {
        _elements[elementIndex] = AJRBezierPathElementMoveTo;
    }
    
    [self setBoundsAreValid:NO];
}

- (NSUInteger)elementIndexOfElementHitByPoint:(CGPoint)point atTValue:(CGFloat *)t {
    return [self elementIndexOfElementHitByPoint:point atTValue:t width:6.0];
}

- (NSUInteger)elementIndexOfElementHitByPoint:(CGPoint)point atTValue:(CGFloat *)t width:(CGFloat)width {
    NSInteger x;
    CGPoint moveTo = CGPointZero, currentPoint = CGPointZero;
    CGFloat error = width / 2.0;
    AJRIntersection *intersection;
    AJRLine line;
    
    *t = 0.0;
    
    for (x = 1; x < _elementCount; x++) {
        switch (_elements[x]) {
            case AJRBezierPathElementSetBoundingBox:
                break;
            case AJRBezierPathElementMoveTo:
                currentPoint = _points[_elementToPointIndex[x]];
                moveTo = currentPoint;
                break;
            case AJRBezierPathElementLineTo:
                line.start = currentPoint;
                line.end = _points[_elementToPointIndex[x]];
                intersection = [AJRIntersection intersectionForLine:line withPerpendicularLineThroughPoint:point];
                if (intersection) {
                    if (AJRDistanceBetweenPoints([intersection point], point) < error) {
                        if (line.start.x == line.end.x) {
                            *t = (line.start.y - [intersection point].y) / (line.start.y - line.end.y);
                        } else {
                            *t = (line.start.x - [intersection point].x) / (line.start.x - line.end.x);
                        }
                        return x - 1;
                    }
                }
                currentPoint = line.end;
                break;
            case AJRBezierPathElementCurveTo:
                intersection = [AJRIntersection intersectionForCurve:(AJRBezierCurve){currentPoint, _points[_elementToPointIndex[x] + 0], _points[_elementToPointIndex[x] + 1], _points[_elementToPointIndex[x] + 2]} withPoint:point];
                if (AJRDistanceBetweenPoints(point, [intersection point]) < error) {
                    *t = [intersection t];
                    return x - 1;
                }
                currentPoint = _points[_elementToPointIndex[x] + 2];
                break;
            case AJRBezierPathElementClose:
                line.start = currentPoint;
                line.end = moveTo;
                intersection = [AJRIntersection intersectionForLine:line withPerpendicularLineThroughPoint:point];
                if (intersection) {
                    if (AJRDistanceBetweenPoints([intersection point], point) < error) {
                        if (line.start.x == line.end.x) {
                            *t = (line.start.y - [intersection point].y) / (line.start.y - line.end.y);
                        } else {
                            *t = (line.start.x - [intersection point].x) / (line.start.x - line.end.x);
                        }
                        return x - 1;
                    }
                }
                currentPoint = moveTo;
                break;
        }
    }
    
    if (x == _elementCount) return NSNotFound;
    
    return x - 1;
}

- (AJRPathEnumerator *)pathEnumerator {
    return [[AJRPathEnumerator allocWithZone:nil] initWithBezierPath:self];
}

- (void)enumerateWithBlock:(void (^)(NSBezierPathElement element, CGPoint *points, BOOL *stop))enumerationBlock {
    AJRPathEnumerator *enumerator = [self pathEnumerator];
    AJRBezierPathElementType *element;
    CGPoint points[4];
    BOOL stop = NO;
    
    while ((element = [enumerator nextElementWithPoints:points]) && !stop) {
        enumerationBlock(*element, points, &stop);
    }
}

- (void)enumerateFlattenedPathWithBlock:(void (^)(AJRLine lineSegment, BOOL isNewSubpath, BOOL *stop))enumerationBlock {
    AJRPathEnumerator *enumerator = [self pathEnumerator];
    AJRLine *line;
    BOOL stop = NO;
    BOOL isNewSubpath = NO;
    
    while ((line = [enumerator nextLineSegmentIsNewSubpath:&isNewSubpath]) && !stop) {
        enumerationBlock(*line, isNewSubpath, &stop);
    }
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@: %p>:\n", [self class], self];
    AJRPathEnumerator *enumerator = [self pathEnumerator];
    AJRBezierPathElementType *type;
    CGPoint somePoints[3];
    
    while ((type = (AJRBezierPathElementType *)[enumerator nextElementWithPoints:somePoints]) != NULL) {
        switch (*type) {
            case AJRBezierPathElementSetBoundingBox:
                [string appendFormat:@"   setboundingbox(%.6f, %.6f, %.6f, %.6f)\n",
                 somePoints[0].x, somePoints[0].y,
                 somePoints[1].x, somePoints[1].y];
                break;
            case AJRBezierPathElementMoveTo:
                [string appendFormat:@"   moveto(%.6f, %.6f)\n",
                 somePoints[0].x, somePoints[0].y];
                break;
            case AJRBezierPathElementLineTo:
                [string appendFormat:@"   lineto(%.6f, %.6f)\n",
                 somePoints[0].x, somePoints[0].y];
                break;
            case AJRBezierPathElementCurveTo:
                [string appendFormat:@"   curveto({%.6f, %.6f}, {%.6f, %.6f}, {%.6f, %.6f})\n",
                 somePoints[0].x, somePoints[0].y,
                 somePoints[1].x, somePoints[1].y,
                 somePoints[2].x, somePoints[2].y];
                break;
            case AJRBezierPathElementClose:
                [string appendFormat:@"   closepath()\n"];
                break;
        }
    }
    
    return string;
}

- (NSString *)javaDescriptionWithName:(NSString *)name {
    NSMutableString *string = [NSMutableString string];
    AJRPathEnumerator *enumerator = [self pathEnumerator];
    AJRBezierPathElementType *type;
    CGPoint somePoints[3];
    
    [string appendFormat:@"        %@ = new GeneralPath();\n", name];
    while ((type = (AJRBezierPathElementType *)[enumerator nextElementWithPoints:somePoints]) != NULL) {
        switch (*type) {
            case AJRBezierPathElementSetBoundingBox:
                break;
            case AJRBezierPathElementMoveTo:
                [string appendFormat:@"        %@.moveTo((CGFloat)%.6f, (CGFloat)%.6f);\n", name, somePoints[0].x, somePoints[0].y];
                break;
            case AJRBezierPathElementLineTo:
                [string appendFormat:@"        %@.lineTo((CGFloat)%.6f, (CGFloat)%.6f);\n", name, somePoints[0].x, somePoints[0].y];
                break;
            case AJRBezierPathElementCurveTo:
                [string appendFormat:@"        %@.curveTo((CGFloat)%.6f, (CGFloat)%.6f, (CGFloat)%.6f, (CGFloat)%.6f, (CGFloat)%.6f, (CGFloat)%.6f);\n", name,
                 somePoints[0].x, somePoints[0].y,
                 somePoints[1].x, somePoints[1].y,
                 somePoints[2].x, somePoints[2].y];
                break;
            case AJRBezierPathElementClose:
                [string appendFormat:@"        %@.closePath();\n", name];
                break;
        }
    }
    
    return string;
}

- (CGRect)strokeBounds:(BOOL)flag {
    if (!flag && _strokeBoundsValid) return _strokeBounds;
    
    if (_elementCount <= 1) return NSZeroRect;
    
    [self _setupDrawingContext:AJRHitTestContext()];
    _strokeBounds = AJRstrokebounds(AJRHitTestContext(), _points, _pointCount, _elements, _elementCount);
    
    _strokeBoundsValid = YES;
    
    return _strokeBounds;
}

- (CGRect)strokeBounds {
    return [self strokeBounds:NO];
}

- (void)setBoundsAreValid:(BOOL)flag {
    _strokeBoundsValid = flag;
    _boundsValid = flag;
}

- (void)appendBezierPathWithCrossedRect:(CGRect)rect {
    [self moveToPoint:rect.origin];
    [self relativeLineToPoint:(CGPoint){0.0, rect.size.height}];
    [self relativeLineToPoint:(CGPoint){rect.size.width, 0.0}];
    [self relativeLineToPoint:(CGPoint){0.0, -rect.size.height}];
    [self closePath];
    [self moveToPoint:rect.origin];
    [self relativeLineToPoint:(CGPoint){rect.size.width, rect.size.height}];
    [self moveToPoint:(CGPoint){rect.origin.x, rect.origin.y + rect.size.height}];
    [self relativeLineToPoint:(CGPoint){rect.size.width, -rect.size.height}];
}

- (void)appendBezierPathWithCrossCenteredAt:(NSPoint)center legSize:(NSSize)legSize andLegThickness:(NSSize)legThickness {
    [self moveToPoint:(NSPoint){center.x - legThickness.width, center.y - legThickness.height}];
    [self lineToPoint:(NSPoint){center.x - legSize.width, center.y - legThickness.height}];
    [self lineToPoint:(NSPoint){center.x - legSize.width, center.y + legThickness.height}];
    [self lineToPoint:(NSPoint){center.x - legThickness.width, center.y + legThickness.height}];
    [self lineToPoint:(NSPoint){center.x - legThickness.width, center.y + legSize.height}];
    [self lineToPoint:(NSPoint){center.x + legThickness.width, center.y + legSize.height}];
    [self lineToPoint:(NSPoint){center.x + legThickness.width, center.y + legThickness.height}];
    [self lineToPoint:(NSPoint){center.x + legSize.width, center.y + legThickness.height}];
    [self lineToPoint:(NSPoint){center.x + legSize.width, center.y - legThickness.height}];
    [self lineToPoint:(NSPoint){center.x + legThickness.width, center.y - legThickness.height}];
    [self lineToPoint:(NSPoint){center.x + legThickness.width, center.y - legSize.height}];
    [self lineToPoint:(NSPoint){center.x - legThickness.width, center.y - legSize.height}];
    [self closePath];
}

- (void)appendBezierPathWithPolygonInRect:(CGRect)arcBounds sides:(NSInteger)sides starPercent:(CGFloat)starPercent offset:(CGFloat)offset NS_SWIFT_NAME(appendPolygon(in:sides:starPercent:offset:)) {
    CGFloat angle = offset;
    CGFloat step = 360.0 / sides;
    CGFloat halfStep = step / 2.0;
    CGPoint origin = CGPointMake(NSMidX(arcBounds), NSMidY(arcBounds));
    CGFloat xRadius = arcBounds.size.width / 2.0;
    CGFloat yRadius = arcBounds.size.height / 2.0;
    CGFloat halfXRadius = xRadius;
    CGFloat halfYRadius = yRadius;

    if (starPercent > 0.0) {
        halfXRadius = xRadius * AJRCos(step / 2.0);
        halfYRadius = yRadius * AJRCos(step / 2.0);
    }

    do {
        CGPoint point = NSZeroPoint;
        point = AJRPointOnOval(origin, xRadius, yRadius, angle);
        if (angle == offset) {
            [self moveToPoint:point];
        } else {
            [self lineToPoint:point];
        }
        if (starPercent > 0) {
            point = AJRPointOnOval(origin,
                                   halfXRadius * ((100.0 - starPercent) / 100.0),
                                   halfYRadius * ((100.0 - starPercent) / 100.0),
                                   angle + halfStep);
            [self lineToPoint:point];
        }
        angle += step;
    } while (angle - offset < 360.0);
    [self closePath];
}

void AJRPathToBezierIterator(void *info, const CGPathElement *element) {
    NSBezierPath *path = (__bridge NSBezierPath *)info;
    
    switch (element->type) {
        case kCGPathElementMoveToPoint:
            [path moveToPoint:(CGPoint){element->points[0].x, element->points[0].y}];
            break;
        case kCGPathElementAddLineToPoint:
            [path lineToPoint:(CGPoint){element->points[0].x, element->points[0].y}];
            break;
        case kCGPathElementAddQuadCurveToPoint:
            break;
        case kCGPathElementAddCurveToPoint:
            [path curveToPoint:(CGPoint){element->points[2].x, element->points[2].y} controlPoint1:(CGPoint){element->points[0].x, element->points[0].y} controlPoint2:(CGPoint){element->points[1].x, element->points[1].y}];
            break;
        case kCGPathElementCloseSubpath:
            [path closePath];
            break;
    }
}

- (AJRBezierPath *)bezierPathFromStrokedPath {
    CGContextRef context = AJRHitTestContext();
    CGPathRef strokedPath;
    AJRBezierPath *newPath;
    
    [self _setupDrawingContext:context];
    AJRbuildpath(context, _points, _pointCount, _elements, _elementCount, NULL);
    CGContextReplacePathWithStrokedPath(context);
    strokedPath = CGContextCopyPath(context);
    newPath = [[AJRBezierPath alloc] init];
    CGPathApply(strokedPath, (__bridge void *)newPath, AJRPathToBezierIterator);
    CGPathRelease(strokedPath);
    
    return newPath;
}

- (BOOL)isContourClockwiseFromIndex:(NSUInteger)startIndex toIndex:(NSUInteger)endIndex {
    NSInteger x;
    CGPoint minPoint;
    NSUInteger minPointIndex;
    BOOL clockwise = YES;
    NSUInteger pointCount = endIndex - startIndex;
    
    NSAssert(pointCount >= 2, @"The startIndex (%ld) must be less than endIndex (%ld) and there must be at least 2 points (%ld).", startIndex, endIndex, pointCount);
    
    minPoint = _points[_elementToPointIndex[startIndex]];
    minPointIndex = startIndex;
    for (x = startIndex + 1; x <= endIndex; x++) {
        CGPoint  newPoint;
        switch (_elements[x]) {
                // NOTE: We only have to worry about these two types because we know we're a valid subcontour at this point.
            case AJRBezierPathElementLineTo:
                newPoint = _points[_elementToPointIndex[x]];
                break;
            case AJRBezierPathElementCurveTo:
                // Just care about the end point, we don't need to worry about the control points.
                newPoint = _points[_elementToPointIndex[x]];
                break;
            default:
                break;
        }
        if (newPoint.x < minPoint.x) {
            minPoint = newPoint;
            minPointIndex = x;
        }
    }
    
    for (x = minPointIndex; x < minPointIndex + pointCount; x++) {
        NSInteger   actualIndex = x > endIndex ? x = startIndex + (x - endIndex - 1): x;
        CGPoint     newPoint;
        switch (_elements[x]) {
                // NOTE: We only have to worry about these two types because we know we're a valid subcontour at this point.
            case AJRBezierPathElementLineTo:
                newPoint = _points[_elementToPointIndex[actualIndex]];
                break;
            case AJRBezierPathElementCurveTo:
                // Just care about the end point, we don't need to worry about the control points.
                newPoint = _points[_elementToPointIndex[actualIndex]];
                break;
            default:
                break;
        }
        if (minPoint.y > newPoint.y) {
            clockwise = NO;
            break;
        } else if (minPoint.y < newPoint.y) {
            clockwise = YES;
            break;
        }
    }
    
    return clockwise;
}

- (BOOL)getContourContainingIndex:(NSUInteger)index startingIndex:(NSUInteger *)startIndexOut endingIndex:(NSUInteger *)endIndexOut clockwise:(BOOL *)clockwiseOut {
    NSInteger x;
    NSInteger startIndex = NSNotFound;
    NSInteger endIndex = NSNotFound;
    BOOL clockwise = NO;
    
    if (_pointCount > 2) {
        // This means we have more than our "bounding box" set.
        
        if (index <= 1) {
            startIndex = 1;
            index = 1;
        } else {
            startIndex = index;
            for (x = index; x >= 0; x--) {
                if (_elements[x] == AJRBezierPathElementMoveTo) {
                    startIndex = x;
                    break;
                }
            }
        }
        
        endIndex = startIndex;
        for (x = index; x < _pointCount; x++) {
            if (_elements[x] == AJRBezierPathElementClose) {
                endIndex = x;
                break;
            } else if (_elements[x] == AJRBezierPathElementMoveTo && x != index) {
                endIndex = x - 1;
                break;
            }
        }
        
        if (startIndex != endIndex) {
            clockwise = [self isContourClockwiseFromIndex:startIndex toIndex:endIndex];
        }
    }

    if (startIndexOut) *startIndexOut = startIndex;
    if (endIndexOut) *endIndexOut = endIndex;
    if (clockwiseOut) *clockwiseOut = clockwise;
    
    return endIndex != NSNotFound && endIndex != startIndex;
}

- (void)applyToContext:(CGContextRef)context startingIndex:(NSUInteger)startIndex endingIndex:(NSUInteger)endIndex {
    NSUInteger x;
    
    for (x = startIndex; x <= endIndex; x++) {
        switch (_elements[x]) {
            case AJRBezierPathElementSetBoundingBox:
                break;
            case AJRBezierPathElementMoveTo:
                CGContextMoveToPoint(context, _points[_elementToPointIndex[x]].x, _points[_elementToPointIndex[x]].y);
                break;
            case AJRBezierPathElementLineTo:
                CGContextAddLineToPoint(context, _points[_elementToPointIndex[x]].x, _points[_elementToPointIndex[x]].y);
                break;
            case AJRBezierPathElementCurveTo:
                CGContextAddCurveToPoint(context,
                                         _points[_elementToPointIndex[x] + 0].x, _points[_elementToPointIndex[x] + 0].y,
                                         _points[_elementToPointIndex[x] + 1].x, _points[_elementToPointIndex[x] + 1].y,
                                         _points[_elementToPointIndex[x] + 2].x, _points[_elementToPointIndex[x] + 2].y);
                break;
            case AJRBezierPathElementClose:
                CGContextClosePath(context);
                break;
            default:
                break;
        }
    }
}

- (void)applyToContextReversed:(CGContextRef)context startingIndex:(NSUInteger)startIndex endingIndex:(NSUInteger)endIndex {
    NSInteger x;
    BOOL nextRequiresMoveTo = YES;
    BOOL close = NO;

    for (x = endIndex; x >= startIndex; x--) {
        switch (_elements[x]) {
            case AJRBezierPathElementSetBoundingBox:
                continue;
            case AJRBezierPathElementMoveTo:
                if (close) {
                    CGContextClosePath(context);
                }
                CGContextAddLineToPoint(context, _points[_elementToPointIndex[x]].x, _points[_elementToPointIndex[x]].y);
                nextRequiresMoveTo = YES;
                close = NO;
                break;
            case AJRBezierPathElementLineTo:
                if (nextRequiresMoveTo) {
                    CGContextMoveToPoint(context, _points[_elementToPointIndex[x]].x, _points[_elementToPointIndex[x]].y);
                    nextRequiresMoveTo = NO;
                }
                switch (_elements[x - 1]) {
                    case AJRBezierPathElementSetBoundingBox: break;
                    case AJRBezierPathElementMoveTo:
                        CGContextAddLineToPoint(context, _points[_elementToPointIndex[x - 1]].x, _points[_elementToPointIndex[x  - 1]].y);
                        break;
                    case AJRBezierPathElementLineTo:
                        CGContextAddLineToPoint(context, _points[_elementToPointIndex[x - 1]].x, _points[_elementToPointIndex[x  - 1]].y);
                        break;
                    case AJRBezierPathElementCurveTo:
                        CGContextAddLineToPoint(context, _points[_elementToPointIndex[x - 1] + 2].x, _points[_elementToPointIndex[x  - 1] + 2].y);
                        break;
                    case AJRBezierPathElementClose: break;
                }
                break;
            case AJRBezierPathElementCurveTo:
                if (nextRequiresMoveTo) {
                    CGContextMoveToPoint(context, _points[_elementToPointIndex[x] + 2].x, _points[_elementToPointIndex[x] + 2].y);
                    nextRequiresMoveTo = NO;
                }
                switch (_elements[x - 1]) {
                    case AJRBezierPathElementSetBoundingBox: break;
                    case AJRBezierPathElementMoveTo:
                        CGContextAddCurveToPoint(context,
                                                 _points[_elementToPointIndex[x] + 1].x, _points[_elementToPointIndex[x] + 1].y,
                                                 _points[_elementToPointIndex[x] + 0].x, _points[_elementToPointIndex[x] + 0].y,
                                                 _points[_elementToPointIndex[x - 1]].x, _points[_elementToPointIndex[x - 1]].y);
                        break;
                    case AJRBezierPathElementLineTo:
                        CGContextAddCurveToPoint(context,
                                                 _points[_elementToPointIndex[x] + 1].x, _points[_elementToPointIndex[x] + 1].y,
                                                 _points[_elementToPointIndex[x] + 0].x, _points[_elementToPointIndex[x] + 0].y,
                                                 _points[_elementToPointIndex[x - 1]].x, _points[_elementToPointIndex[x - 1]].y);
                        break;
                    case AJRBezierPathElementCurveTo:
                        CGContextAddCurveToPoint(context,
                                                 _points[_elementToPointIndex[x] + 1].x, _points[_elementToPointIndex[x] + 1].y,
                                                 _points[_elementToPointIndex[x] + 0].x, _points[_elementToPointIndex[x] + 0].y,
                                                 _points[_elementToPointIndex[x - 1] + 2].x, _points[_elementToPointIndex[x - 1] + 2].y);
                        break;
                    case AJRBezierPathElementClose: break;
                }
                break;
            case AJRBezierPathElementClose:
                nextRequiresMoveTo = YES;
                close = YES;
                break;
        }
    }
}

- (void)applyToContext:(CGContextRef)context clockwise:(BOOL)flag {
    NSUInteger startIndex = 0;
    NSUInteger endIndex;
    BOOL clockwise;
    
    if (_pointCount > 2) {
        while ([self getContourContainingIndex:startIndex startingIndex:&startIndex endingIndex:&endIndex clockwise:&clockwise]) {
            if ((flag && clockwise) || (!flag && !clockwise)) {
                [self applyToContext:context startingIndex:startIndex endingIndex:endIndex];
            } else if ((!flag && clockwise) || (flag && !clockwise)) {
                [self applyToContextReversed:context startingIndex:startIndex endingIndex:endIndex];
            }
            startIndex = endIndex + 1;
        }
    }
}

+ (AJRBezierPath *)bezierPathWithLine:(AJRLine)line {
    AJRBezierPath *path = [[AJRBezierPath alloc] init];
    
    [path moveToPoint:line.start];
    [path lineToPoint:line.end];
    
    return path;
}

+ (void)strokeLine:(AJRLine)line {
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, line.start.x, line.start.y);
    CGContextAddLineToPoint(context, line.end.x, line.end.y);
    CGContextStrokePath(context);
}

+ (AJRBezierPath *)bezierPathWithBarbellFromPoint:(CGPoint)start toPoint:(CGPoint)end radius:(CGFloat)radius {
    AJRBezierPath *path = nil;

    if (radius == 0.0) {
        path = [[AJRBezierPath alloc] init];
        [path moveToPoint:start];
        [path lineToPoint:end];
    } else {
        CGFloat angle = AJRArctan(start.y - end.y, start.x - end.x);
        
        path = [[AJRBezierPath alloc] init];
        [path moveToPoint:AJRPointOnOval(start, radius, radius, angle - 90.0)];
        [path appendBezierPathWithArcWithCenter:start radius:radius startAngle:angle - 180.0 endAngle:angle + 180.0 clockwise:NO];
        [path appendBezierPathWithArcWithCenter:end radius:radius startAngle:angle endAngle:angle + 360 clockwise:NO];
        [path closePath];
    }
    
    return path;
}

@end
