/*
 AJRBezierPathFunctions.m
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

#import "AJRBezierPathFunctions.h"

#import "AJRBezierPath.h"
#import "AJRGeometry.h"

#define TRANSFORM(p) (pointTransform ? pointTransform(p) : p)

void AJRbuildpath(CGContextRef context,
                 CGPoint *points, NSUInteger pointCount,
                 AJRBezierPathElementType *elements, NSUInteger elementCount,
                 AJRBezierPathPointTransform pointTransform) {
    NSUInteger pointIndex = 0;
    NSUInteger elementIndex = 0;
    CGPoint p1, p2, p3;

    CGContextBeginPath(context);
    for (elementIndex = 0; elementIndex < elementCount; elementIndex++) {
        switch (elements[elementIndex]) {
            case AJRBezierPathElementSetBoundingBox:
                pointIndex += 2;
                break;
            case AJRBezierPathElementMoveTo:
                p1 = TRANSFORM(points[pointIndex]);
                CGContextMoveToPoint(context, p1.x, p1.y);
                pointIndex += 1;
                break;
            case AJRBezierPathElementLineTo:
                p1 = TRANSFORM(points[pointIndex]);
                CGContextAddLineToPoint(context, p1.x, p1.y);
                pointIndex += 1;
                break;
            case AJRBezierPathElementCurveTo:
                p1 = TRANSFORM(points[pointIndex]);
                p2 = TRANSFORM(points[pointIndex + 1]);
                p3 = TRANSFORM(points[pointIndex + 2]);
                CGContextAddCurveToPoint(context, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
                pointIndex += 3;
                break;
            case AJRBezierPathElementClose:
                CGContextClosePath(context);
                break;
        }
    }
}

CGPathRef AJRcreatepath(CGPoint *points, NSUInteger pointCount,
                         AJRBezierPathElementType *elements, NSUInteger elementCount,
                         AJRBezierPathPointTransform pointTransform) {
    NSUInteger pointIndex = 0;
    NSUInteger elementIndex = 0;
    CGPoint p1, p2, p3;

    CGMutablePathRef path = CGPathCreateMutable();
    for (elementIndex = 0; elementIndex < elementCount; elementIndex++) {
        switch (elements[elementIndex]) {
            case AJRBezierPathElementSetBoundingBox:
                pointIndex += 2;
                break;
            case AJRBezierPathElementMoveTo:
                p1 = TRANSFORM(points[pointIndex]);
                CGPathMoveToPoint(path, NULL, p1.x, p1.y);
                pointIndex += 1;
                break;
            case AJRBezierPathElementLineTo:
                p1 = TRANSFORM(points[pointIndex]);
                CGPathAddLineToPoint(path, NULL, p1.x, p1.y);
                pointIndex += 1;
                break;
            case AJRBezierPathElementCurveTo:
                p1 = TRANSFORM(points[pointIndex]);
                p2 = TRANSFORM(points[pointIndex + 1]);
                p3 = TRANSFORM(points[pointIndex + 2]);
                CGPathAddCurveToPoint(path, NULL, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
                pointIndex += 3;
                break;
            case AJRBezierPathElementClose:
                CGPathCloseSubpath(path);
                break;
        }
    }

    return path;
}

void AJRstroke(CGContextRef context,
              CGPoint *points, NSUInteger pointCount,
              AJRBezierPathElementType *elements, NSUInteger elementCount,
              AJRBezierPathPointTransform pointTransform) {
    AJRbuildpath(context, points, pointCount, elements, elementCount, pointTransform);
    CGContextStrokePath(context);
}

void AJRfill(CGContextRef context,
            CGPoint *points, NSUInteger pointCount,
            AJRBezierPathElementType *elements, NSUInteger elementCount,
            AJRBezierPathPointTransform pointTransform) {
    AJRbuildpath(context, points, pointCount, elements, elementCount, pointTransform);
    CGContextFillPath(context);
}

void AJReofill(CGContextRef context,
              CGPoint *points, NSUInteger pointCount,
              AJRBezierPathElementType *elements, NSUInteger elementCount,
              AJRBezierPathPointTransform pointTransform) {
    AJRbuildpath(context, points, pointCount, elements, elementCount, pointTransform);
    CGContextEOFillPath(context);
}

void AJRclip(CGContextRef context,
            CGPoint *points, NSUInteger pointCount,
            AJRBezierPathElementType *elements, NSUInteger elementCount) {
    AJRbuildpath(context, points, pointCount, elements, elementCount, NULL);
    CGContextClip(context);
}

void AJReoclip(CGContextRef context,
              CGPoint *points, NSUInteger pointCount,
              AJRBezierPathElementType *elements, NSUInteger elementCount) {
    AJRbuildpath(context, points, pointCount, elements, elementCount, NULL);
    CGContextEOClip(context);
}

void AJRinfill(CGContextRef context,
              CGFloat x, CGFloat y,
              CGPoint *points, NSUInteger pointCount,
              AJRBezierPathElementType *elements, NSUInteger elementCount,
              BOOL *hit) {
    AJRbuildpath(context, points, pointCount, elements, elementCount, NULL);
    *hit = CGContextPathContainsPoint(context, (CGPoint){x, y}, kCGPathFill);
}

void AJRineofill(CGContextRef context,
                CGFloat x, CGFloat y,
                CGPoint *points, NSUInteger pointCount,
                AJRBezierPathElementType *elements, NSUInteger elementCount,
                BOOL *hit) {
    AJRbuildpath(context, points, pointCount, elements, elementCount, NULL);
    *hit = CGContextPathContainsPoint(context, (CGPoint){x, y}, kCGPathEOFill);
}

void AJRinstroke(CGContextRef context,
                CGFloat x, CGFloat y,
                CGPoint *points, NSUInteger pointCount,
                AJRBezierPathElementType *elements, NSUInteger elementCount,
                BOOL *hit) {
    AJRbuildpath(context, points, pointCount, elements, elementCount, NULL);
    *hit = CGContextPathContainsPoint(context, (CGPoint){x, y}, kCGPathStroke);
}

extern CGRect AJRstrokebounds(CGContextRef context,
                             CGPoint *points, NSUInteger pointCount,
                             AJRBezierPathElementType *elements, NSUInteger elementCount) {
    AJRbuildpath(context, points, pointCount, elements, elementCount, NULL);
    CGContextReplacePathWithStrokedPath(context);
    return CGContextGetPathBoundingBox(context);
}

void AJRpathbbox(CGContextRef context,
                CGPoint *points, NSUInteger pointCount,
                AJRBezierPathElementType *elements, NSUInteger elementCount,
                CGFloat *llx, CGFloat *lly, CGFloat *urx, CGFloat *ury) {
    CGRect            bounds;
    
    AJRbuildpath(context, points, pointCount, elements, elementCount, NULL);
    CGContextReplacePathWithStrokedPath(context);
    bounds = CGContextGetPathBoundingBox(context);
    
    *llx = bounds.origin.x;
    *lly = bounds.origin.y;
    *urx = bounds.origin.x + bounds.size.width;
    *ury = bounds.origin.y + bounds.size.height;
}
