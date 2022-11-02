/*
AJRBezierPathFunctions.h
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

#import <AJRInterfaceFoundation/AJRBezierPath.h>

NS_ASSUME_NONNULL_BEGIN

extern void AJRbuildpath(CGContextRef context,
                        CGPoint *points, NSUInteger pointCount,
                        AJRBezierPathElementType *elements, NSUInteger elementCount,
                        _Nullable AJRBezierPathPointTransform pointTransform);

extern void AJRstroke(CGContextRef context,
                     CGPoint *points, NSUInteger pointCount,
                     AJRBezierPathElementType *elements, NSUInteger elementCount,
                      _Nullable AJRBezierPathPointTransform pointTransform);
extern void AJRfill(CGContextRef context,
                   CGPoint *points, NSUInteger pointCount,
                   AJRBezierPathElementType *elements, NSUInteger elementCount,
                    _Nullable AJRBezierPathPointTransform pointTransform);
extern void AJReofill(CGContextRef context,
                     CGPoint *points, NSUInteger pointCount,
                     AJRBezierPathElementType *elements, NSUInteger elementCount,
                      _Nullable AJRBezierPathPointTransform pointTransform);
extern void AJRclip(CGContextRef context,
                   CGPoint *points, NSUInteger pointCount,
                   AJRBezierPathElementType *elements, NSUInteger elementCount);
extern void AJReoclip(CGContextRef context,
                     CGPoint *points, NSUInteger pointCount,
                     AJRBezierPathElementType *elements, NSUInteger elementCount);
extern void AJRinfill(CGContextRef context,
                     CGFloat x, CGFloat y,
                     CGPoint *points, NSUInteger pointCount,
                     AJRBezierPathElementType *elements, NSUInteger elementCount,
                     BOOL *hit);
extern void AJRineofill(CGContextRef context,
                       CGFloat x, CGFloat y,
                       CGPoint *points, NSUInteger pointCount,
                       AJRBezierPathElementType *elements, NSUInteger elementCount,
                       BOOL *hit);
extern void AJRinstroke(CGContextRef context,
                       CGFloat x, CGFloat y,
                       CGPoint *points, NSUInteger pointCount,
                       AJRBezierPathElementType *elements, NSUInteger elementCount,
                       BOOL *hit);
extern CGRect AJRstrokebounds(CGContextRef context,
                             CGPoint *points, NSUInteger pointCount,
                             AJRBezierPathElementType *elements, NSUInteger elementCount);
extern void AJRpathbbox(CGContextRef context,
                       CGPoint *points, NSUInteger pointCount,
                       AJRBezierPathElementType *elements, NSUInteger elementCount,
                       CGFloat *llx, CGFloat *lly, CGFloat *urx, CGFloat *ury);

NS_ASSUME_NONNULL_END
