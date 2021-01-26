
#import <AJRInterfaceFoundation/AJRGeometry.h>
#import <AJRInterfaceFoundation/AJRTrigonometry.h>

extern AJRBezierCurve AJRBezierCurveFromPoints(CGPoint *points, NSInteger pointCount, double error);

// Splits a bezier curve into two curves at t = 0.5
extern void AJRSplitBezierCurve(AJRBezierCurve input, AJRBezierCurve *left, AJRBezierCurve *right);
// Splits a bezier curve into two curves at t.
extern void AJRSplitBezierCurveAtT(AJRBezierCurve input, AJRBezierCurve *left, AJRBezierCurve *right, double t);

// Computes curve at t. t is a value between 0.0 and 1.0.
extern CGPoint AJRBezierCurveAtT(AJRBezierCurve curve, double t);
