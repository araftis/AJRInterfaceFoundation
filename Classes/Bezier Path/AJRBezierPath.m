/*
 AJRBezierPath.m
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

#import "AJRBezierPathP.h"

#import "AJRXMLCoder+Extensions.h"
#import "AJRBezierCurves.h"
#import "AJRBezierPathFunctions.h"
#import "AJRGraphicsUtilities.h"
#import "AJRIntersection.h"
#import "AJRPathEnumerator.h"

#import <AJRFoundation/AJRFoundation.h>

extern void CGContextResetClip(CGContextRef context);

@implementation AJRBezierPath

#pragma mark - Global State

static AJRWindingRule _ajrDefaultWindingRule = AJRWindingRuleNonZero;
static CGFloat _ajrDefaultMiterLimit = 10.0;
static CGFloat _ajrDefaultFlatness = 1.0;
static AJRLineCapStyle _ajrDefaultLineCapStyle = AJRLineCapStyleButt;
static AJRLineJoinStyle _ajrDefaultLineJoinStyle = AJRLineJoinStyleMitered;
static CGFloat _ajrDefaultLineWidth = 1.0;
static CGFloat *_ajrDefaultDashValues = NULL;
static NSInteger _ajrDefaultDashCount = 0;
static CGFloat _ajrDefaultDashOffset = 0.0;

- (instancetype)init {
    if ((self = [super init])) {
        [self _setCoordinateMaxCount:10];
        [self _setOperationMaxCount:9];

        _hasBoundingBox = NO;
        _points[0] = (CGPoint){0.0, 0.0};
        _points[1] = (CGPoint){0.0, 0.0};
        _pointCount = 2;
        _elements[0] = AJRBezierPathElementSetBoundingBox;
        _elementToPointIndex[0] = 0;
        _elementCount = 1;
        _lineWidth = _ajrDefaultLineWidth;
        _miterLimit = _ajrDefaultMiterLimit;
        _flatness = _ajrDefaultFlatness;
        _windingRule = _ajrDefaultWindingRule;
        _lineCapStyle = _ajrDefaultLineCapStyle;
        _lineJoinStyle = _ajrDefaultLineJoinStyle;
    }
    return self;
}

- (void)_setCoordinateMaxCount:(NSUInteger)max {
    _currentMaxPoints = max;
    if (!_points) {
        _points = NSZoneMalloc(nil, _currentMaxPoints * sizeof(CGPoint));
    } else {
        _points = NSZoneRealloc(nil, _points, _currentMaxPoints * sizeof(CGPoint));
    }
}

- (void)_increaseCoordinateCountBy:(NSUInteger)count {
    NSInteger temp = _currentMaxPoints;
    
    while (temp < _pointCount + count) {
        temp += 8;
    }
    
    [self _setCoordinateMaxCount:temp];
}

- (void)_setOperationMaxCount:(NSUInteger)max {
    if (_currentMaxElements != max) {
        _currentMaxElements = max;
        if (!_elements) {
            _elements = NSZoneMalloc(nil, _currentMaxElements * sizeof(AJRBezierPathElementType));
            _elementToPointIndex = NSZoneMalloc(nil, _currentMaxElements * sizeof(NSUInteger));
        } else {
            _elements = NSZoneRealloc(nil, _elements, _currentMaxElements * sizeof(AJRBezierPathElementType));
            _elementToPointIndex = NSZoneRealloc(nil, _elementToPointIndex, _currentMaxElements * sizeof(NSUInteger));
        }
    }
}

- (void)_increaseOperationCountBy:(NSUInteger)count {
    NSInteger temp = _currentMaxElements;
    
    while (temp < _elementCount + count) {
        temp += 8;
    }
    
    [self _setOperationMaxCount:temp];
}

- (void)_unionRectWithBoundingBox:(CGRect)rect {
    if (_hasBoundingBox) {
        if (_points[0].x > rect.origin.x) {
            _points[0].x = rect.origin.x;
        }
        if (_points[0].y > rect.origin.y) {
            _points[0].y = rect.origin.y;
        }
        if (_points[1].x < rect.origin.x + rect.size.width) {
            _points[1].x = rect.origin.x + rect.size.width;
        }
        if (_points[1].y < rect.origin.y + rect.size.height) {
            _points[1].y = rect.origin.y + rect.size.height;
        }
    } else {
        _hasBoundingBox = YES;
        _points[0] = rect.origin;
        _points[1] = (CGPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height};
    }
}

- (void)_intersectPointWithBounds:(CGPoint)aPoint forMoveTo:(BOOL)flag {
    if (flag && (_elementCount <= 2)) {
        _points[0] = aPoint;
        _points[1] = aPoint;
        _hasBoundingBox = YES;
    } else {
        if (_points[0].x > aPoint.x) {
            _points[0].x = aPoint.x;
        }
        if (_points[0].y > aPoint.y) {
            _points[0].y = aPoint.y;
        }
        if (_points[1].x < aPoint.x) {
            _points[1].x = aPoint.x;
        }
        if (_points[1].y < aPoint.y) {
            _points[1].y = aPoint.y;
        }
    }
    [self setBoundsAreValid:NO];
}

- (void)_updateBoundingBox {
    NSInteger x;
    
    if (_pointCount > 2) {
        _points[0] = _points[2];
        _points[1] = _points[2];
        for (x = 3; x < _pointCount; x++) {
            if (_points[0].x > _points[x].x) {
                _points[0].x = _points[x].x;
            }
            if (_points[0].y > _points[x].y) {
                _points[0].y = _points[x].y;
            }
            if (_points[1].x < _points[x].x) {
                _points[1].x = _points[x].x;
            }
            if (_points[1].y < _points[x].y) {
                _points[1].y = _points[x].y;
            }
        }
        _hasBoundingBox = YES;
    } else {
        _hasBoundingBox = NO;
    }
    [self setBoundsAreValid:NO];
}

// Not thread safe!
//+ (AJRBezierPath *)_bezierPathWithRect:(CGRect)rect {
//    static AJRBezierPath *path = nil;
//
//    if (!path) {
//        path = [[AJRBezierPath alloc] initWithRect:rect];
//    } else {
//        path->_points[2] = rect.origin;
//        path->_points[3] = (CGPoint){rect.origin.x, rect.origin.y + rect.size.height};
//        path->_points[4] = (CGPoint){rect.origin.x + rect.size.height, rect.origin.y + rect.size.height};
//        path->_points[5] = (CGPoint){rect.origin.x + rect.size.height, rect.origin.y};
//    }
//
//    return path;
//}

+ (instancetype)bezierPath {
    return [[self allocWithZone:NULL] init];
}

+ (instancetype)bezierPathWithRect:(CGRect)rect {
    AJRBezierPath *path = [self performSelector:@selector(bezierPath)];
    [path appendBezierPathWithRect:rect];
    return path;
}

+ (instancetype)bezierPathWithOvalInRect:(CGRect)rect {
    AJRBezierPath *path = [self performSelector:@selector(bezierPath)];
    [path appendBezierPathWithOvalInRect:rect];
    return path;
}

+ (instancetype)bezierPathWithCrossedRect:(CGRect)rect {
    AJRBezierPath *path = [AJRBezierPath bezierPath];
    
    [path moveToPoint:(CGPoint){rect.origin.x, rect.origin.y}];
    [path lineToPoint:(CGPoint){rect.origin.x, rect.origin.y + rect.size.height}];
    [path lineToPoint:(CGPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height}];
    [path lineToPoint:(CGPoint){rect.origin.x + rect.size.width, rect.origin.y}];
    [path closePath];
    [path moveToPoint:(CGPoint){rect.origin.x, rect.origin.y}];
    [path lineToPoint:(CGPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height}];
    [path moveToPoint:(CGPoint){rect.origin.x, rect.origin.y + rect.size.height}];
    [path lineToPoint:(CGPoint){rect.origin.x + rect.size.width, rect.origin.y}];
    
    return path;
}

+ (instancetype)bezierPathWithRoundedRect:(NSRect)rect xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius {
    AJRBezierPath *path = [AJRBezierPath bezierPath];
    [path appendBezierPathWithRoundedRect:rect xRadius:xRadius yRadius:yRadius];
    return path;
}

// Appending paths and some common shapes
- (void)appendBezierPath:(AJRBezierPath *)path {
    NSInteger x;
    
    [self _increaseOperationCountBy:path->_elementCount - 1];
    [self _increaseCoordinateCountBy:path->_pointCount - 2];
    
    memcpy(_elements + _elementCount,
           path->_elements + 1,
           sizeof(AJRBezierPathElementType) * (path->_elementCount - 1));
    memcpy(_elementToPointIndex + _elementCount,
           path->_elementToPointIndex + 1,
           sizeof(NSUInteger) * (path->_elementCount - 1));
    memcpy(_points + _pointCount,
           path->_points + 2,
           sizeof(CGPoint) * (path->_pointCount - 2));
    
    for (x = _elementCount; x < _elementCount + path->_elementCount - 1; x++) {
        _elementToPointIndex[x] += _pointCount - 2;
    }
    
    _elementCount += (path->_elementCount - 1);
    _pointCount += (path->_pointCount - 2);
    
    if (path->_hasCurves) {
        _hasCurves = YES;
    }
    
    if (path->_hasBoundingBox) {
        if (_hasBoundingBox) {
            if (_points[0].x > path->_points[0].x) {
                _points[0].x = path->_points[0].x;
            }
            if (_points[0].y > path->_points[0].y) {
                _points[0].y = path->_points[0].y;
            }
            if (_points[1].x < path->_points[1].x) {
                _points[1].x = path->_points[1].x;
            }
            if (_points[1].y < path->_points[1].y) {
                _points[1].y = path->_points[1].y;
            }
        } else {
            _points[0] = path->_points[0];
            _points[1] = path->_points[1];
        }
    }
    
    [self setBoundsAreValid:NO];
}

// Contructing paths
static inline void AJR_UNUSED _ajrCheckFrame(CGRect *frame, CGPoint *point) {
    if (point->x < frame->origin.x) {
        frame->size.width += (frame->origin.x - point->x);
        frame->origin.x = point->x;
    } else if (point->x > frame->origin.x + frame->size.width) {
        frame->size.width = point->x - frame->origin.x;
    }
    if (point->y < frame->origin.y) {
        frame->size.height += (frame->origin.y - point->y);
        frame->origin.y = point->y;
    } else if (point->y > frame->origin.y + frame->size.height) {
        frame->size.height = point->y - frame->origin.y;
    }
}

- (void)appendBezierPathWithArcWithCenter:(CGPoint)origin radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise {
    CGRect arcBounds;
    
    arcBounds.origin.x = origin.x - radius;
    arcBounds.origin.y = origin.y - radius;
    arcBounds.size.width = arcBounds.size.height = radius * 2.0;
    
    [self appendBezierPathWithArcBoundedByRect:arcBounds startAngle:startAngle endAngle:endAngle clockwise:clockwise];
    
    [self setBoundsAreValid:NO];
}

- (void)appendBezierPathWithArcWithCenter:(CGPoint)origin radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    CGRect arcBounds;
    
    arcBounds.origin.x = origin.x - radius;
    arcBounds.origin.y = origin.y - radius;
    arcBounds.size.width = arcBounds.size.height = radius * 2.0;
    
    [self appendBezierPathWithArcBoundedByRect:arcBounds startAngle:startAngle endAngle:endAngle clockwise:NO];
    
    [self setBoundsAreValid:NO];
}

- (void)_drawPoint:(CGPoint)point : (NSString *)name {
    CGPoint t = [self currentPoint];
    [self moveToPoint:(CGPoint){point.x + 3, point.y}];
    [self appendBezierPathWithArcWithCenter:point radius:3.0 startAngle:0.0 endAngle:360.0];
    [self moveToPoint:t];
}

- (void)_drawLine:(AJRLine)line {
    CGPoint    t = [self currentPoint];
    [self moveToPoint:line.start];
    [self lineToPoint:line.end];
    [self moveToPoint:t];
}

- (void)_appendBezierPathWithArcFromPoint:(CGPoint)point1
                                  toPoint:(CGPoint)point2
                                   radius:(CGFloat)radius
                                  pointT1:(CGPoint *)pointT1
                                  pointT2:(CGPoint *)pointT2 {
    CGPoint t0, t2;
    CGPoint currentPoint = [self currentPoint];
    
    /* Now we have to compute the tangent points. */
    /* Basically, the idea is to compute the tangent */
    /* of the bisector by using tan(x+y) and tan(z/2) */
    /* formulas, without ever using any trig. */
    CGPoint    d0 = { currentPoint.x - point1.x, currentPoint.y - point1.y };
    CGPoint    d2 = { point2.x - point1.x, point2.y - point1.y };
    
    /* Compute the squared lengths from p1 to p0 and p2. */
    double sql0 = d0.x * d0.x + d0.y * d0.y;
    double sql2 = d2.x * d2.x + d2.y * d2.y;
    
    /* Compute the distance from p1 to the tangent points. */
    /* This is the only messy part. */
    double num = d0.y * d2.x - d2.y * d0.x;
    double denom = sqrt(sql0 * sql2) - (d0.x * d2.x + d0.y * d2.y);
    
    /* Check for collinear points. */
    if (denom == 0) {
        [self lineToPoint:point1];
        if (pointT1) *pointT1 = point1;
        if (pointT2) *pointT2 = point1;
    } else {
        /* not collinear */
        double    dist = fabs(radius * num / denom);
        double    l0 = dist / sqrt(sql0), l2 = dist / sqrt(sql2);
        CGPoint    center;
        AJRLine    line1, line2;
        double    a1, a2;
        
        if (radius < 0) {
            l0 = -l0;
            l2 = -l2;
        }
        
        t0.x = point1.x + d0.x * l0;
        t0.y = point1.y + d0.y * l0;
        t2.x = point1.x + d2.x * l2;
        t2.y = point1.y + d2.y * l2;
        
        line1 = (AJRLine){t0, point1};
        line1 = AJRPerpendicularLine(line1);
        
        line2 = (AJRLine){t2, point1};
        line2 = AJRPerpendicularLine(line2);
        
        AJRLineIntersection(line1, line2, NO, &center);
        
        a1 = AJRArctan(point1.y - currentPoint.y, point1.x - currentPoint.x);
        a2 = AJRArctan(point2.y - point1.y, point2.x - point1.x);
        if (a1 == 0.0 && point2.y < currentPoint.y) a1 = 360.0;
        if (a2 == 0.0 && point1.y < currentPoint.y) a2 = 360.0;
        //AJRPrintf(@"%.1f %.1f: %@\n", a1, a2, a1 > a2 ? @"YES" : @"NO" );
        
        if (a1 > a2) {
            [self appendBezierPathWithArcWithCenter:center radius:radius startAngle:a1 + 90.0 endAngle:a2 + 90.0 clockwise:YES];
        } else {
            [self appendBezierPathWithArcWithCenter:center radius:radius startAngle:a1 - 90.0 endAngle:a2 - 90.0 clockwise:NO];
        }
        
        if (pointT1) {
            pointT1->x = t0.x;
            pointT1->y = t0.y;
        }
        if (pointT2) {
            pointT2->x = t2.x;
            pointT2->y = t2.y;
        }
    }
}

