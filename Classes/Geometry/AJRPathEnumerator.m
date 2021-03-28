/*
AJRPathEnumerator.m
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

#import "AJRBezierCurves.h"
#import "AJRPathEnumerator.h"

// This is a hack of major proportions. Don't try this at home, kids.
#define MAXSTACKSIZE    200

typedef struct __ajrEdgeEnumeratorStackElement {
    AJRBezierCurve  left;
    AJRBezierCurve  right;
    BOOL            usedLeft;
} _AJREdgeEnumeratorStackElement;

#define STACK ((_AJREdgeEnumeratorStackElement *)_stack)

@implementation AJRPathEnumerator
{
    double _error;
    
    NSInteger _elementIndex;
    AJRLine _line;
    AJRBezierPathElementType _elementType;
    AJRBezierCurve _curve;
    CGPoint _lastPoint;
    CGPoint _moveToPoint;
    
    void *_stack;
    NSInteger _stackPosition;
    
    BOOL _flattenCurves:1;
    BOOL _dontFlattenCurves:1;
    BOOL _isMoveTo:1;
}

+ (id)enumeratorWithBezierPath:(AJRBezierPath *)aPath {
    return [[self allocWithZone:NSDefaultMallocZone()] initWithBezierPath:aPath];
}

- (id)initWithBezierPath:(AJRBezierPath *)aPath {
	if ((self = [super init])) {
		_path = aPath;
		_elementIndex = -1;
		_stack = NSZoneMalloc(nil, sizeof(_AJREdgeEnumeratorStackElement) * MAXSTACKSIZE);
		_stackPosition = 0;
		_error = 1.0;
		
		_flattenCurves = NO;
		_dontFlattenCurves = NO;
	}
    return self;
}

- (void)dealloc {
    NSZoneFree(nil, _stack);
}

- (id)nextObject {
    [NSException raise:NSInvalidArgumentException format:@"You called -nextObject on a AJRPathEnumerator. Call -nextLineSegment instead."];
    return nil;
}

- (void)_nextBezierLineSegment {
    CGPoint            midpoint;
    float            distance;
    AJRLine            handleLine;
    AJRBezierCurve    subcurve;
    
    if (_stackPosition == 0) {
        subcurve = _curve;
    } else {
        if (STACK[_stackPosition].usedLeft) {
            subcurve = STACK[_stackPosition].right;
            _stackPosition--;
        } else {
            subcurve = STACK[_stackPosition].left;
        }
    }
    
    while (1) {
        handleLine.start = subcurve.start;
        handleLine.end = subcurve.end;
        
        // Find the mid point value of the subcurve and the distance between that midpoint and the line formed by our subcurve's start and end.
        midpoint = AJRBezierCurveAtT(subcurve, 0.5);
        distance = AJRDistanceBetweenPointAndLine(midpoint, handleLine);
        
        // If the distance is less than error, we're sufficiently flat, and we'll compute the intersection. Otherwise, divide our subcurve in two, and check each side for intersection.
        if (distance < _error) {
            // Here, we're small enough that we'll return a line segment.
            _line = handleLine;
            if (_stackPosition == 0) {
                // Our original curve is sufficiently flat to consider a line.
            } else {
                STACK[_stackPosition].usedLeft = YES;
            }
            break;
        } else {
            _stackPosition++;
            if (_stackPosition >= MAXSTACKSIZE) {
                [NSException raise:NSInternalInconsistencyException format:@"%@ blew the stack at %d", NSStringFromSelector(_cmd), MAXSTACKSIZE];
            }
            AJRSplitBezierCurve(subcurve, &(STACK[_stackPosition].left), &(STACK[_stackPosition].right));
            subcurve = STACK[_stackPosition].left;
        }
    }
}

- (AJRLine *)nextLineSegment {
    BOOL    done = NO;
    CGPoint    points[4];
    
    if (_dontFlattenCurves) {
        [NSException raise:NSInternalInconsistencyException format:@"You called -nextLineSegment after have called -nextElementTypeWithPoints:. You can only call one per enumerator, not both."];
    }
    _flattenCurves = YES;
    
    _isMoveTo = NO;
    
    if (_stackPosition == 0) {
        do {
            _elementIndex++;
            if (_elementIndex == [_path elementCount]) return NULL;
            switch ([_path elementAtIndex:_elementIndex associatedPoints:points]) {
                case AJRBezierPathElementMoveTo:
                    _isMoveTo = YES;
                    _lastPoint = points[0];
                    _moveToPoint = _lastPoint;
                    break;
                case AJRBezierPathElementLineTo:
                    _line.start = _lastPoint;
                    _line.end = points[0];
                    _lastPoint = _line.end;
                    done = YES;
                    break;
                case AJRBezierPathElementCurveTo:
                    _curve.start = _lastPoint;
                    _curve.handle1 = points[0];
                    _curve.handle2 = points[1];
                    _curve.end = points[2];
                    [self _nextBezierLineSegment];
                    _lastPoint = points[2];
                    done = YES;
                    break;
                case AJRBezierPathElementClose:
                    _line.start = _lastPoint;
                    _line.end = _moveToPoint;
                    _lastPoint = _moveToPoint;
                    done = YES;
                    break;
                default:
                    break;
            }
        } while (!done);
    } else {
        [self _nextBezierLineSegment];
    }
    
    return &_line;
}

- (AJRBezierPathElementType *)nextElementWithPoints:(CGPoint *)somePoints {
    if (_flattenCurves) {
        [NSException raise:NSInternalInconsistencyException format:@"You called -nextElementWithPoints: after have called -nextLineSegment. You can only call one per enumerator, not both."];
    }
    _dontFlattenCurves = YES;
    
    if (_elementIndex == [_path elementCount]) return NULL;
    
    _isMoveTo = NO;
    switch (_elementType = [_path elementAtIndex:_elementIndex associatedPoints:somePoints]) {
        case AJRBezierPathElementMoveTo:
            _isMoveTo = YES;
            break;
        case AJRBezierPathElementLineTo:
            break;
        case AJRBezierPathElementCurveTo:
            break;
        case AJRBezierPathElementClose:
            break;
        default:
            break;
    }
    
    _elementIndex++;
    
    return &_elementType;
}

- (void)setError:(double)anError {
    _error = anError;
}

- (double)error {
    return _error;
}

- (double)tValue {
    return 0.0;
}

- (AJRBezierCurve)curve {
    return _curve;
}

- (NSInteger)elementIndex {
    return _elementIndex - 1;
}

- (AJRBezierPathElementType)elementType {
    return [_path elementAtIndex:_elementIndex];
}

- (BOOL)isMoveToLineSegment {
    return _isMoveTo;
}

- (BOOL)isDone {
    return _elementIndex == [_path elementCount];
}

@end
