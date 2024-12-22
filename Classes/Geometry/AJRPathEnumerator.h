/*
 AJRPathEnumerator.h
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

#import <Foundation/Foundation.h>

#import <AJRInterfaceFoundation/AJRGeometry.h>
#import <AJRInterfaceFoundation/AJRTrigonometry.h>
#import <AJRInterfaceFoundation/AJRBezierPath.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRPathEnumerator : NSObject

/*!
 Returns a new path enumerator inialized with `path`. See the documentation for -initWithBezierPath: for information on the error value.

 Note: `path` can also be an NSBeizerPath.

 @param path The path to enumerate.
 */
+ (id)enumeratorWithBezierPath:(id <AJRBezierPathProtocol>)path;

/*!
 Initializes an enumerator with the provided path.

 Note that the error value used to flatten bezier segments will be taken from the path at this point. It's important to note that if you're enumerating a path that will be displayed at a scale other than 1, you may need to adjust the error value on the enumerator.

 When enumerating a path, you can enumerate the actual segments, or you can enumerate by just line segments, which effectively flattens all bezier path segments in the input path. Which type of enumeration is controlled by call -nextLineSegmentIsNewSubpath: or -nextElementWithPoints:. You should only call one of these methods, as alternating calls between these methods can cause undefined results.

 @param path The path to enumerate.
 */
- (id)initWithBezierPath:(id <AJRBezierPathProtocol>)path;

/*!
 The path we're enumerator. This can only be set at the time of creation.
 */
@property (nonatomic,readonly) id <AJRBezierPathProtocol> path;

/*!
 Returns the next line segment by calling -[nextLineSergmentIsNewSubpath:NULL].

 @returns The next line segment in the shape, or NULL if there are no more line segments.
 */
- (nullable AJRLine *)nextLineSegment;
/*!
 Returns the next line segment in the path. Calling this method will flatten any bezier path segments in the path. When calling this, you can pass in a pointer to a boolean, `isNewSubpath`, which will be initialized if the line segment represents the first line segment in a new subpath. This will always return YES at least once for each path, but can be YES for multiple. If you don't care about this, you may pass `NULL`.

 @param isNewSubpath An option pointer to a boolean that will be initialized to YES if the returned line segment represents the first line segment of a new subpath.

 @results The next line segment in the path, or NULL if there are no more line segments.
 */
- (nullable AJRLine *)nextLineSegmentIsNewSubpath:(BOOL * _Nullable)isNewSubpath;

/*!
 Returns the next segment of path, and it's corresponding points.

 The number of points returned will vary between 0 and 3 depending on the type of element returned. So, an `AJRBezierPathElementClose`  will have no associated points, while `AJRBezierPathElementMoveTo` and `AJRBezierPathElementLineTo` will have 1 point returned, and `AJRBezierPathElementCubicCurveTo` will return 3 points. As such, `points` should be large enough to hold three points.

 @param points A pointer to an array of CGPoint. This should be large enough to hold three points.

 @result The type of the next element or NULL if there are no more elements in the path.
 */
- (nullable AJRBezierPathElement *)nextElementWithPoints:(CGPoint *)points NS_SWIFT_NAME(_nextElement(withPoints:));

/*! Error value used when flattening bezier curves. This is derived from the initializing input path. */
@property (nonatomic, assign) double error;

/*! If currently enumerating a bezier curve, this is the current tValue of the curve. */
@property (nonatomic, readonly) double tValue;
/*! The definitive of the current bezier curve, but this is only valid if `elementType ==  `AJRBezierPathElementCubicCurveTo`. */
@property (nonatomic, readonly) AJRBezierCurve curve;    // Only valid if the current elementType is NSCurveToBezierPathElement
/*! The current element index we're enumeration. This doesn't necessarily increment with each call, since each line segment of a bezier path with have the same elementIndex. */
@property (nonatomic,readonly) NSInteger elementIndex;
/*! The type of the current element type. This would be the same as asking the `AJRBezierPath` for the element type of the element at `elementIndex`. */
@property (nonatomic, readonly) AJRBezierPathElement elementType;
/*! If we're enumerating by line segments, this is true when the current line segment was starting via a moveTo. */
@property (nonatomic, readonly) BOOL isMoveToLineSegment;

@end

NS_ASSUME_NONNULL_END
