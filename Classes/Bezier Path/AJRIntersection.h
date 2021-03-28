/*
AJRIntersection.h
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
AJRRulerViewalex@raftis.net

 *%*%*%*%*/

#import <AppKit/AppKit.h>

#import <AJRInterfaceFoundation/AJRBezierCurves.h>
#import <AJRInterfaceFoundation/AJRGeometry.h>

#define AJRLeftToRightDirection 0x01
#define AJRRightToLeftDirection 0x02
#define AJRTopToBottomDirection 0x04
#define AJRBottomToTopDirection 0x08

#define AJRVerticalMask (AJRTopToBottomDirection | AJRBottomToTopDirection)
#define AJRHorizontalMask (AJRLeftToRightDirection | AJRRightToLeftDirection)

#define AJRLeftAndRightDirectionMask 0x03
#define AJRTopAndBottomDirectionMask 0x0C

@interface AJRIntersection : NSObject <NSCopying, NSCoding>

+ (id)intersectionWithPoint:(CGPoint)aPoint direction:(NSUInteger)direction segment:(NSUInteger)segment;
- (id)initWithPoint:(CGPoint)aPoint direction:(NSUInteger)direction segment:(NSUInteger)segment;

- (void)setPoint:(CGPoint)aPoint;
- (CGPoint)point;
- (void)setDirection:(NSUInteger)aDirection;
- (NSUInteger)direction;
- (void)setSegment:(NSUInteger)aSegment;
- (NSUInteger)segment;
- (void)setT:(double)tValue;
- (double)t;

- (void)setIsEndPoint:(BOOL)flag;
- (BOOL)isEndPoint;
- (void)setLinear:(BOOL)flag;
- (BOOL)linear;
- (void)setUserFlag3:(BOOL)flag;
- (BOOL)userFlag3;
- (void)setUserFlag4:(BOOL)flag;
- (BOOL)userFlag4;

// Returns the intersection of line1 with line2, or nil if the segments do not intersection.
+ (id)intersectionForLine:(AJRLine)line1 withLine:(AJRLine)line2;
// Intersect a line with an arc contained by arcBounds. If arcBounds is square, then the arc is circular. Otherwise, it is ovoid. startAngle and endAngle are presented in degrees, not radians.
+ (NSArray *)intersectionsForLine:(AJRLine)line withArcBoundedBy:(CGRect)arcBounds startingAt:(double)startAngle endingAt:(double)endAngle;
// Calls intersectionsForLine:withArcBoundedBy:startingAt:endingAt: with a square bounds.
+ (NSArray *)intersectionsForLine:(AJRLine)line withCircularArcAt:(CGPoint)origin radius:(double)radius startingAt:(double)startAngle endingAt:(double)endAngle;
// Calls intersectionsForLine:withArcBoundedBy:startingAt:endingAt: with a square bounds and startAngle 0 and endAngle 360.0
+ (NSArray *)intersectionsForLine:(AJRLine)line withCircleAt:(CGPoint)origin radius:(double)radius;
// Returns the intersections of a bezier curve with a line. This will produce one to three intersections. If the curve does not intersection the line segment, then nil is returned.
+ (NSArray *)intersectionsForCurve:(AJRBezierCurve)curve withLine:(AJRLine)line error:(double)error;
+ (id)intersectionForCurve:(AJRBezierCurve)curve withPoint:(CGPoint)aPoint;

+ (id)intersectionForLine:(AJRLine)line1 withPerpendicularLineThroughPoint:(CGPoint)aPoint;

@end


@interface NSArray (AJRIntersectionAdditions)

- (NSString *)psDescription;
- (NSArray *)sortedArrayFromPoint:(CGPoint)point;

@end


@interface NSMutableArray (AJRIntersectionAdditions)

- (void)sortFromPoint:(CGPoint)point;
- (void)flipFlopObjects;

@end
