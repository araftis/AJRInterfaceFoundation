
#import <Foundation/Foundation.h>

#import <AJRInterfaceFoundation/AJRBezierPath.h>

@class AJRVertex;

@interface AJRPolygon : NSObject

@property (nonatomic,strong) NSString *prefix;
@property (nonatomic,strong) NSColor *color;
@property (nonatomic,strong) AJRBezierPathPointTransform transform;

#pragma mark - Path Construction

- (void)moveToPoint:(CGPoint)point;
- (void)lineToPoint:(CGPoint)point;
- (void)curveToPoint:(CGPoint)point controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;

#pragma mark - Drawing

- (void)draw;
- (void)drawPoints;

@end
