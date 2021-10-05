/*
AJRGeometry.h
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

#import <AppKit/AppKit.h>
#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterfaceFoundation/AJRTrigonometry.h>

typedef struct _ajrPoint2 {
    double        x;
    double        y;
} AJRPoint2;

typedef struct _ajrSize2 {
    double        width;
    double        height;
} AJRSize2;

typedef struct _ajrLine {
    CGPoint        start;
    CGPoint        end;
} AJRLine;

typedef struct AJRLine2 {
    AJRPoint2        start;
    AJRPoint2        end;
} AJRLine2;

typedef struct _ajrRectAdjustment {
    CGFloat        minX;
    CGFloat        maxX;
    CGFloat        minY;
    CGFloat        maxY;
} AJRRectAdjustment;

typedef struct _ajrRectAdjustment2 {
    double        minX;
    double        maxX;
    double        minY;
    double        maxY;
} AJRRectAdjustment2;

typedef struct _ajrBezierCurve {
    CGPoint    start;
    CGPoint    handle1;
    CGPoint    handle2;
    CGPoint    end;
} AJRBezierCurve;

typedef struct _ajrBezierCurve2 {
    AJRPoint2    start;
    AJRPoint2    handle1;
    AJRPoint2    handle2;
    AJRPoint2    end;
} AJRBezierCurve2;

#define AJRSameSigns(a, b)    \
(((a < 0.0) && (b < 0.0)) || ((a > 0.0) && (b > 0.0)))
#define AJRSgn(a) ((a) < 0.0 ? -1.0 : 1.0)

typedef NS_ENUM(NSInteger, AJRRectCentering) {
    AJRRectCenteringNoFittingOrScaling,
    AJRRectCenteringFitWidth,
    AJRRectCenteringFitHeight,
    AJRRectCenteringFitWidthAndHeight,
    AJRRectCenteringScaleWidth,
    AJRRectCenteringScaleHeight,
    AJRRectCenteringScaleWidthAndHeight,
};

typedef NS_ENUM(NSInteger, AJRSizeScaling) {
    AJRSizeScalingToFitDominateAxis,       // Scales up or down to fit, perserving aspect ratio.
    AJRSizeScalingToFitAxes,               // Scales both axes up or down to fit
    AJRSizeScalingDownToFitDominateAxis,   // Scales down, if necessary, preserving aspect ratio.
    AJRSizeScalingDownToFitAxes,           // Scales both axes down to fit.
    AJRSizeScalingUpToFitDominateAxis,     // Scales up, if necessary, preserving aspect ratio.
    AJRSizeScalingUpByToFitAxes,           // Scales up both axes to fit.
};

#if defined(AJRFoundation_iOS)
typedef UIEdgeInsets AJREdgeInsets;
#else
typedef NSEdgeInsets AJREdgeInsets;
#endif

extern CGSize AJRScaleSize(CGSize size, CGSize maxSize, AJRSizeScaling action);

extern CGRect AJRRectByCenteringInRect(CGRect rect, CGRect containingRect, AJRRectCentering method);
extern CGRect AJRInterpolateRect(CGRect start, CGRect end, double percent);
extern CGRect AJRInsetRect(CGRect input, AJREdgeInsets insets, BOOL flipped);

/*!
 Makes sure the input has a positive width and height.

 @param rect A rect with a possible negative width or height.

 @return The rect with positive a width and height.
 */
extern CGRect AJRNormalizeRect(CGRect rect);
extern CGRect AJRNormalizeRectWithNonzeroArea(CGRect rect);
extern double AJRDistanceBetweenPoints(CGPoint one, CGPoint two);

extern CGRect AJRUnionRectWithPoint(CGRect frame, CGPoint point);

extern AJRRectAdjustment AJRUnionRectAdjustment(AJRRectAdjustment one, AJRRectAdjustment two);
extern CGRect AJRAdjustRect(CGRect rect, AJRRectAdjustment adjustment);

extern double AJRDistanceBetweenPointAndLine(CGPoint point, AJRLine line);
extern CGPoint AJRMidpointBetweenPoints(CGPoint one, CGPoint two);

extern CGSize AJRSizeByScaling(CGSize size, CGFloat scale);