- (void)appendBezierPathWithArcFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2 radius:(CGFloat)radius {
    [self _appendBezierPathWithArcFromPoint:point1
                                    toPoint:point2
                                     radius:radius
                                    pointT1:NULL
                                    pointT2:NULL];
    
    [self setBoundsAreValid:NO];
}

- (void)appendBezierPathWithCGGlyph:(CGGlyph)aGlyph inFont:(NSFont *)fontObj {
    [self appendBezierPathWithCGGlyphs:&aGlyph count:1 inFont:fontObj];
    
    [self setBoundsAreValid:NO];
}

- (void)_appendBezierPath:(NSBezierPath *)path {
    NSInteger x, max;
    CGPoint somePoints[4];
    
    for (x = 0, max = [path elementCount]; x < max; x++) {
        switch ([path elementAtIndex:x associatedPoints:somePoints]) {
            case NSBezierPathElementMoveTo:
                [self moveToPoint:somePoints[0]];
                break;
            case NSBezierPathElementLineTo:
                [self lineToPoint:somePoints[0]];
                break;
            case NSBezierPathElementCurveTo:
                [self curveToPoint:somePoints[2] controlPoint1:somePoints[0] controlPoint2:somePoints[1]];
                break;
            case NSBezierPathElementClosePath:
                [self closePath];
                break;
        }
    }
    
    [self setBoundsAreValid:NO];
}

