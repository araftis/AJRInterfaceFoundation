
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
