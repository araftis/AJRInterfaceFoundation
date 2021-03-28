/*
AJRTrigonometry.swift
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

import Foundation

public enum AJRTrigonometryError : Error {
    case invalidParemeters(message: String)
}

@inlinable public func AJRDegreesToRadians<T:BinaryFloatingPoint>(_ degrees: T) -> T {
    return degrees * (T(Double.pi) / T(180.0))
}

@inlinable public func AJRRadiansToDegrees<T:BinaryFloatingPoint>(_ radians: T) -> T {
    return radians / (T(Double.pi) / T(180.0));
}

public extension Double {
    
    func toRadians() -> Double {
        return AJRDegreesToRadians(self)
    }
    
    func toDegrees() -> Double {
        return AJRRadiansToDegrees(self)
    }
    
}

@inlinable public func AJRSin<T:BinaryFloatingPoint>(_ degrees: T) -> T {
    return T(sin(Double(degrees).toRadians()))
}

@inlinable public func AJRArcsin<T:BinaryFloatingPoint>(_ value: T) -> T {
    return T(asin(Double(value)).toDegrees())
}

@inlinable public func AJRCos<T:BinaryFloatingPoint>(_ degrees: T) -> T {
    return T(cos(Double(degrees).toRadians()))
}

@inlinable public func AJRArccos<T:BinaryFloatingPoint>(_ value: T) -> T {
    return T(acos(Double(value)).toDegrees())
}

@inlinable public func AJRTan<T:BinaryFloatingPoint>(_ degrees: T) -> T {
    return T(tan(Double(degrees).toRadians()))
}

public func AJRArctan<T:BinaryFloatingPoint>(rise: T, run: T) throws -> T {
   if (rise == 0.0) && (run == 0.0) {
    throw AJRTrigonometryError.invalidParemeters(message: "A rise and run of 0.0 are invalid inputs to arctan.")
   }

   if run == 0.0 {
      if rise >= 0.0 {
         return 90.0
      } else {
         return 270.0
      }
   }

    if (rise >= 0.0) && (run >= 0.0) {
        return T(atan(Double(rise / run)).toDegrees())
    } else if (rise >= 0.0) && (run < 0.0) {
        return T(atan(Double(rise / run)).toDegrees() + 180.0)
    } else if (rise < 0.0) && (run >= 0.0) {
        return T(atan(Double(rise / run)).toDegrees() + 360.0)
    }
    return T(atan(Double(rise / run)).toDegrees() + 180.0)
}

@inlinable public func AJRPolarToEuclidean<T:BinaryFloatingPoint>(source: CGPoint, angle: T, length: T) -> CGPoint {
    return AJRPointOnOval(origin: source, xRadius: length, yRadius: length, angle: angle)
}

@inlinable public func AJRPointOnOval<T:BinaryFloatingPoint>(origin: CGPoint, xRadius: T, yRadius: T, angle: T) -> CGPoint {
    return CGPoint(x: CGFloat(AJRCos(angle - 90.0) * xRadius) + origin.x,
                   y: CGFloat(AJRSin(angle - 90.0) * yRadius) + origin.y)
}