static NSImage *_ajrHack = nil;

- (void)appendBezierPathWithCGGlyphs:(CGGlyph *)glyphs count:(NSInteger)count inFont:(NSFont *)fontObj {
    NSBezierPath *path = [[NSBezierPath alloc] init];
    
    if (_ajrHack == nil) {
        _ajrHack = [[NSImage alloc] initWithSize:(CGSize){10, 10}];
    }
    
    [_ajrHack lockFocus];
    [path moveToPoint:[self currentPoint]];
    [path appendBezierPathWithCGGlyphs:glyphs count:count inFont:fontObj];
    [_ajrHack unlockFocus];
    
    [self _appendBezierPath:path];
}

- (void)appendBezierPathWithOvalInRect:(CGRect)rect {
    CGFloat fractionHeight;
    CGFloat fractionWidth;
    
    fractionHeight = rect.size.height * .224225;
    fractionWidth = rect.size.width * .224225;
    
    [self _increaseOperationCountBy:6];
    _elements[_elementCount + 0] = AJRBezierPathElementMoveTo;
    _elements[_elementCount + 1] = AJRBezierPathElementCurveTo;
    _elements[_elementCount + 2] = AJRBezierPathElementCurveTo;
    _elements[_elementCount + 3] = AJRBezierPathElementCurveTo;
    _elements[_elementCount + 4] = AJRBezierPathElementCurveTo;
    _elements[_elementCount + 5] = AJRBezierPathElementClose;
    
    [self _increaseCoordinateCountBy:13];
    
    _elementToPointIndex[_elementCount + 0] = _pointCount;
    _moveToOffset = _pointCount;
    _points[_pointCount + 0].x = rect.origin.x + rect.size.width;
    _points[_pointCount + 0].y = rect.origin.y + rect.size.height / 2.0;
    
    _elementToPointIndex[_elementCount + 1] = _pointCount + 1;
    _points[_pointCount + 1].x = rect.origin.x + rect.size.width;
    _points[_pointCount + 1].y = rect.origin.y + rect.size.height - fractionHeight;
    _points[_pointCount + 2].x = rect.origin.x + rect.size.width - fractionWidth;
    _points[_pointCount + 2].y = rect.origin.y + rect.size.height;
    _points[_pointCount + 3].x = rect.origin.x + rect.size.width / 2.0;
    _points[_pointCount + 3].y = rect.origin.y + rect.size.height;
    
    _elementToPointIndex[_elementCount + 2] = _pointCount + 4;
    _points[_pointCount + 4].x = rect.origin.x + fractionWidth;
    _points[_pointCount + 4].y = rect.origin.y + rect.size.height;
    _points[_pointCount + 5].x = rect.origin.x;
    _points[_pointCount + 5].y = rect.origin.y + rect.size.height - fractionHeight;
    _points[_pointCount + 6].x = rect.origin.x;
    _points[_pointCount + 6].y = rect.origin.y + rect.size.height / 2.0;
    
    _elementToPointIndex[_elementCount + 3] = _pointCount + 7;
    _points[_pointCount + 7].x = rect.origin.x;
    _points[_pointCount + 7].y = rect.origin.y + fractionHeight;
    _points[_pointCount + 8].x = rect.origin.x + fractionWidth;
    _points[_pointCount + 8].y = rect.origin.y;
    _points[_pointCount + 9].x = rect.origin.x + rect.size.width / 2.0;
    _points[_pointCount + 9].y = rect.origin.y;
    
    _elementToPointIndex[_elementCount + 4] = _pointCount + 10;
    _points[_pointCount + 10].x = rect.origin.x + rect.size.width - fractionWidth;
    _points[_pointCount + 10].y = rect.origin.y;
    _points[_pointCount + 11].x = rect.origin.x + rect.size.width;
    _points[_pointCount + 11].y = rect.origin.y + fractionHeight;
    _points[_pointCount + 12].x = rect.origin.x + rect.size.width;
    _points[_pointCount + 12].y = rect.origin.y + rect.size.height / 2.0;
    
    _elementToPointIndex[_elementCount + 5] = _pointCount;
    
    _elementCount += 6;
    _pointCount += 13;
    
    [self _unionRectWithBoundingBox:rect];
    
    [self setBoundsAreValid:NO];
}

- (void)appendBezierPathWithPoints:(CGPoint *)somePoints count:(NSInteger)count {
    NSInteger index;
    BOOL addMoveTo = NO;
    NSInteger offset = 0;
    
    [self _increaseCoordinateCountBy:count];
    [self _increaseOperationCountBy:count];
    
    addMoveTo = _pointCount == 2;
    
    if (!addMoveTo) {
        if (_elements[_elementCount - 1] == AJRBezierPathElementClose) {
            offset = -1;
        }
    }
    
    for (index = 0; index < count; index++) {
        _points[_pointCount] = somePoints[index];
        if (addMoveTo) {
            addMoveTo = NO;
            _elements[_elementCount + offset] = AJRBezierPathElementMoveTo;
            _moveToOffset = _pointCount;
        } else {
            _elements[_elementCount + offset] = AJRBezierPathElementLineTo;
        }
        _elementToPointIndex[_elementCount + offset] = _pointCount;
        _pointCount++;
        _elementCount++;
        
        if (_hasBoundingBox) {
            if (_points[0].x > somePoints[index].x) {
                _points[0].x = somePoints[index].x;
            }
            if (_points[0].y > somePoints[index].y) {
                _points[0].y = somePoints[index].y;
            }
            if (_points[1].x < somePoints[index].x) {
                _points[1].x = somePoints[index].x;
            }
            if (_points[1].y < somePoints[index].y) {
                _points[1].y = somePoints[index].y;
            }
        } else {
            _points[0] = somePoints[index];
            _points[1] = somePoints[index];
        }
    }
    if (offset) {
        _elements[_elementCount - 1] = AJRBezierPathElementClose;
        _elementToPointIndex[_elementCount - 1] = _moveToOffset;
    }
    
    [self setBoundsAreValid:NO];
}

- (void)appendBezierPathWithRect:(CGRect)rect {
    [self _increaseCoordinateCountBy:4];
    _points[_pointCount + 0] = rect.origin;
    _points[_pointCount + 1] = (CGPoint){rect.origin.x, rect.origin.y + rect.size.height};
    _points[_pointCount + 2] = (CGPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height};
    _points[_pointCount + 3] = (CGPoint){rect.origin.x + rect.size.width, rect.origin.y};
    
    [self _increaseOperationCountBy:5];
    _elements[_elementCount + 0] = AJRBezierPathElementMoveTo;
    _elementToPointIndex[_elementCount + 0] = _pointCount + 0;
    _moveToOffset = _pointCount;
    _elements[_elementCount + 1] = AJRBezierPathElementLineTo;
    _elementToPointIndex[_elementCount + 1] = _pointCount + 1;
    _elements[_elementCount + 2] = AJRBezierPathElementLineTo;
    _elementToPointIndex[_elementCount + 2] = _pointCount + 2;
    _elements[_elementCount + 3] = AJRBezierPathElementLineTo;
    _elementToPointIndex[_elementCount + 3] = _pointCount + 3;
    _elements[_elementCount + 4] = AJRBezierPathElementClose;
    _elementToPointIndex[_elementCount + 4] = _moveToOffset;
    
    _pointCount += 4;
    _elementCount += 5;
    
    [self _unionRectWithBoundingBox:rect];
    [self setBoundsAreValid:NO];
}

