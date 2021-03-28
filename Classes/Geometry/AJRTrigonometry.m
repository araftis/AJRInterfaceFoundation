/*
AJRTrigonometry.m
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
