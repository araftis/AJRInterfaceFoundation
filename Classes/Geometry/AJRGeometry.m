/*
AJRGeometry.m
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

#import "AJRGeometry.h"

#import "math.h"
#import "AJRTrigonometry.h"

#import <AJRFoundation/AJRFoundation.h>

CGSize AJRScaleSize(CGSize size, CGSize maxSize, AJRSizeScaling action) {
    CGSize newSize = CGSizeZero;
    
    // Because zero values break things.
    if (maxSize.width == 0.0 || maxSize.height == 0.0) {
        return maxSize;
    }
    
    switch (action) {
        case AJRSizeScalingToFitDominateAxis: {
            CGFloat widthScale = size.width / maxSize.width;
            CGFloat heightScale = size.height / maxSize.height;
            if (widthScale > heightScale) {
                newSize.width = size.width / widthScale;
                newSize.height = size.height / widthScale;
            } else {
                newSize.width = size.width / heightScale;
                newSize.height = size.height / heightScale;
            }
            break;
        }
        case AJRSizeScalingToFitAxes:
            newSize = maxSize;
            break;
        case AJRSizeScalingDownToFitDominateAxis: {
            newSize = size;
            if (newSize.width > maxSize.width) {
                CGFloat scale = newSize.width / maxSize.width;
                newSize.width /= scale;
                newSize.height /= scale;
            }
            if (newSize.height > maxSize.height) {
                CGFloat scale = newSize.height / maxSize.height;
                newSize.width /= scale;
                newSize.height /= scale;
            }
            break;
        }
        case AJRSizeScalingDownToFitAxes:
            newSize.width = MIN(size.width, maxSize.width);
            newSize.height = MIN(size.height, maxSize.height);
            break;
        case AJRSizeScalingUpToFitDominateAxis:
            AJRLogWarning(@"TODO: Support AJRSizeScalingUpToFitDominateAxis\n");
            break;
        case AJRSizeScalingUpByToFitAxes:
            newSize.width = MAX(size.width, maxSize.width);
            newSize.height = MAX(size.height, maxSize.height);
            break;
    }
    
    return newSize;
}

CGRect AJRRectByCenteringInRect(CGRect rect, CGRect containingRect, AJRRectCentering method) {
    CGRect outputRect = rect;
    CGFloat scale;
    
    switch (method) {
        case AJRRectCenteringNoFittingOrScaling:
            outputRect.origin.x = containingRect.origin.x + (containingRect.size.width - rect.size.width) / 2.0;
            outputRect.origin.y = containingRect.origin.y + (containingRect.size.height - rect.size.height) / 2.0;
            break;
        case AJRRectCenteringFitWidth:
            scale = containingRect.size.width / rect.size.width;
            outputRect.size.width *= scale;
            outputRect.size.height *= scale;
            outputRect.origin.x = containingRect.origin.x + (containingRect.size.width - rect.size.width) / 2.0;
            outputRect.origin.y = containingRect.origin.y + (containingRect.size.height - rect.size.height) / 2.0;
            break;
        case AJRRectCenteringFitHeight:
            scale = containingRect.size.height / rect.size.height;
            outputRect.size.width *= scale;
            outputRect.size.height *= scale;
            outputRect.origin.x = containingRect.origin.x + (containingRect.size.width - outputRect.size.width) / 2.0;
            outputRect.origin.y = containingRect.origin.y + (containingRect.size.height - outputRect.size.height) / 2.0;
            break;
        case AJRRectCenteringFitWidthAndHeight:
            if (containingRect.size.width / rect.size.width < containingRect.size.height / rect.size.height) {
                outputRect = AJRRectByCenteringInRect(rect, containingRect, AJRRectCenteringFitWidth);
            } else {
                outputRect = AJRRectByCenteringInRect(rect, containingRect, AJRRectCenteringFitHeight);
            }
            break;
        case AJRRectCenteringScaleWidth:
            scale = containingRect.size.width / rect.size.width;
            outputRect.size.width *= scale;
            outputRect.origin.x = containingRect.origin.x + (containingRect.size.width - rect.size.width) / 2.0;
            outputRect.origin.y = containingRect.origin.y + (containingRect.size.height - rect.size.height) / 2.0;
            break;
        case AJRRectCenteringScaleHeight:
            scale = containingRect.size.height / rect.size.height;
            outputRect.size.height *= scale;
            outputRect.origin.x = containingRect.origin.x + (containingRect.size.width - rect.size.width) / 2.0;
            outputRect.origin.y = containingRect.origin.y + (containingRect.size.height - rect.size.height) / 2.0;
            break;
        case AJRRectCenteringScaleWidthAndHeight: {
            outputRect = containingRect;
            break;
        }
    }
    
    return outputRect;
}

CGRect AJRInterpolateRect(CGRect start, CGRect end, double percent) {
    CGRect rect;
    
    rect.origin.x = start.origin.x + (end.origin.x - start.origin.x) * percent;
    rect.origin.y = start.origin.y + (end.origin.y - start.origin.y) * percent;
    rect.size.width = start.size.width + (end.size.width - start.size.width) * percent;
    rect.size.height = start.size.height + (end.size.height - start.size.height) * percent;
    
    return rect;
}

CGRect AJRInsetRect(CGRect input, AJREdgeInsets insets, BOOL flipped) {
    CGRect insetRect = input;
    
    insetRect.origin.x += insets.left;
    insetRect.size.width -= (insets.left + insets.right);
    if (flipped) {
        insetRect.origin.y += insets.top;
        insetRect.size.height -= (insets.top + insets.bottom);
    } else {
        insetRect.origin.y += insets.bottom;
        insetRect.size.height -= (insets.top + insets.bottom);
    }
    
    return insetRect;
}

inline CGRect AJRNormalizeRect(CGRect rect) {
    if (rect.size.height < 0.0) {
        rect.size.height *= -1.0;
        rect.origin.y -= rect.size.height;
    }
    if (rect.size.width < 0.0) {
        rect.size.width *= -1.0;
        rect.origin.x -= rect.size.width;
    }
    
    return rect;
}

inline CGRect AJRNormalizeRectWithNonzeroArea(CGRect rect) {
    rect = AJRNormalizeRect(rect);
    if (rect.size.width < 0.01) rect.size.width = 0.01;
    if (rect.size.height < 0.01) rect.size.height = 0.01;
    return rect;
}

inline double AJRDistanceBetweenPoints(CGPoint one, CGPoint two) {
    return sqrt((one.x - two.x) * (one.x - two.x) + (one.y - two.y) * (one.y - two.y));
}

inline CGRect AJRUnionRectWithPoint(CGRect frame, CGPoint point) {
    if (point.x < frame.origin.x) {
        frame.size.width += (frame.origin.x - point.x);
        frame.origin.x = point.x;
    } else if (point.x > frame.origin.x + frame.size.width) {
        frame.size.width = point.x - frame.origin.x;
    }
    if (point.y < frame.origin.y) {
        frame.size.height += (frame.origin.y - point.y);
        frame.origin.y = point.y;
    } else if (point.y > frame.origin.y + frame.size.height) {
        frame.size.height = point.y - frame.origin.y;
    }
    
    return frame;
}

inline AJRRectAdjustment AJRUnionRectAdjustment(AJRRectAdjustment one, AJRRectAdjustment two) {
    one.minX = one.minX > two.minX ? one.minX : two.minX;
    one.maxX = one.maxX > two.maxX ? one.maxX : two.maxX;
    one.minY = one.minY > two.minY ? one.minY : two.minY;
    one.maxY = one.maxY > two.maxY ? one.maxY : two.maxY;
    
    return one;
}

inline CGRect AJRAdjustRect(CGRect rect, AJRRectAdjustment adjustment) {
    rect.origin.x -= adjustment.minX;
    rect.size.width += (adjustment.minX + adjustment.maxX);
    rect.origin.y -= adjustment.minY;
    rect.size.height += (adjustment.minY + adjustment.maxY);
    
    return rect;
}

double AJRDistanceBetweenPointAndLine(CGPoint point, AJRLine line) {
    double        a, b, c;
    double        d, lp;
    
    c = ((double)line.end.x * (double)line.start.y) - ((double)line.start.x * (double)line.end.y);
    a = (double)line.end.y - (double)line.start.y;
    b = (double)line.start.x - (double)line.end.x;
    
    d = sqrt((a * a) + (b * b));
    if (d == 0.0) {
        lp = 0.0;
    } else {
        lp = (a * (double)point.x + b * (double)point.y + c) / d;
    }
    
    return fabs(lp);
}

inline CGPoint AJRMidpointBetweenPoints(CGPoint one, CGPoint two) {
    return (CGPoint){(one.x + two.x) / 2.0, (one.y + two.y) / 2.0};
}

CGSize AJRSizeByScaling(CGSize size, CGFloat scale) {
    CGSize newSize = (CGSize){size.width * scale, size.height * scale};
    return newSize;
}

AJRLine AJRPerpendicularLine(AJRLine line) {
    CGPoint    d0 = { line.start.x - line.end.x, line.start.y - line.end.y };
    double    sql0, l0;
    AJRLine    rline;
    
    if (d0.x == 0.0) {
        rline.start = line.start;
        rline.end = line.start;
        rline.end.x += 20.0;
        
        return rline;
    }
    
    if (d0.y == 0.0) {
        rline.start = line.start;
        rline.end = line.start;
        rline.end.y += 20.0;
        
        return rline;
    }
    
    l0 = d0.x;
    d0.x = -d0.y;
    d0.y = l0;
    sql0 = d0.x * d0.x + d0.y * d0.y;
    l0 = 20.0 / sqrt(sql0);
    
    rline.start = line.start;
    rline.end.x = line.start.x + d0.x * l0;
    rline.end.y = line.start.y + d0.y * l0;
    
    return rline;
}

BOOL AJRBezierRangesIntersect(AJRBezierRange first, AJRBezierRange second) {
    if ((first.start >= second.start) && (first.start <= second.stop)) return YES;
    if ((first.stop >= second.start) && (first.stop <= second.stop)) return YES;
    if ((second.start >= first.start) && (second.start <= first.stop)) return YES;
    if ((second.stop >= first.start) && (second.stop <= first.stop)) return YES;
    
    return NO;
}

AJRBezierRange AJRUnionBezierRanges(AJRBezierRange first, AJRBezierRange second) {
    AJRBezierRange range = first;
    
    AJRInlineUnionBezierRanges(&range, second);
    
    return range;
}

void AJRInlineUnionBezierRanges(AJRBezierRange *first, AJRBezierRange second) {
    if (first->start > second.start) {
        first->start = second.start;
    }
    if (first->stop < second.stop) {
        first->stop = second.stop;
    }
    first->direction |= second.direction;
}

AJRBezierRange AJRBezierRangeFromString(NSString *aString) {
    AJRBezierRange range = {0.0, 0.0, 0};
    NSDictionary *dictionary;
    
    @try {
        dictionary = [aString propertyList];
    } @catch (NSException *localException) {
        dictionary = nil;
    }
    
    if (dictionary) {
        range.start = [[dictionary objectForKey:@"start"] floatValue];
        range.stop = [[dictionary objectForKey:@"stop"] floatValue];
        range.direction = [[dictionary objectForKey:@"direction"] intValue];
    }
    
    return range;
}

NSString *AJRStringFromBezierRange(AJRBezierRange bezierRange) {
    if (bezierRange.direction == AJRBezierRangeDirectionInvalid) {
        return @"{start = 0.0, stop = 0.0, direction = Invalid\n}";
    }
    
    return [NSString stringWithFormat:@"{start = %.3f; stop = %.3f; direction = %d}", bezierRange.start, bezierRange.stop, bezierRange.direction];
}

NSString *AJRStringFromLine(AJRLine line) {
    return [NSString stringWithFormat:@"{%.1f, %.1f}->{%.1f, %.1f}", line.start.x, line.start.y, line.end.x, line.end.y];
}

CGPoint AJRMidpoint(AJRLine line) {
    return AJRMidpoint2(line.start, line.end);
}

CGPoint AJRMidpoint2(CGPoint start, CGPoint end) {
    return (CGPoint){(start.x + end.x) / 2.0, (start.y + end.y) / 2.0};
}

BOOL AJRLineIntersection(AJRLine first, AJRLine second, BOOL limited, CGPoint *point) {
    double a1, a2, b1, b2, c1, c2; // Coefficients of line eqns.
    double r1, r2, r3, r4;         // 'Sign' values
    double denom;
    
    // Compute a1, b1, c1, where line joining points 1 and 2 is "a1 x  +  b1 y  + c1  =  0".
    
    a1 = (double)first.end.y - (double)first.start.y;
    b1 = (double)first.start.x - (double)first.end.x;
    c1 = (double)first.end.x * (double)first.start.y - (double)first.start.x * (double)first.end.y;
    
    // Compute r3 and r4.
    
    r3 = a1 * (double)second.start.x + b1 * (double)second.start.y + c1;
    r4 = a1 * (double)second.end.x + b1 * (double)second.end.y + c1;
    
    // Check signs of r3 and r4. If both point 3 and point 4 lie on same side of line 1, the line segments do not intersect.
    
    if (limited &&
        r3 != 0.0 &&
        r4 != 0.0 &&
        AJRSameSigns(r3, r4)) {
        return NO;
    }
    
    // Compute a2, b2, c2
    
    a2 = (double)second.end.y - (double)second.start.y;
    b2 = (double)second.start.x - (double)second.end.x;
    c2 = (double)second.end.x * (double)second.start.y - (double)second.start.x * (double)second.end.y;
    
    // Compute r1 and r2
    
    r1 = a2 * (double)first.start.x + b2 * (double)first.start.y + c2;
    r2 = a2 * (double)first.end.x + b2 * (double)first.end.y + c2;
    
    // Check signs of r1 and r2.  If both point 1 and point 2 lie on same side of second line segment, the line segments do not intersect.
    
    if (limited &&
        r1 != 0.0 &&
        r2 != 0.0 &&
        AJRSameSigns(r1, r2)) {
        return NO;
    }
    
    // Line segments intersect: compute intersection point.
    
    denom = a1 * b2 - a2 * b1;
    if (denom == 0.0) {
        return NO;
    }
    
    point->x = (b1 * c2 - b2 * c1) / denom;
    point->y = (a2 * c1 - a1 * c2) / denom;
    
    return YES;
}

AJRBezierCurve AJRBezierFromArc(CGRect bounds, double angleStart, double angleEnd) {
   double halfAngle, a;
   double xNorm[4], yNorm[4];
   NSInteger i;
   CGPoint center;
   AJRBezierCurve curve;

   if (fabs(angleEnd - angleStart) > 90.0) {
      [NSException raise:NSInvalidArgumentException format:@"The sweep of the arc in AJRBezierFromArc must be less than 90.0 degrees."];
   }

   angleStart = AJRDegreesToRadians(angleStart);
   angleEnd = AJRDegreesToRadians(angleEnd);

   /* Compute control points */
   halfAngle = (angleEnd - angleStart) / 2.0;
   if (fabs(halfAngle) > 1e-8) {
      a = 4.0 / 3.0 * (1 - cos(halfAngle)) / sin(halfAngle);
      xNorm[0] = cos(angleStart);
      yNorm[0] = sin(angleStart);
      xNorm[1] = xNorm[0] - a * yNorm[0];
      yNorm[1] = yNorm[0] + a * xNorm[0];
      xNorm[3] = cos(angleEnd);
      yNorm[3] = sin(angleEnd);
      xNorm[2] = xNorm[3] + a * yNorm[3];
      yNorm[2] = yNorm[3] - a * xNorm[3];
   } else {
      for (i = 0; i < 4; i++) {
         xNorm[i] = cos(angleStart);
         yNorm[i] = sin(angleStart);
      }
   }

   center.x = bounds.size.width / 2.0 + bounds.origin.x;
   center.y = bounds.size.height / 2.0 + bounds.origin.y;

   curve.start.x = xNorm[0] * (bounds.size.width / 2.0) + center.x;
   curve.start.y = yNorm[0] * (bounds.size.height / 2.0) + center.y;
   curve.handle1.x = xNorm[1] * (bounds.size.width / 2.0) + center.x;
   curve.handle1.y = yNorm[1] * (bounds.size.height / 2.0) + center.y;
   curve.handle2.x = xNorm[2] * (bounds.size.width / 2.0) + center.x;
   curve.handle2.y = yNorm[2] * (bounds.size.height / 2.0) + center.y;
   curve.end.x = xNorm[3] * (bounds.size.width / 2.0) + center.x;
   curve.end.y = yNorm[3] * (bounds.size.height / 2.0) + center.y;

   return curve;
}
