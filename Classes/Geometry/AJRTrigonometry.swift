//
//  AJRTrigonometry.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 6/8/19.
//  Copyright © 2019 Alex Raftis. All rights reserved.
//

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