- (void)appendBezierPathWithRoundedRect:(NSRect)rect xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius {
    CGRect bezierBounds;
    AJRBezierCurve bezier;
    CGFloat xDiameter = xRadius * 2.0;
    CGFloat yDiameter = yRadius * 2.0;

    if (xRadius == 0.0 || yRadius == 0) {
        [self appendBezierPathWithRect:rect];
    } else {
        [self _intersectPointWithBounds:(CGPoint){rect.origin.x, rect.origin.y} forMoveTo:YES];
        [self _intersectPointWithBounds:(CGPoint){rect.origin.x + rect.size.width, rect.origin.y} forMoveTo:NO];
        [self _intersectPointWithBounds:(CGPoint){rect.origin.x + rect.size.width, rect.origin.y + rect.size.height} forMoveTo:NO];
        [self _intersectPointWithBounds:(CGPoint){rect.origin.x, rect.origin.y + rect.size.height} forMoveTo:NO];

        [self _increaseOperationCountBy:9];
        [self _increaseCoordinateCountBy:16];

        bezierBounds.size.width = xDiameter;
        bezierBounds.size.height = yDiameter;

        _elements[_elementCount + 0] = AJRBezierPathElementMoveTo;
        _elements[_elementCount + 1] = AJRBezierPathElementCurveTo;
        _elements[_elementCount + 2] = AJRBezierPathElementLineTo;
        _elements[_elementCount + 3] = AJRBezierPathElementCurveTo;
        _elements[_elementCount + 4] = AJRBezierPathElementLineTo;
        _elements[_elementCount + 5] = AJRBezierPathElementCurveTo;
        _elements[_elementCount + 6] = AJRBezierPathElementLineTo;
        _elements[_elementCount + 7] = AJRBezierPathElementCurveTo;
        _elements[_elementCount + 8] = AJRBezierPathElementClose;
        _elementToPointIndex[_elementCount + 8] = _pointCount + 0;

        // curveto
        bezierBounds.origin.x = rect.origin.x;
        bezierBounds.origin.y = rect.origin.y;
        bezier = AJRBezierFromArc(bezierBounds, 180.0, 270.0);
        _points[_pointCount + 0] = bezier.start;                    // moveto
        _elementToPointIndex[_elementCount + 0] = _pointCount + 0;
        _points[_pointCount + 1] = bezier.handle1;
        _points[_pointCount + 2] = bezier.handle2;
        _points[_pointCount + 3] = bezier.end;
        _elementToPointIndex[_elementCount + 1] = _pointCount + 1;

        // lineto
        _points[_pointCount + 4].x = rect.origin.x + rect.size.width - xRadius;
        _points[_pointCount + 4].y = rect.origin.y;
        _elementToPointIndex[_elementCount + 2] = _pointCount + 4;

        // curveto
        bezierBounds.origin.x = rect.origin.x + rect.size.width - xDiameter;
        bezierBounds.origin.y = rect.origin.y;
        bezier = AJRBezierFromArc(bezierBounds, 270.0, 360.0);
        _points[_pointCount + 5] = bezier.handle1;
        _points[_pointCount + 6] = bezier.handle2;
        _points[_pointCount + 7] = bezier.end;
        _elementToPointIndex[_elementCount + 3] = _pointCount + 5;

        // lineto
        _points[_pointCount + 8].x = rect.origin.x + rect.size.width;
        _points[_pointCount + 8].y = rect.origin.y + rect.size.height - yRadius;
        _elementToPointIndex[_elementCount + 4] = _pointCount + 8;

        // curveto
        bezierBounds.origin.x = rect.origin.x + rect.size.width - xDiameter;
        bezierBounds.origin.y = rect.origin.y + rect.size.height - yDiameter;
        bezier = AJRBezierFromArc(bezierBounds, 0.0, 90.0);
        _points[_pointCount + 9] = bezier.handle1;
        _points[_pointCount + 10] = bezier.handle2;
        _points[_pointCount + 11] = bezier.end;
        _elementToPointIndex[_elementCount + 5] = _pointCount + 9;

        // lineto
        _points[_pointCount + 12].x = rect.origin.x + xRadius;
        _points[_pointCount + 12].y = rect.origin.y + rect.size.height;
        _elementToPointIndex[_elementCount + 6] = _pointCount + 12;

        // curveto
        bezierBounds.origin.x = rect.origin.x;
        bezierBounds.origin.y = rect.origin.y + rect.size.height - yDiameter;
        bezier = AJRBezierFromArc(bezierBounds, 90.0, 180.0);
        _points[_pointCount + 13] = bezier.handle1;
        _points[_pointCount + 14] = bezier.handle2;
        _points[_pointCount + 15] = bezier.end;
        _elementToPointIndex[_elementCount + 7] = _pointCount + 13;

        _pointCount += 16;
        _elementCount += 9;

        [self setBoundsAreValid:NO];
    }
}

// Clipping paths
- (void)addClip {
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    
    if (_elementCount <= 1) return;
    CGContextSetFlatness(context, _flatness);
    if (_windingRule == AJRWindingRuleNonZero) {
        AJRclip(context, _points, _pointCount, _elements, _elementCount);
    } else {
        AJReoclip(context, _points, _pointCount, _elements, _elementCount);
    }
}

- (void)setClip {
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextResetClip(context);
    [self addClip];
}

+ (void)clipRect:(CGRect)rect {
    CGContextRef    context = [[NSGraphicsContext currentContext] CGContext];
    CGContextClipToRect(context, (CGRect){{rect.origin.x, rect.origin.y}, {rect.size.width, rect.size.height}});
}

// Drawing paths
- (void)fill {
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    
    if (_elementCount <= 1) return;
    
    CGContextSetFlatness(context, _flatness);
    if (_windingRule == AJRWindingRuleNonZero) {
        AJRfill(context, _points, _pointCount, _elements, _elementCount, _fillPointTransform);
    } else {
        AJReofill(context, _points, _pointCount, _elements, _elementCount, _fillPointTransform);
    }
}

- (void)_setupDrawingContext:(CGContextRef)context {
    CGContextSetMiterLimit(context, _miterLimit);
    CGContextSetFlatness(context, _flatness);
    CGContextSetLineCap(context, (CGLineCap)_lineCapStyle);
    CGContextSetLineJoin(context, (CGLineJoin)_lineJoinStyle);
    CGContextSetLineDash(context, _dashOffset, _dashValues, _dashCount);
    CGContextSetLineWidth(context, _lineWidth);
}

- (void)stroke {
    CGContextRef context;
    NSGraphicsContext *graphicsContext;
    BOOL drawingToScreen;
    
    if (_elementCount <= 1) return;
    
    graphicsContext = [NSGraphicsContext currentContext];
    context = [graphicsContext CGContext];
    drawingToScreen = [graphicsContext isDrawingToScreen];

    [self _setupDrawingContext:context];
    if (drawingToScreen && (_lineWidth == AJRHairLineWidth)) {
        CGFloat xScale, yScale;
        AJRGetCurrentScales(&xScale, &yScale);
        CGContextSetLineWidth(context, 1.0 / xScale);
    } else {
        /*   
         if (drawingToScreen && (NSInteger)rint(_lineWidth) % 2) {
         CGFloat xScale, yScale;
         
         [NSAffineTransform getCurrentXScale:&xScale yScale:&yScale];
         xAdjust = 1.0 / xScale / 2.0;
         yAdjust = 1.0 / yScale / 2.0;
         }
         */
        if (!drawingToScreen && _lineWidth == AJRHairLineWidth) {
            CGContextSetLineWidth(context, 0.1);
        } else {
            CGContextSetLineWidth(context, _lineWidth);
        }
    }
    CGContextSetFlatness(context, _flatness);
    
    AJRstroke(context, _points, _pointCount, _elements, _elementCount, _strokePointTransform);
}

+ (void)drawPackedGlyphs:(const char *)packedGlyphs atPoint:(CGPoint)aPoint {
    [NSBezierPath drawPackedGlyphs:packedGlyphs atPoint:aPoint];
}

+ (void)fillRect:(CGRect)rect {
    [NSBezierPath fillRect:rect];
}

