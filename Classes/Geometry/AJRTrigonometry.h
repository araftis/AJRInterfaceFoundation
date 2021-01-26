
#import <Foundation/Foundation.h>

#import <AJRInterfaceFoundation/AJRGeometry.h>

extern NSString * const AJRTrigonometryErrorDomain;

extern double AJRRadiansToDegrees(double radians);
extern double AJRDegreesToRadians(double degrees);
extern double AJRSin(double angle);
extern double AJRCos(double angle);
extern double AJRTan(double angle);
extern double AJRArcsin(double angle);
extern double AJRArccos(double angle);
extern double AJRArctan(double rise, double run);
extern CGPoint AJRPolarToEuclidean(CGPoint origin, double angle, double length);
extern CGPoint AJRPointOnOval(CGPoint center, CGFloat xRadius, CGFloat yRadius, CGFloat angleInDegrees);

extern double AJRRoundAngle(double angle, double granularity);

