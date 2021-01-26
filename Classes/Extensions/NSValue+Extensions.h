/* NSValue-Extensions.h created by alex on Tue 27-Oct-1998 */

#import <AJRInterfaceFoundation/AJRTrigonometry.h>
#import <AJRInterfaceFoundation/AJRBezierCurves.h>

@interface NSValue (Extensions) <AJRXMLCoding>

+ (id)valueWithBezierCurve:(AJRBezierCurve)curve;
- (AJRBezierCurve)bezierCurveValue;

+ (id)valueWithBezierRange:(AJRBezierRange)range;
- (AJRBezierRange)bezierRangeValue;

@end