/* This may not seem useful, but it returns a perpendicular line to "line" of length 20 starting at line.start. And yes, this is occaisionally useful, usually when you're planning on sending the resultant line(s) into something like the line intersection code */
extern AJRLine AJRPerpendicularLine(AJRLine line);

// Bezier Ranges... These are used for text line scanning
typedef NS_ENUM(uint8_t, AJRBezierRangeDirection) {
    AJRBezierRangeDirectionTop         = 0x01,
    AJRBezierRangeDirectionTopToBottom = 0x02,
    AJRBezierRangeDirectionBottom      = 0x04,
    AJRBezierRangeDirectionBottomToTop = 0x08,
    AJRBezierRangeDirectionInvalid     = 0xFF
};

#define AJRBezierRangeRight        AJRBezierRangeTop
#define AJRBezierRangeRightToLeft  AJRBezierRangeTopToBottom
#define AJRBezierRangeLeft         AJRBezierRangeBottom
#define AJRBezierRangeLeftToRight  AJRBezierRangeBottomToTop
#define AJRBezierRangeLeftAndRight AJRBezierRangeTopAndBottom

#define AJRRangeIsEdge(a) ((((a).direction & AJRBezierRangeTop) || ((a).direction & AJRBezierRangeBottom)) || \
(((a).direction & AJRBezierRangeTopToBottom) && ((a).direction & AJRBezierRangeBottomToTop)))

typedef struct _ajrBezierRange {
    double                  start;
    double                  stop;
    AJRBezierRangeDirection direction;
} AJRBezierRange;

extern AJRBezierCurve AJRBezierFromArc(CGRect bounds, double angleStart, double angleEnd);
extern BOOL AJRBezierRangesIntersect(AJRBezierRange first, AJRBezierRange second);
extern AJRBezierRange AJRUnionBezierRanges(AJRBezierRange first, AJRBezierRange second);
extern void AJRInlineUnionBezierRanges(AJRBezierRange *first, AJRBezierRange second);
extern AJRBezierRange AJRBezierRangeFromString(NSString *aString);
extern NSString *AJRStringFromBezierRange(AJRBezierRange bezierRange);
extern NSString *AJRStringFromLine(AJRLine line);

/*!
 * @function AJRLineIntersection
 *
 * Computes the intersection of two line segments. If limited is YES, then the line segments
 * must intersect, otherwise, just the lines they define must intersect.
 *
 * @param first   One of the lines to intersect.
 * @param second  The second line of the intersection
 * @param limited If YES, then an intersection is only returned if the two line segments have a
 *                physical intersection, otherwise, any intersection of the two lines is returned.
 * @param point   A pointer to a point where the computed intersection can be stored.
 *
 * @result Returns NO if no line intersection exists, otherwise YES.
 */
extern BOOL AJRLineIntersection(AJRLine first, AJRLine second, BOOL limited, CGPoint *point);

/*!
 @function AJRLineIsValid
 
 Checks to make sure the line is a valid line segment. Generally, this means that the line's start and end are not equal.
 
 @param line The line to check.
 
 @result YES if the line segment is valid, meaning that the line has either a rise, a run, or both.
 */
#define AJRLineIsValid(line) (!NSEqualPoints((line).start, (line).end))

/*!
 Returns the angle of the line. Consider this the angle of the line where a line with no rise and a positive run is at degress 0°. A line of no run, and a negative rise has an angle of 270°. A line of negative run and no rise is at 180°, and a line with zero run and a positive run is at 90°.
 
 @param line The line of interest
 
 @result The angle of the line. See the discussion for specifics.
 */
#define AJRLineAngle(line) (AJRArctan((line).end.y - (line).start.y, (line).end.x - (line).start.x))

/**
 Computes the midpoint of the line

 @param line The line who's midpoint you want.

 @result The midpoint of the line.
 */
extern CGPoint AJRMidpoint(AJRLine line);

/**
 Computers the midpoint of the line defined by start and end. If start and end are equal, the return will also be equal.

 @param start The start of the line.
 @param end The end of the line.

 @result The midpoint of the line defined by start and end.
 */
extern CGPoint AJRMidpoint2(CGPoint start, CGPoint end);