+ (void)strokeLineFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2 {
    NSBezierPath.defaultLineWidth = _ajrDefaultLineWidth;
    [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
}

+ (void)strokeRect:(CGRect)rect {
    [NSBezierPath strokeRect:rect];
}

// Setting attributes
- (void)setWindingRule:(AJRWindingRule)aWindingRule {
    _windingRule = aWindingRule;
}

- (void)setFlatness:(CGFloat)aFlatness {
    _flatness = aFlatness;
}

- (void)setLineCapStyle:(AJRLineCapStyle)lineCap {
    _lineCapStyle = lineCap;
}

- (void)setLineJoinStyle:(AJRLineJoinStyle)lineJoinStyle {
    _lineJoinStyle = lineJoinStyle;
    [self setBoundsAreValid:NO];
}

- (void)setLineWidth:(CGFloat)width {
    _lineWidth = width;
    [self setBoundsAreValid:NO];
}

- (void)setMiterLimit:(CGFloat)limit {
    _miterLimit = limit;
    [self setBoundsAreValid:NO];
}

- (void)setLineDash:(CGFloat *)values count:(NSInteger)count phase:(CGFloat)phase {
    if (_dashValues) {
        NSZoneFree(nil, _dashValues);
    }
    if (values) {
        _dashValues = NSZoneMalloc(nil, sizeof(CGFloat) * count);
        memcpy(_dashValues, values, sizeof(CGFloat) * count);
        _dashCount = count;
        _dashOffset = phase;
    } else {
        _dashValues = NULL;
        _dashCount = 0;
        _dashOffset = 0.0;
    }
}

- (void)getLineDash:(CGFloat *)values count:(NSInteger *)count phase:(CGFloat *)phase {
    if (_dashValues && values) {
        memcpy(values, _dashValues, sizeof(CGFloat) * _dashCount);
    }
    AJRSetOutParameter(count, _dashCount);
    AJRSetOutParameter(phase, _dashOffset);
}

+ (void)setDefaultWindingRule:(AJRWindingRule)aWindingRule {
    _ajrDefaultWindingRule = AJRWindingRuleNonZero;
}

+ (AJRWindingRule)defaultWindingRule {
    return _ajrDefaultWindingRule;
}

+ (void)setDefaultFlatness:(CGFloat)aFlatness {
    _ajrDefaultFlatness = aFlatness;
}

+ (CGFloat)defaultFlatness {
    return _ajrDefaultFlatness;
}

+ (void)setDefaultLineCapStyle:(AJRLineCapStyle)aLineCap {
    _ajrDefaultLineCapStyle = aLineCap;
}

+ (AJRLineCapStyle)defaultLineCapStyle {
    return _ajrDefaultLineCapStyle;
}

+ (void)setDefaultLineJoinStyle:(AJRLineJoinStyle)aLineJoinStyle {
    _ajrDefaultLineJoinStyle = aLineJoinStyle;
}

+ (AJRLineJoinStyle)defaultLineJoinStyle {
    return _ajrDefaultLineJoinStyle;
}

+ (void)setDefaultLineWidth:(CGFloat)width {
    _ajrDefaultLineWidth = width;
}

+ (CGFloat)defaultLineWidth {
    return _ajrDefaultLineWidth;
}

+ (void)setDefaultMiterLimit:(CGFloat)limit {
    _ajrDefaultMiterLimit = limit;
}

+ (CGFloat)defaultMiterLimit {
    return _ajrDefaultMiterLimit;
}

+ (void)setDefaultLineDash:(CGFloat *)values count:(NSInteger)count phase:(CGFloat)phase {
    if (_ajrDefaultDashValues) {
        NSZoneFree(nil, _ajrDefaultDashValues);
    }
    if (values) {
        _ajrDefaultDashValues = NSZoneMalloc(nil, sizeof(CGFloat) * count);
        memcpy(_ajrDefaultDashValues, values, sizeof(CGFloat) * count);
        _ajrDefaultDashCount = count;
        _ajrDefaultDashOffset = phase;
    } else {
        _ajrDefaultDashValues = NULL;
        _ajrDefaultDashCount = 0;
        _ajrDefaultDashOffset = 0.0;
    }
}

+ (void)getDefaultLineDash:(CGFloat *)values count:(NSInteger *)count phase:(CGFloat *)phase {
    if (_ajrDefaultDashValues) {
        memcpy(values, _ajrDefaultDashValues, sizeof(CGFloat) * _ajrDefaultDashCount);
    }
    *count = _ajrDefaultDashCount;
    *phase = _ajrDefaultDashOffset;
}

#pragma mark - Hit detection

CGContextRef AJRHitTestContext(void) {
    typedef union {
        uint8_t bytes[4];
        struct {
            uint8_t r, g, b ,a;
        } components;
    } AJRSinglePixelRGBA8Bitmap;
    static AJRSinglePixelRGBA8Bitmap bitmap = {.components = { 0, 0, 0, 0 }};
    static CGContextRef context = NULL;
    
    if (context == NULL) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        context = CGBitmapContextCreate(bitmap.bytes, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colorSpace);
    }
    
    return context;
}

- (BOOL)isHitByPath:(AJRBezierPath *)path {
    // Maybe find a better way to do this? Right now, I'm just checking to see if the path's bounds intersect.
    CGPathRef path1;
    CGPathRef path2;
    // NOTE: It's a bit heavy handed to get teh stroke path, but in the case where the path's width or height is 0, the CGPathIntersectsPath() function will return NO, even thought the "line" of the path does, in fact, intersect. This is because, presumably, the method is based on fills.
    if (self.isClosed) {
        path1 = self.CGPath;
    } else {
        path1 = self.bezierPathFromStrokedPath.CGPath;
    }
    if (path.isClosed) {
        path2 = path.CGPath;
    } else {
        path2 = path.bezierPathFromStrokedPath.CGPath;
    }
    return CGPathIntersectsPath(path1, path2, NO);
}

- (BOOL)isHitByPoint:(CGPoint)aPoint {
    CGContextRef context = AJRHitTestContext();
    BOOL hit;
    
    [self _setupDrawingContext:context];
    if ([self windingRule] == AJRWindingRuleNonZero) {
        AJRinfill(context, aPoint.x, aPoint.y, _points, _pointCount, _elements, _elementCount, &hit);
    } else {
        AJRineofill(context, aPoint.x, aPoint.y, _points, _pointCount, _elements, _elementCount, &hit);
    }
    
    return hit;
}

- (BOOL)isHitByRect:(CGRect)rect {
    return [self isHitByPath:[AJRBezierPath bezierPathWithRect:rect]];
}

- (BOOL)isStrokeHitByPath:(AJRBezierPath *)path {
    return NO;
}

- (BOOL)isStrokeHitByPoint:(CGPoint)aPoint {
    CGContextRef context = AJRHitTestContext();
    BOOL hit;
    
    [self _setupDrawingContext:context];
    if (self.lineWidth < 4.0) {
        CGContextSetLineWidth(context, 4.0);
    }
    AJRinstroke(context, aPoint.x, aPoint.y, _points, _pointCount, _elements, _elementCount, &hit);
    
    return hit;
}

- (BOOL)isStrokeHitByRect:(CGRect)rect {
    return NO;
}

- (void)curveToPoint:(CGPoint)aPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2 {
    NSInteger offset;
    
    [self _intersectPointWithBounds:aPoint forMoveTo:NO];
    [self _intersectPointWithBounds:controlPoint1 forMoveTo:NO];
    [self _intersectPointWithBounds:controlPoint2 forMoveTo:NO];
    
    offset = _elements[_elementCount - 1] == AJRBezierPathElementClose ? -1 : 0;
    
    [self _increaseOperationCountBy:1];
    [self _increaseCoordinateCountBy:3];
    _elements[_elementCount + offset] = AJRBezierPathElementCurveTo;
    _elementToPointIndex[_elementCount + offset] = _pointCount;
    _points[_pointCount + 0] = controlPoint1;
    _points[_pointCount + 1] = controlPoint2;
    _points[_pointCount + 2] = aPoint;
    _elementCount++;
    _pointCount += 3;
    
    if (offset == -1) {
        _elements[_elementCount - 1] = AJRBezierPathElementClose;
        _elementToPointIndex[_elementCount - 1] = _moveToOffset;
    }
}

- (void)lineToPoint:(CGPoint)aPoint {
    NSInteger offset;
    
    [self _intersectPointWithBounds:aPoint forMoveTo:NO];
    
    offset = _elements[_elementCount - 1] == AJRBezierPathElementClose ? -1 : 0;
    
    [self _increaseOperationCountBy:1];
    [self _increaseCoordinateCountBy:1];
    _elements[_elementCount + offset] = AJRBezierPathElementLineTo;
    _elementToPointIndex[_elementCount + offset] = _pointCount;
    _points[_pointCount] = aPoint;
    _elementCount++;
    _pointCount++;
    
    if (offset == -1) {
        _elements[_elementCount - 1] = AJRBezierPathElementClose;
        _elementToPointIndex[_elementCount - 1] = _moveToOffset;
    }
}

