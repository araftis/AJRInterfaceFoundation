
#import <AJRInterfaceFoundation/AJRBezierPath.h>

extern CGContextRef AJRHitTestContext(void);
extern void AJRPathToBezierIterator(void *info, const CGPathElement *element);

@interface AJRBezierPath (Private)

- (void)_setupDrawingContext:(CGContextRef)context;
- (void)_setCoordinateMaxCount:(NSUInteger)max;
- (void)_increaseCoordinateCountBy:(NSUInteger)count;
- (void)_setOperationMaxCount:(NSUInteger)max;
- (void)_increaseOperationCountBy:(NSUInteger)count;
- (void)_unionRectWithBoundingBox:(CGRect)rect;
- (void)_intersectPointWithBounds:(CGPoint)aPoint forMoveTo:(BOOL)flag;
- (void)_updateBoundingBox;

@end
