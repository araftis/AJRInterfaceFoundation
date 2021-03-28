
#import <AJRInterfaceFoundation/AJRTrigonometry.h>
#import <AJRInterfaceFoundation/AJRBezierCurves.h>

@interface NSValue (Extensions) <AJRXMLCoding>

+ (id)valueWithBezierCurve:(AJRBezierCurve)curve;
- (AJRBezierCurve)bezierCurveValue;

+ (id)valueWithBezierRange:(AJRBezierRange)range;
- (AJRBezierRange)bezierRangeValue;

@end