- (void)moveToPoint:(CGPoint)point {
    //BOOL isClosed = _elements[_elementCount - 1] == AJRBezierPathElementClose;
    BOOL isClosed = NO;
    NSInteger offset = isClosed ? 2 : 1;
    
    [self _intersectPointWithBounds:point forMoveTo:YES];
    
    if (_elements[_elementCount - offset] == AJRBezierPathElementMoveTo) {
        _points[_pointCount - 1] = point;
    } else {
        if (isClosed) {
            [self _increaseOperationCountBy:2];
            [self _increaseCoordinateCountBy:2];
        } else {
            [self _increaseOperationCountBy:1];
            [self _increaseCoordinateCountBy:1];
        }
        _elements[_elementCount] = AJRBezierPathElementMoveTo;
        _elementToPointIndex[_elementCount] = _pointCount;
        _moveToOffset = _pointCount;
        _points[_pointCount] = point;
        _elementCount++;
        _pointCount++;
        
        if (isClosed) {
            _elements[_elementCount] = AJRBezierPathElementClose;
            _elementCount++;
        }
    }
}

- (void)relativeCurveToPoint:(CGPoint)aPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2 {
    CGPoint current = [self currentPoint];
    
    [self curveToPoint:(CGPoint){current.x + aPoint.x, current.y + aPoint.y}
         controlPoint1:(CGPoint){current.x + controlPoint1.x, current.y + controlPoint1.y}
         controlPoint2:(CGPoint){current.x + controlPoint2.x, current.y + controlPoint2.y}];
}

- (void)relativeLineToPoint:(CGPoint)aPoint {
    CGPoint current = [self currentPoint];
    
    current.x += aPoint.x;
    current.y += aPoint.y;
    
    [self lineToPoint:current];
}

- (void)relativeMoveToPoint:(CGPoint)aPoint {
    CGPoint current = [self currentPoint];
    
    current.x += aPoint.x;
    current.y += aPoint.y;
    
    [self moveToPoint:current];
}

- (void)removeAllPoints {
    _elementCount = 1;
    _pointCount = 2;
    _hasBoundingBox = NO;
    _hasCurves = NO;
    _points[0] = (CGPoint){0.0, 0.0};
    _points[1] = _points[0];
}

- (void)closePath {
    if (![self isClosed]) {
        [self _increaseOperationCountBy:1];
        _elements[_elementCount] = AJRBezierPathElementClose;
        _elementToPointIndex[_elementCount] = _moveToOffset;
        _elementCount++;
    }
}

#pragma mark - Removing Elements

- (void)removeLastElement {
    switch (_elements[_elementCount]) {
        case AJRBezierPathElementSetBoundingBox:
            [NSException raise:NSRangeException format:@"No remaining _elements to remove"];
            break;
        case AJRBezierPathElementMoveTo:
            _elementCount--;
            _pointCount--;
            break;
        case AJRBezierPathElementLineTo:
            _elementCount--;
            _pointCount--;
            break;
        case AJRBezierPathElementCurveTo:
            _elementCount--;
            _pointCount -= 3;
            break;
        case AJRBezierPathElementClose:
            _elementCount--;
            break;
    }
}

#pragma mark - Querying paths

- (BOOL)isEmpty {
    // This is <= 1, because all paths have at least a bounding box.
    return _elementCount <= 1;
}

void AJRExpandRect(CGRect *rect, CGPoint *point) {
    if (point->x < rect->origin.x) {
        rect->size.width += (rect->origin.x - point->x);
        rect->origin.x = point->x;
    }
    if (point->y < rect->origin.y) {
        rect->size.height += (rect->origin.y - point->y);
        rect->origin.y = point->y;
    }
    if (point->x > rect->origin.x + rect->size.width) {
        rect->size.width += point->x - (rect->origin.x + rect->size.width);
    }
    if (point->y > rect->origin.y + rect->size.height) {
        rect->size.height += point->y - (rect->origin.y + rect->size.height);
    }
}

- (CGRect)bounds {
    if (_boundsValid) return _bounds;
    
    if (_elementCount <= 1) {
        _bounds = NSZeroRect;
    } else {
        AJRPathEnumerator *enumerator = [self pathEnumerator];
        AJRLine *line;
        
        line = [enumerator nextLineSegment];
        if (line) {
            _bounds.origin = line->start;
            _bounds.size = (CGSize){0, 0};
            do {
                AJRExpandRect(&_bounds, &line->end);
            } while ((line = [enumerator nextLineSegment]));
        } else {
            _bounds = NSZeroRect;
        }
    }
    
    _boundsValid = YES;
    
    return _bounds;
}

- (CGRect)controlPointBounds {
    return (CGRect){_points[0], {_points[1].x - _points[0].x, _points[1].y - _points[0].y}};
}

- (CGPoint)currentPoint {
    if (_pointCount == 2) {
        [NSException raise:NSInvalidArgumentException format:@"AJRBezierPath has no current point."];
    }
    
    return _points[_pointCount - 1];
}

// Accessing _elements of a path
- (NSInteger)pathElementIndexForPointIndex:(NSInteger)index {
    NSInteger x;
    
    index += 2;
    
    for (x = 0; x < _elementCount; x++) {
        switch (_elements[x]) {
            case AJRBezierPathElementSetBoundingBox:
                if (index < _elementToPointIndex[x] + 2) return AJRBezierPathElementSetBoundingBox;
                break;
            case AJRBezierPathElementMoveTo:
                if (index < _elementToPointIndex[x] + 1) return AJRBezierPathElementMoveTo;
                break;
            case AJRBezierPathElementLineTo:
                if (index < _elementToPointIndex[x] + 1) return AJRBezierPathElementLineTo;
                break;
            case AJRBezierPathElementCurveTo:
                if (index < _elementToPointIndex[x] + 3) return AJRBezierPathElementCurveTo;
                break;
            case AJRBezierPathElementClose:
                break;
        }
    }
    
    return NSNotFound;
}

- (CGPoint)pointAtIndex:(NSInteger)index {
    if (index + 2 < _pointCount) {
        return _points[index + 2];
    }
    
    [NSException raise:NSRangeException format:@"Index %ld is out of range [0..%lu]", index, _pointCount - 2];
    
    return (CGPoint){0.0, 0.0};
}

- (NSInteger)pointCount {
    return _pointCount - 2;
}

- (NSInteger)pointIndexForPathElementIndex:(NSInteger)index {
    if (index + 1 < _elementCount) {
        return _elementToPointIndex[index + 1] - 2;
    }
    
    [NSException raise:NSRangeException format:@"Index %ld is out of range [0..%lu]", index, _elementCount - 1];
    
    return 0;
}

- (void)setPointAtIndex:(NSInteger)index toPoint:(CGPoint)aPoint {
    if (index + 2 < _pointCount) {
        _points[index + 2] = aPoint;
        [self _updateBoundingBox];
    } else {
        [NSException raise:NSRangeException format:@"Index %ld is out of range [0..%lu]", index, _pointCount - 2];
    }
}

- (NSInteger)elementCount {
    return _elementCount - 1;
}

- (AJRBezierPathElementType)elementAtIndex:(NSInteger)index {
    if (index + 1 >= _elementCount) {
        [NSException raise:NSRangeException format:@"Index %ld is out of range [0..%lu]", index, _elementCount - 1];
    }
    
    return _elements[index + 1];
}

- (AJRBezierPathElementType)elementAtIndex:(NSInteger)index associatedPoints:(CGPoint *)somePoints {
    NSUInteger offset;
    
    if (index + 1 >= _elementCount) {
        [NSException raise:NSRangeException format:@"Index %ld is out of range [0..%lu]", index, _elementCount - 1];
    }
    
    offset = _elementToPointIndex[index + 1];
    switch (_elements[index + 1]) {
        case AJRBezierPathElementSetBoundingBox:
            somePoints[0] = _points[offset];
            somePoints[1] = _points[offset + 1];
            break;
        case AJRBezierPathElementMoveTo:
            somePoints[0] = _points[offset];
            break;
        case AJRBezierPathElementLineTo:
            somePoints[0] = _points[offset];
            break;
        case AJRBezierPathElementCurveTo:
            somePoints[0] = _points[offset];
            somePoints[1] = _points[offset + 1];
            somePoints[2] = _points[offset + 2];
            break;
        case AJRBezierPathElementClose:
            break;
    }
    
    return _elements[index + 1];
}

