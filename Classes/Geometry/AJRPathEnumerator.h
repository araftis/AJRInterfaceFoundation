
#import <Foundation/Foundation.h>

#import <AJRInterfaceFoundation/AJRGeometry.h>
#import <AJRInterfaceFoundation/AJRTrigonometry.h>
#import <AJRInterfaceFoundation/AJRBezierPath.h>

@interface AJRPathEnumerator : NSObject

+ (id)enumeratorWithBezierPath:(AJRBezierPath *)path;
- (id)initWithBezierPath:(AJRBezierPath *)path;

@property (nonatomic,readonly) AJRBezierPath *path;

- (id)nextObject;

- (AJRLine *)nextLineSegment;
- (AJRBezierPathElementType *)nextElementWithPoints:(CGPoint *)points;

- (void)setError:(double)anError;
- (double)error;

- (double)tValue;
- (AJRBezierCurve)curve;    // Only valid if the current elementType is NSCurveToBezierPathElement
- (NSInteger)elementIndex;
- (AJRBezierPathElementType)elementType;
- (BOOL)isMoveToLineSegment;

@end
