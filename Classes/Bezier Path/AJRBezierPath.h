/*
AJRBezierPath.h
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

#import <CoreGraphics/CoreGraphics.h>

#import <AJRInterfaceFoundation/AJRGeometry.h>
#import <AJRInterfaceFoundation/AJRBezierCurves.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRPathEnumerator, AJRMutableBezierRangeArray;

#define AJRHairLineWidth (CGFloat)0.0

typedef NS_ENUM(NSInteger, AJRBezierPathElementType)  {
    AJRBezierPathElementSetBoundingBox = -1,
    AJRBezierPathElementMoveTo = NSBezierPathElementMoveTo,
    AJRBezierPathElementLineTo = NSBezierPathElementLineTo,
    AJRBezierPathElementCurveTo = NSBezierPathElementCurveTo,
    AJRBezierPathElementClose = NSBezierPathElementClosePath
};

typedef NS_ENUM(NSInteger, AJRWindingRule)  {
    AJRWindingRuleNonZero = NSWindingRuleNonZero,
    AJRWindingRuleEvenOdd = NSWindingRuleEvenOdd
};

typedef NS_ENUM(NSInteger, AJRLineCapStyle)  {
    AJRLineCapStyleButt = NSLineCapStyleButt,
    AJRLineCapStyleRound = NSLineCapStyleRound,
    AJRLineCapStyleSquare = NSLineCapStyleSquare
};

typedef NS_ENUM(NSInteger, AJRLineJoinStyle)  {
    AJRLineJoinStyleMitered = NSLineJoinStyleMiter,
    AJRLineJoinStyleRound = NSLineJoinStyleRound,
    AJRLineJoinStyleBeveled = NSLineJoinStyleBevel
};

extern void AJRExpandRect(CGRect *rect, CGPoint *point);

typedef CGPoint (^AJRBezierPathPointTransform)(CGPoint point);

@interface NSArray (_AJRBezierPathExtensions)

- (AJRBezierRange)bezierRangeAtIndex:(NSUInteger)index;

@end


@interface NSMutableArray (_AJRBezierPathExtensions)

- (void)addBezierRange:(AJRBezierRange)range;
- (void)replaceBezierRangeAtIndex:(NSUInteger)index withRange:(AJRBezierRange)range;
- (void)unionBezierRangeAtIndex:(NSUInteger)index withRange:(AJRBezierRange)newRange;

@end


@interface AJRBezierPath : NSObject <NSCoding, NSCopying, AJRXMLCoding> {
	CGPoint *_points;
	NSUInteger _pointCount;
	AJRBezierPathElementType *_elements;
	NSUInteger *_elementToPointIndex;
	NSUInteger _elementCount;
	
	NSUInteger _currentMaxPoints;
	NSUInteger _currentMaxElements;
	NSUInteger _moveToOffset;
	
	CGFloat *_dashValues;
	NSInteger _dashCount;
	CGFloat _dashOffset;
	
	CGRect _bounds;
	CGRect _strokeBounds;
	
	AJRBezierPathPointTransform _strokePointTransform;
	AJRBezierPathPointTransform _fillPointTransform;
	
	BOOL _hasCurves;
	BOOL _hasBoundingBox;
	BOOL _strokeBoundsValid;
	BOOL _boundsValid;
}

#pragma mark - Creation
+ (instancetype)bezierPath;
+ (instancetype)bezierPathWithRect:(CGRect)rect;
+ (instancetype)bezierPathWithOvalInRect:(CGRect)rect;
+ (instancetype)bezierPathWithCrossedRect:(CGRect)rect;
+ (instancetype)bezierPathWithRoundedRect:(NSRect)rect xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius;

#pragma mark - Appending paths and some common shapes
- (void)appendBezierPath:(AJRBezierPath *)path;
- (void)appendBezierPathWithArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise NS_SWIFT_NAME(appendArc(withCenter:radius:startAngle:endAngle:clockwise:));
- (void)appendBezierPathWithArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle NS_SWIFT_NAME(appendArc(withCenter:radius:startAngle:endAngle:));
- (void)appendBezierPathWithArcFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2 radius:(CGFloat)radius NS_SWIFT_NAME(appendArc(from:to:radius:));
- (void)appendBezierPathWithCGGlyph:(CGGlyph)aGlyph inFont:(NSFont *)font NS_SWIFT_NAME(append(withCGGlyph:in:));
- (void)appendBezierPathWithCGGlyphs:(CGGlyph *)glyphs count:(NSInteger)count inFont:(NSFont *)font NS_SWIFT_NAME(append(withCGGlyphs:count:in:));
- (void)appendBezierPathWithOvalInRect:(CGRect)rect NS_SWIFT_NAME(appendOval(in:));
- (void)appendBezierPathWithPoints:(CGPoint *)points count:(NSInteger)count NS_SWIFT_NAME(appendPoints(_:count:));
- (void)appendBezierPathWithRect:(CGRect)rect NS_SWIFT_NAME(appendRect(_:));
- (void)appendBezierPathWithRoundedRect:(NSRect)rect xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius NS_SWIFT_NAME(appendRoundedRect(_:xRadius:yRadius:));

#pragma mark - Clipping paths
- (void)addClip;
- (void)setClip;
+ (void)clipRect:(CGRect)rect;

#pragma mark - Drawing paths
- (void)fill;
- (void)stroke;
+ (void)drawPackedGlyphs:(const char *)packedGlyphs atPoint:(CGPoint)aPoint;
+ (void)fillRect:(CGRect)rect;
+ (void)strokeLineFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2;
+ (void)strokeRect:(CGRect)rect;

#pragma mark - Setting attributes
@property (nonatomic,assign) AJRWindingRule windingRule;
@property (nonatomic,assign) CGFloat flatness;
@property (nonatomic,assign) AJRLineCapStyle lineCapStyle;
@property (nonatomic,assign) AJRLineJoinStyle lineJoinStyle;
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,assign) CGFloat miterLimit;
- (void)setLineDash:(CGFloat * _Nullable)values count:(NSInteger)count phase:(CGFloat)phase;
- (void)getLineDash:(nullable CGFloat *)values count:(nullable NSInteger *)count phase:(nullable CGFloat *)phase;

@property (nonatomic,class,assign) AJRWindingRule defaultWindingRule;
@property (nonatomic,class,assign) CGFloat defaultFlatness;
@property (nonatomic,class,assign) AJRLineCapStyle defaultLineCapStyle;
@property (nonatomic,class,assign) AJRLineJoinStyle defaultLineJoinStyle;
@property (nonatomic,class,assign) CGFloat defaultLineWidth;
@property (nonatomic,class,assign) CGFloat defaultMiterLimit;
+ (void)setDefaultLineDash:(CGFloat *)values count:(NSInteger)count phase:(CGFloat)phase;
+ (void)getDefaultLineDash:(CGFloat *)values count:(NSInteger *)count phase:(CGFloat *)phase;

#pragma mark - Hit detection
- (BOOL)isHitByPath:(AJRBezierPath *)aBezierPath;
- (BOOL)isHitByPoint:(CGPoint)aPoint;
- (BOOL)isHitByRect:(CGRect)rect;
- (BOOL)isStrokeHitByPath:(AJRBezierPath *)aBezierPath;
- (BOOL)isStrokeHitByPoint:(CGPoint)aPoint;
- (BOOL)isStrokeHitByRect:(CGRect)rect;

#pragma mark - Contructing paths
- (void)curveToPoint:(CGPoint)aPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;
- (void)lineToPoint:(CGPoint)aPoint;
- (void)moveToPoint:(CGPoint)aPoint;
- (void)relativeCurveToPoint:(CGPoint)aPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;
- (void)relativeLineToPoint:(CGPoint)aPoint;
- (void)relativeMoveToPoint:(CGPoint)aPoint;
- (void)removeAllPoints;
- (void)closePath;

#pragma mark - Removing Elements
- (void)removeLastElement;

#pragma mark - Querying paths
@property (nonatomic,readonly) BOOL isEmpty;
@property (nonatomic,readonly) CGRect bounds;
@property (nonatomic,readonly) CGRect controlPointBounds;
@property (nonatomic,readonly) CGPoint currentPoint;

#pragma mark - Accessing elements of a path
- (NSInteger)pathElementIndexForPointIndex:(NSInteger)index;
- (CGPoint)pointAtIndex:(NSInteger)index;
@property (nonatomic,readonly) NSInteger pointCount;
- (NSInteger)pointIndexForPathElementIndex:(NSInteger)index;
- (void)setPointAtIndex:(NSInteger)index toPoint:(CGPoint)aPoint;
@property (nonatomic,readonly) NSInteger elementCount;
- (AJRBezierPathElementType)elementAtIndex:(NSInteger)index;
- (AJRBezierPathElementType)elementAtIndex:(NSInteger)index associatedPoints:(CGPoint *)points;
- (void)setAssociatedPoints:(CGPoint *)points atIndex:(NSInteger)index;

#pragma mark - Path modifications
- (id)bezierPathByFlatteningPath;
- (id)bezierPathByReversingPath;

#pragma mark - Applying transformations
- (void)transformUsingAffineTransform:(NSAffineTransform *)transform;

@end


@interface AJRBezierPath (AJRExtensions)

@property (nonatomic,assign,nullable) AJRBezierPathPointTransform strokePointTransform;
@property (nonatomic,assign,nullable) AJRBezierPathPointTransform fillPointTransform;

#pragma mark - Creation

- (id)initWithRect:(CGRect)rect;

- (id)initWithPolygonInRect:(CGRect)rect sides:(NSInteger)sides starPercent:(CGFloat)starPercent offset:(CGFloat)offset;
+ (instancetype)bezierPathWithPolygonInRect:(CGRect)rect sides:(NSInteger)sides starPercent:(CGFloat)starPercent offset:(CGFloat)offset NS_SWIFT_NAME(bezierPathWithPolygon(in:sides:starPercent:offset:));

#pragma mark - Appending paths and some common shapes

- (void)appendBezierPathWithArcBoundedByRect:(CGRect)arcBounds
                                  startAngle:(CGFloat)startAngle
                                    endAngle:(CGFloat)endAngle
                                   clockwise:(BOOL)flag NS_SWIFT_NAME(appendArc(boundedBy:startAngle:endAngle:clockwise:));

- (void)appendBezierPathWithCrossedRect:(CGRect)rect NS_SWIFT_NAME(appendCrossedRect(_:));
- (void)appendBezierPathWithCrossCenteredAt:(NSPoint)center legSize:(NSSize)legSize andLegThickness:(NSSize)legThickness NS_SWIFT_NAME(appendCross(centeredAt:legSize:legThickness:));

- (void)appendBezierPathWithPolygonInRect:(CGRect)rect sides:(NSInteger)sides starPercent:(CGFloat)starPercent offset:(CGFloat)offset NS_SWIFT_NAME(appendPolygon(in:sides:starPercent:offset:));

#pragma mark - Contructing Paths

- (void)lineToAngle:(CGFloat)degree length:(CGFloat)length;
- (void)relativeLineToAngle:(CGFloat)degree length:(CGFloat)length;
- (void)moveToAngle:(CGFloat)degree length:(CGFloat)length;
- (void)relativeMoveToAngle:(CGFloat)degree length:(CGFloat)length;
- (void)openPath;
- (BOOL)isClosed;
- (void)insertMoveToPoint:(CGPoint)point atIndex:(NSUInteger)elementIndex;
- (void)insertLineToPoint:(CGPoint)point atIndex:(NSUInteger)elementIndex;
- (void)insertCurveToPoint:(CGPoint)point controlPoint1:(CGPoint)control1 controlPoint2:(CGPoint)control2 atIndex:(NSUInteger)elementIndex;
- (void)splitElementAtIndex:(NSUInteger)elementIndex atTValue:(CGFloat)t;

#pragma mark - Accessing elements of a path

- (CGPoint)lastPoint;
- (void)movePointAtIndex:(NSInteger)index byDelta:(CGPoint)aDelta;
- (NSInteger)lastDrawingElementIndex;
- (AJRBezierPathElementType)elementTypeAtIndex:(NSInteger)index ajrsociatedLineSegment:(AJRLine *)lineSegment;
- (AJRBezierPathElementType)lastElementType;
- (AJRBezierPathElementType)lastDrawingElementType;
- (NSUInteger)moveToIndexForElementAtIndex:(NSInteger)index;
- (BOOL)isElementAtIndexInClosedSubpath:(NSInteger)elementIndex;

#pragma mark - Path transformations

- (void)translateByDelta:(CGPoint)delta;
- (void)rotateByDegrees:(CGFloat)degrees aroundPoint:(CGPoint)origin;
- (void)setControlPointBounds:(CGRect)newBounds;

#pragma mark - Changing the path

- (void)changeToLineToElementAtIndex:(NSUInteger)elementIndex;
- (void)changeToCurveToWithControlPoint1:(CGPoint)control1 controlPoint2:(CGPoint)control2 elementAtIndex:(NSUInteger)elementIndex;
- (void)removeElementAtIndex:(NSUInteger)elementIndex;

#pragma mark - Additional Hit Detection

- (NSUInteger)elementIndexOfElementHitByPoint:(CGPoint)point atTValue:(CGFloat *)t;
- (NSUInteger)elementIndexOfElementHitByPoint:(CGPoint)point atTValue:(CGFloat *)t width:(CGFloat)width;

- (NSString *)psDescription;
- (NSString *)psDescriptionWithFill:(BOOL)flag;

#pragma mark - Enumerator for going over the edge. This is an easy way to flatten the path.

@property (readonly) AJRPathEnumerator *pathEnumerator;
- (void)enumerateWithBlock:(void (^)(NSBezierPathElement element, CGPoint *points, BOOL *stop))enumerationBlock;
- (void)enumerateFlattenedPathWithBlock:(void (^)(AJRLine lineSegment, BOOL isNewSubpath, BOOL *stop))enumerationBlock;

#pragma mark - Additonal bounds computations

- (CGRect)strokeBounds;
- (void)setBoundsAreValid:(BOOL)flag;

#pragma mark - Transforming the path

- (AJRBezierPath *)bezierPathFromStrokedPath;

#pragma mark - Applying the path to the current context

- (void)applyToContext:(CGContextRef)context clockwise:(BOOL)flag;

#pragma mark - Conveniences methods

+ (AJRBezierPath *)bezierPathWithLine:(AJRLine)line;
+ (void)strokeLine:(AJRLine)line;
+ (AJRBezierPath *)bezierPathWithBarbellFromPoint:(CGPoint)start toPoint:(CGPoint)end radius:(CGFloat)radius;

@end


@interface AJRBezierPath (AJRIntersection)

// Returns an array of AJRIntersection objects of all points on line intersecting our path. If the line segment does not intersect our path, return nil. The intersections are not sorted. If you'd like them sorted in a certain order from a certain point in space, call sortFromPoint: or sortedArrayFromPoint: on NSMutableArray or NSArray respectfully. error represents the amount of "flatness" to treat curves with. If error is 0.0, the current flatness, as set by +setFlatness is used.
- (NSArray *)intersectionsWithLine:(AJRLine)line error:(double)error;

- (NSArray *)subrectanglesContainedInRect:(CGRect)proposedRect error:(CGFloat)error lineSweep:(NSLineSweepDirection)sweepDirection minimumSize:(CGFloat)minSize;

- (id)pathByUnioningWithPath:(id)path;
- (id)pathByIntersectingWithPath:(id)path;
- (id)pathBySubtractingPath:(id)path;
- (id)pathByExclusivelyIntersectingPath:(id)path;

@end

NS_ASSUME_NONNULL_END
