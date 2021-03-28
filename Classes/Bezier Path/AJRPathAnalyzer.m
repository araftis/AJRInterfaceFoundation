/*
AJRPathAnalyzer.m
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

#import "AJRPathAnalyzer.h"

#import "AJRBezierPath.h"
#import "AJRGeometry.h"
#import "AJRPathEnumerator.h"
#import "AJRTrigonometry.h"

#import <AJRFoundation/AJRFormat.h>

@implementation AJRPathAnalysisCorner

#pragma mark NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%.1f, %.1f>", _angle, _delta];
}

@end


@implementation AJRPathAnalysisContour

#pragma mark Creation

- (id)init {
    if ((self = [super init])) {
        _corners = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark NSObject

- (NSString *)description {
    return AJRFormat(@"<%C: %R: %@>", self, _bounds, _corners);
}

@end


@interface AJRPathAnalyzer ()

- (void)_analyze;

@end

@implementation AJRPathAnalyzer

#pragma mark Creation

- (id)initWithPath:(AJRBezierPath *)path {
    if ((self = [super init])) {
        _path = path;
        _contours = [[NSMutableArray alloc] init];
        
        [self _analyze];
    }
    return self;
}

#pragma mark Analysis

- (void)_analyze {
    AJRPathEnumerator *enumerator = [_path pathEnumerator];
    AJRLine *line;
    AJRPathAnalysisContour *currentContour = nil;
    AJRLine previous;
    BOOL previousValid = NO, previousWasMoveTo = NO;
    CGFloat previousAngleOfInterest = 0.0;
    
    while ((line = [enumerator nextLineSegment])) {
        if ([enumerator isMoveToLineSegment]) {
            currentContour = [[AJRPathAnalysisContour alloc] init];
            [(NSMutableArray *)_contours addObject:currentContour];
            previousWasMoveTo = YES;
        } 
        
        if (AJRLineIsValid(*line)) {
            if (previousWasMoveTo) {
                AJRPathAnalysisCorner *corner = [[AJRPathAnalysisCorner alloc] init];
                CGFloat angle = AJRRoundAngle(AJRLineAngle(*line), 45.0);
                
                [(NSMutableArray *)[currentContour corners] addObject:corner];
                corner.angle = angle;
                corner.delta = angle;
                corner.point = line->start;
                
                previousAngleOfInterest = angle;

                previousWasMoveTo = NO;
            }
            if (!previousValid) {
                previousValid = YES;
                previousAngleOfInterest = AJRRoundAngle(AJRLineAngle(*line), 45.0);
            } else {
                CGFloat        newAngle = AJRRoundAngle(AJRLineAngle(*line), 45.0);
                if (fabs(previousAngleOfInterest - newAngle) > 40.0) {
                    AJRPathAnalysisCorner    *corner = [[AJRPathAnalysisCorner alloc] init];
                    
                    [(NSMutableArray *)[currentContour corners] addObject:corner];
                    corner.angle = previousAngleOfInterest;
                    corner.delta = newAngle - previousAngleOfInterest;
                    corner.point = line->start;
                    
                    previousAngleOfInterest = newAngle;
                }
            }
            previous = *line;
        }
    }
}

#pragma mark - Utilities

- (AJRBezierPath *)simplifiedPath {
    AJRBezierPath *path = [[AJRBezierPath alloc] init];
    
    for (AJRPathAnalysisContour *contour in _contours) {
        BOOL first = YES;
        for (AJRPathAnalysisCorner *corner in [contour corners]) {
            if (first) {
                [path moveToPoint:[corner point]];
                first = NO;
            } else {
                [path lineToPoint:[corner point]];
            }
        }
    }
    
    return path;
}

#pragma mark - NSObject

- (NSString *)description {
    return AJRFormat(@"<%C: %@>", self, _contours);
}

@end
