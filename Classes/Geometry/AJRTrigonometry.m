
#import "AJRTrigonometry.h"

#import <stdlib.h>
#import <math.h>

NSString * const AJRTrigonometryErrorDomain = @"AJRTrigonometryErrorDomain";

inline double AJRRadiansToDegrees(double radians) {
   return radians / (M_PI / 180.0);
}

inline double AJRDegreesToRadians(double degrees) {
   return degrees * (M_PI / 180.0);
}

inline double AJRSin(double degrees) {
   return sin(AJRDegreesToRadians(degrees));
}

inline double AJRArcsin(double value) {
   return AJRRadiansToDegrees(asin(value));
}

inline double AJRCos(double degrees) {
   return cos(AJRDegreesToRadians(degrees));
}

inline double AJRArccos(double value) {
   return AJRRadiansToDegrees(acos(value));
}

inline double AJRTan(double degrees) {
   return tan(AJRDegreesToRadians(degrees));
}

double AJRArctan(double rise, double run) {
   if ((rise == 0.0) && (run == 0.0)) {
      [NSException raise:NSInvalidArgumentException format:@"A rise and run of 0.0 are invalid inputs to arctan."];
   }

   if (run == 0.0) {
      if (rise >= 0.0) {
         return 90.0;
      } else {
         return 270.0;
      }
   }

   if ((rise >= 0.0) && (run >= 0.0)) {
      return AJRRadiansToDegrees(atan(rise / run));
   } else if ((rise >= 0.0) && (run < 0.0)) {
      return AJRRadiansToDegrees(atan(rise / run)) + 180.0;
   } else if ((rise < 0.0) && (run >= 0.0)) {
      return AJRRadiansToDegrees(atan(rise / run)) + 360.0;
   }
   return AJRRadiansToDegrees(atan(rise / run)) + 180.0;
}

inline CGPoint AJRPolarToEuclidean(CGPoint origin, double angle, double length) {
   return AJRPointOnOval(origin, length, length, angle);
}

inline CGPoint AJRPointOnOval(CGPoint center, CGFloat xRadius, CGFloat yRadius, CGFloat angleInDegrees) {
    return NSMakePoint(center.x + cos(AJRDegreesToRadians(angleInDegrees - 90.0)) * xRadius,
                       center.y + sin(AJRDegreesToRadians(angleInDegrees - 90.0)) * yRadius);
}

inline double AJRRoundAngle(double angle, double granularity) {
    return rint(angle / granularity) * granularity;
}