- (void)setAssociatedPoints:(CGPoint *)somePoints atIndex:(NSInteger)index {
    NSUInteger        offset;
    
    if (index + 1 >= _elementCount) {
        [NSException raise:NSRangeException format:@"Index %ld is out of range [0..%lu]", index, _elementCount - 1];
    }
    
    offset = _elementToPointIndex[index + 1];
    
    switch (_elements[index + 1]) {
        case AJRBezierPathElementSetBoundingBox:
            _points[offset] = somePoints[0];
            _points[offset + 1] = somePoints[1];
            break;
        case AJRBezierPathElementMoveTo:
            _points[offset] = somePoints[0];
            break;
        case AJRBezierPathElementLineTo:
            _points[offset] = somePoints[0];
            break;
        case AJRBezierPathElementCurveTo:
            _points[offset] = somePoints[0];
            _points[offset + 1] = somePoints[1];
            _points[offset + 2] = somePoints[2];
            break;
        case AJRBezierPathElementClose:
            break;
    }
}

#pragma mark - Path modifications

- (id)bezierPathByFlatteningPath {
    AJRBezierPath *newPath = [[[self class] allocWithZone:nil] init];
    AJRPathEnumerator *enumerator = [self pathEnumerator];
    AJRLine *line;
    
    [newPath setWindingRule:_windingRule];
    [newPath setLineJoinStyle:_lineJoinStyle];
    [newPath setLineCapStyle:_lineCapStyle];
    [newPath setLineWidth:_lineWidth];
    [newPath setMiterLimit:_miterLimit];
    [newPath setFlatness:_flatness];
    
    [enumerator setError:_flatness];
    while ((line = [enumerator nextLineSegment])) {
        if ([enumerator isMoveToLineSegment]) {
            [newPath moveToPoint:line->start];
        }
        [newPath lineToPoint:line->end];
    }
    
    if ([self isClosed]) {
        [newPath closePath];
    }
    
    return newPath;
}

