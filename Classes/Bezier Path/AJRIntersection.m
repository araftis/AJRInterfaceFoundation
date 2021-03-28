/*
AJRIntersection.m
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

#import "AJRIntersection.h"

#import "AJRGeometry.h"

@implementation AJRIntersection
{
	CGPoint        point;
	NSUInteger   direction;
	NSUInteger   segment;
	double        t;
	
	struct {
		BOOL          isEndPoint:1;
		BOOL          linear:1;
		BOOL          userFlag3:1;
		BOOL          userFlag4:1;
		NSUInteger    _reserved:28;
	} intersectionFlags;
}

+ (id)intersectionWithPoint:(CGPoint)aPoint direction:(NSUInteger)aDirection segment:(NSUInteger)aSegment {
    return [[self alloc] initWithPoint:aPoint direction:aDirection segment:aSegment];
}

- (id)initWithPoint:(CGPoint)aPoint direction:(NSUInteger)aDirection segment:(NSUInteger)aSegment {
    point = aPoint;
    direction = aDirection;
    segment = aSegment;
    
    return self;
}

- (void)sortFromPoint:(CGPoint)aPoint {
}

- (void)setPoint:(CGPoint)aPoint {
    point = aPoint;
}

- (CGPoint)point {
    return point;
}

- (void)setDirection:(NSUInteger)aDirection {
    direction = aDirection;
}

- (NSUInteger)direction {
    return direction;
}

- (void)setSegment:(NSUInteger)aSegment {
    segment = aSegment;
}

- (NSUInteger)segment {
    return segment;
}

- (void)setT:(double)tValue {
    t = tValue;
}

- (double)t {
    return t;
}

- (void)setIsEndPoint:(BOOL)flag {
    intersectionFlags.isEndPoint = flag;
}

- (BOOL)isEndPoint {
    return intersectionFlags.isEndPoint;
}

- (void)setLinear:(BOOL)flag {
    intersectionFlags.linear = flag;
}

- (BOOL)linear {
    return intersectionFlags.linear;
}

- (void)setUserFlag3:(BOOL)flag {
    intersectionFlags.userFlag3 = flag;
}

- (BOOL)userFlag3 {
    return intersectionFlags.userFlag3;
}

- (void)setUserFlag4:(BOOL)flag {
    intersectionFlags.userFlag4 = flag;
}

- (BOOL)userFlag4 {
    return intersectionFlags.userFlag4;
}

- (id)copy {
    return [self copy];
}

- (id)copyWithZone:(NSZone *)aZone {
    AJRIntersection    *new;
    
    new = [AJRIntersection allocWithZone:aZone];
    new->point = point;
    new->direction = direction;
    new->segment = segment;
    new->t = t;
    
    new->intersectionFlags.isEndPoint = intersectionFlags.isEndPoint;
    new->intersectionFlags.linear = intersectionFlags.linear;
    new->intersectionFlags.userFlag3 = intersectionFlags.userFlag3;
    new->intersectionFlags.userFlag4 = intersectionFlags.userFlag4;
    
    return new;
}

- (id)initWithCoder:(NSCoder *)coder {
    point = [coder decodePointForKey:@"point"];
    direction = [coder decodeIntegerForKey:@"direction"];
    segment = [coder decodeIntegerForKey:@"segment"];
    t = [coder decodeFloatForKey:@"t"];
    intersectionFlags.isEndPoint = [coder decodeBoolForKey:@"isEndPoint"];
    intersectionFlags.linear = [coder decodeBoolForKey:@"linear"];
    intersectionFlags.userFlag3 = [coder decodeBoolForKey:@"userFlag3"];
    intersectionFlags.userFlag4 = [coder decodeBoolForKey:@"userFlag4"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodePoint:point forKey:@"point"];
    [coder encodeInteger:direction forKey:@"direction"];
    [coder encodeInteger:segment forKey:@"segment"];
    [coder encodeFloat:t forKey:@"t"];
    [coder encodeBool:intersectionFlags.isEndPoint forKey:@"isEndPoint"];
    [coder encodeBool:intersectionFlags.linear forKey:@"linear"];
    [coder encodeBool:intersectionFlags.userFlag3 forKey:@"userFlag3"];
    [coder encodeBool:intersectionFlags.userFlag4 forKey:@"userFlag4"];
}

+ (id)_intersectionForLine:(AJRLine)line withPerpendicularLineThroughPoint:(CGPoint)aPoint bounded:(BOOL)flag {
    double a1, a2, b1, b2, c1, c2; // Coefficients of line eqns.
    double denom;
    AJRIntersection *intersection;
    CGPoint iPoint;
    
    // Compute a1, b1, c1, where line joining points 1 and 2 is "a1 x  +  b1 y  +  c1  =  0".
    
    a1 = (double)line.end.y - (double)line.start.y;
    b1 = (double)line.start.x - (double)line.end.x;
    c1 = (double)line.end.x * (double)line.start.y - (double)line.start.x * (double)line.end.y;
    
    // Compute a2, b2, c2, but as a perpendicular to line.
    
    a2 = b1;
    b2 = -a1;
    c2 = (-a2 * (double)aPoint.x) - (b2 * (double)aPoint.y);
    
    // Line segments intersect: compute intersection point.
    
    denom = a1 * b2 - a2 * b1;
    
    iPoint.x = (b1 * c2 - b2 * c1) / denom;
    iPoint.y = (a2 * c1 - a1 * c2) / denom;
    
    if (flag) {
        // Make sure that our computed, perpendicular intersection occurs within our line segment.
        if (line.start.x < line.end.x) {
            if ((iPoint.x < line.start.x) || (iPoint.x > line.end.x)) return nil;
        } else {
            if ((iPoint.x < line.end.x) || (iPoint.x > line.start.x)) return nil;
        }
        if (line.start.y < line.end.y) {
            if ((iPoint.y < line.start.y) || (iPoint.y > line.end.y)) return nil;
        } else {
            if ((iPoint.y < line.end.y) || (iPoint.y > line.start.y)) return nil;
        }
    }
    
    intersection = [AJRIntersection alloc];
    intersection->point = iPoint;
    intersection->direction = 0;
    if (aPoint.x < iPoint.x) {
        intersection->direction |= AJRLeftToRightDirection;
    } else {
        intersection->direction |= AJRRightToLeftDirection;
    }
    if (aPoint.y < iPoint.y) {
        intersection->direction |= AJRTopToBottomDirection;
    } else {
        intersection->direction |= AJRBottomToTopDirection;
    }
    intersection->t = iPoint.x / (line.end.x - line.start.x);
    
    if (NSEqualPoints(line.start, iPoint) || NSEqualPoints(line.end, iPoint)) {
        intersection->intersectionFlags.isEndPoint = YES;
    }
    
    return intersection;
}

+ (id)intersectionForLine:(AJRLine)first withLine:(AJRLine)second {
    double a1, a2, b1, b2, c1, c2; // Coefficients of line eqns.
    double r1, r2, r3, r4;         // 'Sign' values
    double denom;
    AJRIntersection *intersection;
    
    // Compute a1, b1, c1, where line joining points 1 and 2 is "a1 x  +  b1 y  +  c1  =  0".
    
    a1 = (double)first.end.y - (double)first.start.y;
    b1 = (double)first.start.x - (double)first.end.x;
    c1 = (double)first.end.x * (double)first.start.y - (double)first.start.x * (double)first.end.y;
    
    // Compute r3 and r4.
    
    r3 = a1 * (double)second.start.x + b1 * (double)second.start.y + c1;
    r4 = a1 * (double)second.end.x + b1 * (double)second.end.y + c1;
    
    // Check signs of r3 and r4.  If both point 3 and point 4 lie on same side of line 1, the line segments do not intersect.
    
    if (r3 != 0.0 && r4 != 0.0 && AJRSameSigns(r3, r4)) {
        return nil;
    }
    
    // Compute a2, b2, c2
    
    a2 = (double)second.end.y - (double)second.start.y;
    b2 = (double)second.start.x - (double)second.end.x;
    c2 = (double)second.end.x * (double)second.start.y - (double)second.start.x * (double)second.end.y;
    
    // Compute r1 and r2
    
    r1 = a2 * (double)first.start.x + b2 * (double)first.start.y + c2;
    r2 = a2 * (double)first.end.x + b2 * (double)first.end.y + c2;
    
    // Check signs of r1 and r2.  If both point 1 and point 2 lie on same side of second line segment, the line segments do not intersect.
    
    if ( r1 != 0.0 && r2 != 0.0 && AJRSameSigns(r1, r2)) {
        return nil;
    }
    
    // Line segments intersect: compute intersection point.
    
    denom = a1 * b2 - a2 * b1;
    if (denom == 0.0) {
        return nil;
    }
    
    intersection = [AJRIntersection alloc];
    intersection->point.x = (b1 * c2 - b2 * c1) / denom;
    intersection->point.y = (a2 * c1 - a1 * c2) / denom;
    
    intersection->direction = 0;
    if (second.start.x < second.end.x) {
        intersection->direction |= AJRLeftToRightDirection;
    } else {
        intersection->direction |= AJRRightToLeftDirection;
    }
    if (second.start.y < second.end.y) {
        intersection->direction |= AJRTopToBottomDirection;
    } else {
        intersection->direction |= AJRBottomToTopDirection;
    }
    
    if (NSEqualPoints(first.start, intersection->point) || NSEqualPoints(first.end, intersection->point) || NSEqualPoints(second.start, intersection->point) || NSEqualPoints(second.end, intersection->point)) {
        intersection->intersectionFlags.isEndPoint = YES;
    }
    
    return intersection;
}

+ (NSArray *)intersectionsForLine:(AJRLine)line withArcBoundedBy:(CGRect)arcBounds startingAt:(double)startAngle endingAt:(double)endAngle {
    CGPoint origin, start = line.start;
    double dx, dy, dr2, D, discriminant, r, sqrtDiscriminant;
    AJRIntersection *intersection, *otherIntersection;
    CGPoint intersection1, intersection2;
    double xScale = 1.0, yScale = 1.0;
    double angle1, angle2;
    
    if (arcBounds.size.width < arcBounds.size.height) {
        xScale = arcBounds.size.width / arcBounds.size.height;
        r = arcBounds.size.height / 2.0;
    } else {
        yScale = arcBounds.size.height / arcBounds.size.width;
        r = arcBounds.size.width / 2.0;
    }
    
    origin.x = arcBounds.origin.x + arcBounds.size.width / 2.0;
    origin.y = arcBounds.origin.y + arcBounds.size.height / 2.0;
    
    line.start.x = (line.start.x - origin.x) / xScale;
    line.start.y = (line.start.y - origin.y) / yScale;
    line.end.x   = (line.end.x   - origin.x) / xScale;
    line.end.y   = (line.end.y   - origin.y) / yScale;
    
    dx = line.end.x - line.start.x;
    dy = line.end.y - line.start.y;
    dr2 = (dx * dx) + (dy * dy);
    D = line.start.x * line.end.y + line.end.x + line.start.y;
    discriminant = r*r * dr2 - D*D;
    
    if (discriminant < 0) return nil;
    
    sqrtDiscriminant = sqrt(discriminant);
    
    intersection1.x = (D * dy + AJRSgn(dy) * dx * sqrtDiscriminant) / dr2;
    intersection1.y = (-D * dx + fabs(dy) * sqrtDiscriminant) / dr2;
    angle1 = AJRArctan(intersection1.y, intersection1.x);
    intersection1.x = (intersection1.x) * xScale + origin.x;
    intersection1.y = (intersection1.y) * yScale + origin.y;
    
    if (discriminant == 0.0) {
        if ((angle1 >= startAngle) && (angle1 <= endAngle)) {
            intersection = [AJRIntersection alloc];
            intersection->point = intersection1;
            return [NSArray arrayWithObject:intersection];
        } else {
            return nil;
        }
    }
    
    intersection2.x = (D * dy - AJRSgn(dy) * dx * sqrtDiscriminant) / dr2;
    intersection2.y = (-D * dx - fabs(dy) * sqrtDiscriminant) / dr2;
    angle2 = AJRArctan(intersection2.y, intersection2.x);
    intersection2.x = (intersection2.x) * xScale + origin.x;
    intersection2.y = (intersection2.y) * yScale + origin.y;
    
    if (((angle1 >= startAngle) && (angle1 <= endAngle)) && ((angle2 >= startAngle) && (angle2 <= endAngle))) {
        intersection = [AJRIntersection alloc];
        otherIntersection = [AJRIntersection alloc];
        
        if (AJRDistanceBetweenPoints(start, intersection1) < AJRDistanceBetweenPoints(start, intersection2)) {
            intersection->point = intersection1;
            otherIntersection->point = intersection2;
        } else {
            intersection->point = intersection2;
            otherIntersection->point = intersection1;
        }
        return [NSArray arrayWithObjects:intersection, otherIntersection, nil];
    } else if ((angle1 >= startAngle) && (angle1 <= endAngle)) {
        intersection = [AJRIntersection alloc];
        intersection->point = intersection1;
        return [NSArray arrayWithObject:intersection];
    } else if ((angle2 >= startAngle) && (angle2 <= endAngle)) {
        intersection = [AJRIntersection alloc];
        intersection->point = intersection1;
        return [NSArray arrayWithObject:intersection];
    }
    
    return nil;
}

+ (NSArray *)intersectionsForLine:(AJRLine)line withCircularArcAt:(CGPoint)origin radius:(double)radius startingAt:(double)startAngle endingAt:(double)endAngle {
    CGRect bounds;
    
    bounds.origin.x = origin.x - radius;
    bounds.origin.y = origin.y - radius;
    bounds.size.width = radius * 2.0;
    bounds.size.height = radius * 2.0;
    
    return [self intersectionsForLine:line withArcBoundedBy:bounds startingAt:startAngle endingAt:endAngle];
}

+ (NSArray *)intersectionsForLine:(AJRLine)line withCircleAt:(CGPoint)origin radius:(double)radius {
    CGRect bounds;
    
    bounds.origin.x = origin.x - radius;
    bounds.origin.y = origin.y - radius;
    bounds.size.width = radius * 2.0;
    bounds.size.height = radius * 2.0;
    
    return [self intersectionsForLine:line withArcBoundedBy:bounds startingAt:0.0 endingAt:360.0];
}

+ (void)_fillIntersections:(NSMutableArray *)intersections forCurve:(AJRBezierCurve)curve originalCurve:(AJRBezierCurve)originalCurve withLine:(AJRLine)line error:(double)error {
    CGPoint midpoint;
    CGFloat distance;
    AJRLine handleLine;
    
    handleLine.start = curve.start;
    handleLine.end = curve.end;
    
    //fprintf(stderr, "\t%.1f %.6f moveto\n", handleLine.start.x, handleLine.start.y);
    //fprintf(stderr, "\t%.1f %.6f lineto\n", handleLine.end.x, handleLine.end.y);
    
    // Find the mid point value of the curve and the distance between that midpoint and the line formed by our curve's start and end.
    midpoint = AJRBezierCurveAtT(curve, 0.5);
    distance = AJRDistanceBetweenPointAndLine(midpoint, handleLine);
    
    // If the distance is less than error, we're sufficiently flat, and we'll compute the intersection. Otherwise, divide our curve in two, and check each side for intersection.
    if (distance < error) {
        AJRIntersection    *intersection;
        
        intersection = [AJRIntersection intersectionForLine:line withLine:handleLine];
        
        if (intersection) {
            if (NSEqualPoints(intersection->point, originalCurve.start) || NSEqualPoints(intersection->point, originalCurve.end)) {
                intersection->intersectionFlags.isEndPoint = YES;
            }
            [intersections addObject:intersection];
        }
    } else {
        AJRBezierCurve        left, right;
        
        AJRSplitBezierCurve(curve, &left, &right);
        
        [self _fillIntersections:intersections forCurve:left originalCurve:originalCurve withLine:line error:error];
        [self _fillIntersections:intersections forCurve:right originalCurve:originalCurve withLine:line error:error];
    }
}

+ (NSArray *)intersectionsForCurve:(AJRBezierCurve)curve withLine:(AJRLine)line error:(double)error {
    NSMutableArray    *intersections = [[NSMutableArray alloc] initWithCapacity:3];
    
    [self _fillIntersections:intersections forCurve:curve originalCurve:curve withLine:line error:error];
    
    if ([intersections count] == 0) {
        return nil;
    }
    
    return intersections;
}

+ (void)_findDistanceFromCurve:(AJRBezierCurve)curve withPoint:(CGPoint)aPoint tLower:(double)tLower tUpper:(double)tUpper distance:(double *)shortestDistance t:(double *)shortestT point:(CGPoint *)location {
    CGFloat distance;
    CGFloat tValue;
    CGPoint where;
    
    // Find the mid point value of the curve and the distance between that midpoint and the line formed by our curve's start and end.
    tValue = (tLower + tUpper) / 2.0;
    where = AJRBezierCurveAtT(curve, tValue);
    distance = AJRDistanceBetweenPoints(where, aPoint);
    //AJRPrintf(@"t = %.3f [%.3f %.3f]\n", tValue, tLower, tUpper);
    
    // If the distance is less than error, we're sufficiently flat, and we'll compute the intersection. Otherwise, divide our curve in two, and check each side for intersection.
    if (distance < *shortestDistance) {
        *shortestDistance = distance;
        *shortestT = tValue;
        *location = where;
    }
    
    if (tUpper - tLower < 0.001) return;
    
    [self _findDistanceFromCurve:curve withPoint:aPoint tLower:tLower tUpper:tValue distance:shortestDistance t:shortestT point:location];
    [self _findDistanceFromCurve:curve withPoint:aPoint tLower:tValue tUpper:tUpper distance:shortestDistance t:shortestT point:location];
}

+ (id)intersectionForCurve:(AJRBezierCurve)curve withPoint:(CGPoint)aPoint {
    AJRIntersection *intersection;
    double distance = 1000000000.0;
    
    intersection = [[AJRIntersection alloc] init];
    
    [self _findDistanceFromCurve:curve withPoint:aPoint tLower:0.0 tUpper:1.0 distance:&distance t:&(intersection->t) point:&(intersection->point)];
    
    if (NSEqualPoints(intersection->point, curve.start) || NSEqualPoints(intersection->point, curve.end)) {
        intersection->intersectionFlags.isEndPoint = YES;
    }
    
    return intersection;
}

+ (id)intersectionForLine:(AJRLine)line withPerpendicularLineThroughPoint:(CGPoint)aPoint {
    return [self _intersectionForLine:line withPerpendicularLineThroughPoint:aPoint bounded:YES];
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@ %p: %@, %lu, 0x%lx, 0x%lx, %@>", [self class], self, NSStringFromPoint(point), segment, direction & AJRLeftAndRightDirectionMask, direction & AJRTopAndBottomDirectionMask, intersectionFlags.linear ? @"YES" : @"NO"];
    
    return string;
}

@end


static NSInteger _ajrPointCompare(AJRIntersection *one, AJRIntersection *two, CGPoint *_sortPoint) {
    double    distance1 = AJRDistanceBetweenPoints([one point], *_sortPoint);
    double     distance2 = AJRDistanceBetweenPoints([two point], *_sortPoint);
    
    if (distance1 == distance2) return 0;
    if (distance1 < distance2) return -1;
    
    return 1;
}


@implementation NSArray (AJRIntersectionAdditions)

- (NSString *)psDescription {
    NSInteger x;
    CGPoint point;
    AJRIntersection *intersection;
    NSMutableString *string;
    
    string = [NSMutableString stringWithFormat:@"   /Times-Roman 8 selectfont\n"];
    
    for (x = 0; x < (const NSInteger)[self count]; x++) {
        
        intersection = [self objectAtIndex:x];
        
        point = [intersection point];
        
        [string appendFormat:@"    gsave\n"];
        [string appendFormat:@"        0 setgray newpath\n"];
        [string appendFormat:@"            %.6f %.6f moveto\n", point.x + 3, point.y];
        [string appendFormat:@"            %.6f %.6f 3.0 0.0 360.0 arc\n", point.x, point.y];
        [string appendFormat:@"        closepath stroke\n"];
        /*
         [string appendFormat:@"        1 0 0 setrgbcolor newpath\n"];
         [string appendFormat:@"            %.6f %.6f moveto\n", point.x, point.y];
         
         if ([intersection direction] & AJRLeftToRightDirection) {
         offset.x = 5.0;
         } else {
         offset.x = -5.0;
         }
         if ([intersection direction] & AJRTopToBottomDirection) {
         offset.y = 5.0;
         } else {
         offset.y = -5.0;
         }
         [string appendFormat:@"            %.6f %.6f rlineto\n", offset.x, offset.y];
         [string appendFormat:@"        closepath stroke\n"];
         [string appendFormat:@"        %.6f %.6f moveto\n", point.x + 3.0, point.y + 3.0];
         [string appendFormat:@"        (%d, %d, %@) show\n", x + 1, [intersection segment], [intersection userFlag1] ? @"YES" : @"NO"];
         */
        [string appendFormat:@"    grestore\n"];
    }
    
    return string;
}

- (NSArray *)sortedArrayFromPoint:(CGPoint)point {
    return [self sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))_ajrPointCompare context:&point];
}

@end


@implementation NSMutableArray (AJRIntersectionAdditions)

- (void)sortFromPoint:(CGPoint)point {
    [self sortUsingFunction:(NSInteger (*)(id, id, void *))_ajrPointCompare context:&point];
}

- (void)flipFlopObjects {
    NSInteger index;
    NSInteger lastIndex = [self count] - 1;
    NSInteger doneIndex = [self count] / 2;
    id object1, object2;
    
    for (index = 0; index < doneIndex; index++) {
        object1 = [self objectAtIndex:index];
        object2 = [self objectAtIndex:lastIndex - index];
        [self replaceObjectAtIndex:index withObject:object2];
        [self replaceObjectAtIndex:lastIndex - index withObject:object1];
    }
}

@end