- (id)bezierPathByReversingPath {
    AJRBezierPath *newPath = [[[self class] allocWithZone:nil] init];
    NSInteger x;
    BOOL nextRequiresMoveTo = YES;
    BOOL close = NO;
    
    [newPath setWindingRule:_windingRule];
    [newPath setLineJoinStyle:_lineJoinStyle];
    [newPath setLineCapStyle:_lineCapStyle];
    [newPath setLineWidth:_lineWidth];
    [newPath setMiterLimit:_miterLimit];
    [newPath setFlatness:_flatness];
    
    for (x = _elementCount - 1; x >= 1; x--) {
        switch (_elements[x]) {
            case AJRBezierPathElementSetBoundingBox:
                continue;
            case AJRBezierPathElementMoveTo:
                if (close) {
                    [newPath closePath];
                }
                [newPath lineToPoint:_points[_elementToPointIndex[x]]];
                nextRequiresMoveTo = YES;
                close = NO;
                break;
            case AJRBezierPathElementLineTo:
                if (nextRequiresMoveTo) {
                    [newPath moveToPoint:_points[_elementToPointIndex[x]]];
                    nextRequiresMoveTo = NO;
                }
                switch (_elements[x - 1]) {
                    case AJRBezierPathElementSetBoundingBox: break;
                    case AJRBezierPathElementMoveTo:
                        [newPath lineToPoint:_points[_elementToPointIndex[x - 1]]];
                        break;
                    case AJRBezierPathElementLineTo:
                        [newPath lineToPoint:_points[_elementToPointIndex[x - 1]]];
                        break;
                    case AJRBezierPathElementCurveTo:
                        [newPath lineToPoint:_points[_elementToPointIndex[x - 1] + 2]];
                        break;
                    case AJRBezierPathElementClose: break;
                }
                break;
            case AJRBezierPathElementCurveTo:
                if (nextRequiresMoveTo) {
                    [newPath moveToPoint:_points[_elementToPointIndex[x] + 2]];
                    nextRequiresMoveTo = NO;
                }
                switch (_elements[x - 1]) {
                    case AJRBezierPathElementSetBoundingBox: break;
                    case AJRBezierPathElementMoveTo:
                        [newPath curveToPoint:_points[_elementToPointIndex[x - 1]]
                                controlPoint1:_points[_elementToPointIndex[x] + 1]
                                controlPoint2:_points[_elementToPointIndex[x] + 0]];
                        break;
                    case AJRBezierPathElementLineTo:
                        [newPath curveToPoint:_points[_elementToPointIndex[x - 1]]
                                controlPoint1:_points[_elementToPointIndex[x] + 1]
                                controlPoint2:_points[_elementToPointIndex[x] + 0]];
                        break;
                    case AJRBezierPathElementCurveTo:
                        [newPath curveToPoint:_points[_elementToPointIndex[x - 1] + 2]
                                controlPoint1:_points[_elementToPointIndex[x] + 1]
                                controlPoint2:_points[_elementToPointIndex[x] + 0]];
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
    
    if (close) {
        [newPath closePath];
    }
    
    return newPath;
}

- (void)transformUsingAffineTransform:(NSAffineTransform *)transform {
    NSInteger        x;
    
    for (x = _elementCount - 1; x >= 1; x--) {
        switch (_elements[x]) {
            case AJRBezierPathElementSetBoundingBox:
                continue;
            case AJRBezierPathElementMoveTo:
                _points[_elementToPointIndex[x]] = [transform transformPoint:_points[_elementToPointIndex[x]]];
                break;
            case AJRBezierPathElementLineTo:
                _points[_elementToPointIndex[x]] = [transform transformPoint:_points[_elementToPointIndex[x]]];
                break;
            case AJRBezierPathElementCurveTo:
                _points[_elementToPointIndex[x] + 0] = [transform transformPoint:_points[_elementToPointIndex[x] + 0]];
                _points[_elementToPointIndex[x] + 1] = [transform transformPoint:_points[_elementToPointIndex[x] + 1]];
                _points[_elementToPointIndex[x] + 2] = [transform transformPoint:_points[_elementToPointIndex[x] + 2]];
                break;
            case AJRBezierPathElementClose:
                break;
        }
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    [self _setCoordinateMaxCount:[coder decodeIntegerForKey:@"currentMaxPoints"]];
    [self _setOperationMaxCount:[coder decodeIntegerForKey:@"currentMaxElements"]];
    _moveToOffset = [coder decodeIntegerForKey:@"moveToOffset"];
    
    _pointCount = [coder decodeIntegerForKey:@"pointCount"];
    for (NSInteger pointIndex = 0; pointIndex < _pointCount; pointIndex++) {
        _points[pointIndex] = [coder decodePointForKey:[NSString stringWithFormat:@"p%ld", pointIndex]];
    }
    
    _elementCount = [coder decodeIntegerForKey:@"elementCount"];
    for (NSInteger elementIndex = 0; elementIndex < _elementCount; elementIndex++) {
        _elements[elementIndex] = [coder decodeIntegerForKey:[NSString stringWithFormat:@"e%ld", elementIndex]];
        _elementToPointIndex[elementIndex] = [coder decodeIntegerForKey:[NSString stringWithFormat:@"ei%ld", elementIndex]];
    }
    
    _windingRule = [coder decodeIntegerForKey:@"windingRule"];
    _hasCurves = [coder decodeBoolForKey:@"hasCurves"];
    _hasBoundingBox = [coder decodeBoolForKey:@"hasBoundingBox"];
    _lineWidth = [coder decodeFloatForKey:@"lineWidth"];
    _miterLimit = [coder decodeFloatForKey:@"miterLimit"];
    _flatness = [coder decodeFloatForKey:@"flatness"];
    _lineCapStyle = [coder decodeIntegerForKey:@"lineCapStyle"];
    _lineJoinStyle = [coder decodeIntegerForKey:@"lineJoinStyle"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:_currentMaxPoints forKey:@"currentMaxPoints"];
    [coder encodeInteger:_currentMaxElements forKey:@"currentMaxElements"];
    [coder encodeInteger:_moveToOffset forKey:@"moveToOffset"];
    
    [coder encodeInteger:_pointCount forKey:@"pointCount"];
    for (NSInteger pointIndex = 0; pointIndex < _pointCount; pointIndex++) {
        [coder encodePoint:_points[pointIndex] forKey:[NSString stringWithFormat:@"p%ld", pointIndex]];
    }
    
    [coder encodeInteger:_elementCount forKey:@"elementCount"];
    for (NSInteger elementIndex = 0; elementIndex < _elementCount; elementIndex++) {
        [coder encodeInteger:_elements[elementIndex] forKey:[NSString stringWithFormat:@"e%ld", elementIndex]];
        [coder encodeInteger:_elementToPointIndex[elementIndex] forKey:[NSString stringWithFormat:@"ei%ld", elementIndex]];
    }
    
    [coder encodeInteger:_windingRule forKey:@"windingRule"];
    [coder encodeBool:_hasCurves forKey:@"hasCurves"];
    [coder encodeBool:_hasBoundingBox forKey:@"hasBoundingBox"];
    [coder encodeFloat:_lineWidth forKey:@"lineWidth"];
    [coder encodeFloat:_miterLimit forKey:@"miterLimit"];
    [coder encodeFloat:_flatness forKey:@"flatness"];
    [coder encodeInteger:_lineCapStyle forKey:@"lineCapStyle"];
    [coder encodeInteger:_lineJoinStyle forKey:@"lineJoinStyle"];
}

#pragma mark - AJRXMLCoding

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeGroupForKey:@"elements" usingBlock:^{
        [coder decodePointForKey:@"moveTo" setter:^(CGPoint point) {
            [self moveToPoint:point];
        }];
        [coder decodePointForKey:@"lineTo" setter:^(CGPoint point) {
            [self lineToPoint:point];
        }];
        [coder decodeGroupForKey:@"close" usingBlock:^{
            // Do nothing.
        } setter:^{
            [self closePath];
        }];
        __block NSPoint end, c0, c1;
        [coder decodeGroupForKey:@"curveTo" usingBlock:^{
            [coder decodeDoubleForKey:@"x" setter:^(double value) {
                end.x = value;
            }];
            [coder decodeDoubleForKey:@"y" setter:^(double value) {
                end.y = value;
            }];
            [coder decodeDoubleForKey:@"c0x" setter:^(double value) {
                c0.x = value;
            }];
            [coder decodeDoubleForKey:@"c0y" setter:^(double value) {
                c0.y = value;
            }];
            [coder decodeDoubleForKey:@"c1x" setter:^(double value) {
                c1.x = value;
            }];
            [coder decodeDoubleForKey:@"c1y" setter:^(double value) {
                c1.y = value;
            }];
        } setter:^{
            [self curveToPoint:end controlPoint1:c0 controlPoint2:c1];
        }];
    } setter:^{
        // Do nothing?
    }];
    [coder decodeIntegerForKey:@"windingRule" setter:^(NSInteger value) {
        self->_windingRule = value;
    }];
    [coder decodeDoubleForKey:@"lineWidth" setter:^(double value) {
        self->_lineWidth = value;
    }];
    [coder decodeDoubleForKey:@"miterLimit" setter:^(double value) {
        self->_miterLimit = value;
    }];
    [coder decodeDoubleForKey:@"flatness" setter:^(double value) {
        self->_flatness = value;
    }];
    [coder decodeIntegerForKey:@"lineCapStyle" setter:^(NSInteger value) {
        self->_lineCapStyle = value;
    }];
    [coder decodeIntegerForKey:@"lineJoinStyle" setter:^(NSInteger value) {
        self->_lineJoinStyle = value;
    }];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    if (!self.isEmpty) {
        [coder encodeGroupForKey:@"elements" usingBlock:^{
            [self enumerateWithBlock:^(NSBezierPathElement element, CGPoint *points, BOOL *stop) {
                switch (element) {
                    case NSBezierPathElementMoveTo: {
                        CGPoint point = points[0];
                        [coder encodePoint:point forKey:@"moveTo"];
                        break;
                    }
                    case NSBezierPathElementLineTo: {
                        CGPoint point = points[0];
                        [coder encodePoint:point forKey:@"lineTo"];
                        break;
                    }
                    case NSBezierPathElementClosePath:
                        [coder encodeGroupForKey:@"close" usingBlock:^{
                        }];
                        break;
                    case NSBezierPathElementCurveTo: {
                        CGPoint point = points[0];
                        CGPoint pointC0 = points[1];
                        CGPoint pointC1 = points[2];
                        [coder encodeGroupForKey:@"curveTo" usingBlock:^{
                            [coder encodeString:[AJRXMLCoderGetFloatFormatter() stringFromNumber:@(point.x)] forKey:@"x"];
                            [coder encodeString:[AJRXMLCoderGetFloatFormatter() stringFromNumber:@(point.y)] forKey:@"y"];
                            [coder encodeString:[AJRXMLCoderGetFloatFormatter() stringFromNumber:@(pointC0.x)] forKey:@"c0x"];
                            [coder encodeString:[AJRXMLCoderGetFloatFormatter() stringFromNumber:@(pointC0.y)] forKey:@"c0y"];
                            [coder encodeString:[AJRXMLCoderGetFloatFormatter() stringFromNumber:@(pointC1.x)] forKey:@"c1x"];
                            [coder encodeString:[AJRXMLCoderGetFloatFormatter() stringFromNumber:@(pointC1.y)] forKey:@"c1y"];
                        }];
                        break;
                    }
                }
            }];
        }];
    }

    [coder encodeInteger:_windingRule forKey:@"windingRule"];
    [coder encodeDouble:_lineWidth forKey:@"lineWidth"];
    [coder encodeDouble:_miterLimit forKey:@"miterLimit"];
    [coder encodeDouble:_flatness forKey:@"flatness"];
    [coder encodeInteger:_lineCapStyle forKey:@"lineCapStyle"];
    [coder encodeInteger:_lineJoinStyle forKey:@"lineJoinStyle"];
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"path";
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    AJRBezierPath *new = [[self class] allocWithZone:zone];
    
    [new _setCoordinateMaxCount:_currentMaxPoints];
    [new _setOperationMaxCount:_currentMaxElements];
    new->_moveToOffset = _moveToOffset;
    
    memcpy(new->_points, _points, sizeof(CGPoint) * _pointCount);
    new->_pointCount = _pointCount;
    memcpy(new->_elements, _elements, sizeof(AJRBezierPathElementType) * _elementCount);
    memcpy(new->_elementToPointIndex, _elementToPointIndex, sizeof(NSUInteger) * _elementCount);
    new->_elementCount = _elementCount;
    
    new->_lineWidth = _lineWidth;
    new->_miterLimit = _miterLimit;
    new->_flatness = _flatness;
    
    new->_windingRule = _windingRule;
    new->_hasCurves = _hasCurves;
    new->_hasBoundingBox = _hasBoundingBox;
    new->_lineCapStyle = _lineCapStyle;
    new->_lineJoinStyle = _lineJoinStyle;
    
    return new;
}

- (BOOL)isEqualToPath:(AJRBezierPath *)other {
    // We're going to use a lot of short-curcuiting here. Not my normal choice, but this would get really awkward if we didn't.

    // We check both pointCount and elementCount first, because those'll let us short circuit quickly.
    if (_pointCount != other->_pointCount || _elementCount != other->_elementCount) return NO;
    for (NSInteger x = 0; x < _pointCount; x++) {
        if (!AJRApproximateEquals(_points[x].x, other->_points[x].x, 4)
            || !AJRApproximateEquals(_points[x].y, other->_points[x].y, 4)) {
            return NO;
        }
    }
    for (NSInteger x = 0; x < _elementCount; x++) {
        if (_elements[x] != other->_elements[x]) return NO;
    }
    // NOTE: Ignoring elementToPointIndex, because if points and elements are the same, then the index had better be the same.

    // NOTE: Not comparing computed values, just user setable values.
    return (_lineWidth == other->_lineWidth
            && _miterLimit == other->_miterLimit
            && _flatness == other->_flatness
            && _windingRule == other->_windingRule
            && _lineCapStyle == other->_lineCapStyle
            && _lineJoinStyle == other->_lineJoinStyle);
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[AJRBezierPath class]] && [self isEqualToPath:(AJRBezierPath *)other];
}

@end

@implementation AJRBezierPath (Retype)

- (NSBezierPath *)asBezierPath {
    return (NSBezierPath *)self;
}

- (CGPathRef)CGPath {
    return AJRcreatepath(_points, _pointCount, _elements, _elementCount, NULL);
}

+ (AJRBezierPath *)bezierPathWithCGPath:(CGPathRef)path {
    AJRBezierPath *newPath = [AJRBezierPath bezierPath];
    [newPath appendBezierPathWithCGPath:path];
    return newPath;
}

- (void)appendBezierPathWithCGPath:(CGPathRef)path {
    CGPathApply(path, (__bridge void *)self, AJRPathToBezierIterator);
}

@end
