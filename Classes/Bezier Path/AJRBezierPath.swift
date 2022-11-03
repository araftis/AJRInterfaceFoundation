/*
 AJRBezierPath.swift
 AJRInterfaceFoundation

 Copyright © 2022, AJ Raftis and AJRInterfaceFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterfaceFoundation nor the names of its contributors may be
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

/**
 Some useful extensions to make using from Swift a little nicer.
 */

public extension AJRBezierPath {

    static var hairLineWidth : CGFloat = 0.0

    func move<T: BinaryInteger>(to point: (T, T)) -> Void {
        move(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func move<T: BinaryFloatingPoint>(to point: (T, T)) -> Void {
        move(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func moveTo<T: BinaryInteger>(x: T, y: T) -> Void {
        move(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func moveTo<T: BinaryFloatingPoint>(x: T, y: T) -> Void {
        move(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func line<T: BinaryInteger>(to point: (T, T)) -> Void {
        line(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func line<T: BinaryFloatingPoint>(to point: (T, T)) -> Void {
        line(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func lineTo<T: BinaryInteger>(x: T, y: T) -> Void {
        line(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func lineTo<T: BinaryFloatingPoint>(x: T, y: T) -> Void {
        line(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func relativeLine<T: BinaryInteger>(to point: (T, T)) -> Void {
        relativeLine(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func relativeLine<T: BinaryFloatingPoint>(to point: (T, T)) -> Void {
        relativeLine(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func relativeLineTo<T: BinaryInteger>(x: T, y: T) -> Void {
        relativeLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func relativeLineTo<T: BinaryFloatingPoint>(x: T, y: T) -> Void {
        relativeLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }
    
    func curve<T: BinaryInteger>(to point: (T, T), controlPoint1 cp1: (T, T), controlPoint2 cp2: (T, T)) -> Void {
        curve(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)),
              controlPoint1: CGPoint(x: CGFloat(cp1.0), y: CGFloat(cp1.1)),
              controlPoint2: CGPoint(x: CGFloat(cp2.0), y: CGFloat(cp2.1)))
    }
    
    func curve<T: BinaryFloatingPoint>(to point: (T, T), controlPoint1 cp1: (T, T), controlPoint2 cp2: (T, T)) -> Void {
        curve(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)),
              controlPoint1: CGPoint(x: CGFloat(cp1.0), y: CGFloat(cp1.1)),
              controlPoint2: CGPoint(x: CGFloat(cp2.0), y: CGFloat(cp2.1)))
    }
    
    func setLineDash(_ dashes: [CGFloat]?, phase: CGFloat = 0.0) -> Void {
        if let dashes {
            var temp = dashes
            temp.withUnsafeMutableBytes { buffer in
                setLineDash(buffer.baseAddress?.assumingMemoryBound(to: CGFloat.self), count: dashes.count, phase: phase)
            }
        } else {
            setLineDash(nil, count: 0, phase: 0.0)
        }
    }
    
    func getLineDash(phase: inout CGFloat?) -> [CGFloat] {
        var count : Int = 0
        var dash : [CGFloat]
        var fetchedPhase : CGFloat = 0.0
        
        getLineDash(nil, count: &count, phase: &fetchedPhase)
        phase? = fetchedPhase
        
        dash = [CGFloat](repeating: 0.0, count: count)
        let raw = UnsafeMutablePointer<CGFloat>.allocate(capacity: count)
        getLineDash(raw, count: nil, phase: nil)
        for x in 0 ..< count {
            dash[x] = raw[x]
        }
        
        return dash
    }
    
    // MARK: - Drawing Conveniences
    
    func stroke(color: AJRColor) {
        color.set()
        stroke()
    }
    
    func fill(color: AJRColor) {
        color.set()
        fill()
    }
    
}

///
/// And some more extensions that make working with the bezier path enums nicer.
///

extension AJRWindingRule : AJRUserDefaultProvider, AJRXMLEncodableEnum {
    
    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> AJRWindingRule? {
        if let value = userDefaults.string(forKey: key) {
            return AJRWindingRule(string: value)
        }
        return nil
    }
    
    public static func setUserDefault(_ value: AJRWindingRule?, forKey key: String, into userDefaults: UserDefaults) {
        if let value {
            userDefaults.set(value.description, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    public static var allCases: [AJRWindingRule] = [.nonZero, .evenOdd]
        
    public var description: String {
        switch self {
        case .evenOdd: return "evenOdd"
        case .nonZero: return "nonZero"
        @unknown default:
            preconditionFailure("Unknown case in AJRWindingRule. This shouldn't happen.")
        }
    }
}

extension AJRBezierPathElementType : AJRUserDefaultProvider, AJRXMLEncodableEnum {
    
    public static var allCases: [AJRBezierPathElementType] = [.setBoundingBox, .moveTo, .lineTo, .curveTo, .close]
    
    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> AJRBezierPathElementType? {
        if let value = userDefaults.string(forKey: key) {
            return AJRBezierPathElementType(string: value)
        }
        return nil
    }
    
    public static func setUserDefault(_ value: AJRBezierPathElementType?, forKey key: String, into userDefaults: UserDefaults) {
        if let value {
            userDefaults.set(value.description, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    public var description: String {
        switch self {
        case .setBoundingBox: return "setBoundingBox"
        case .moveTo: return "moveTo"
        case .lineTo: return "lineTo"
        case .curveTo: return "curveTo"
        case .close: return "close"
        @unknown default:
            preconditionFailure("Unknown case in \(type(of: self)). This shouldn't happen.")
        }
    }
    
}

extension AJRLineCapStyle : AJRUserDefaultProvider, AJRXMLEncodableEnum {
    
    public static var allCases: [AJRLineCapStyle] = [.butt, .round, .square]
    
    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> AJRLineCapStyle? {
        if let value = userDefaults.string(forKey: key) {
            return AJRLineCapStyle(string: value)
        }
        return nil
    }
    
    public static func setUserDefault(_ value: AJRLineCapStyle?, forKey key: String, into userDefaults: UserDefaults) {
        if let value {
            userDefaults.set(value.description, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    public var description: String {
        switch self {
        case .butt: return "butt"
        case .round: return "round"
        case .square: return "square"
        @unknown default:
            preconditionFailure("Unknown case in \(type(of: self)). This shouldn't happen.")
        }
    }
    
}

extension AJRLineJoinStyle : AJRUserDefaultProvider, AJRXMLEncodableEnum {
    
    public static var allCases: [AJRLineJoinStyle] = [.mitered, .round, .beveled]
    
    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> AJRLineJoinStyle? {
        if let value = userDefaults.string(forKey: key) {
            return AJRLineJoinStyle(string: value)
        }
        return nil
    }
    
    public static func setUserDefault(_ value: AJRLineJoinStyle?, forKey key: String, into userDefaults: UserDefaults) {
        if let value {
            userDefaults.set(value.description, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    public var description: String {
        switch self {
        case .mitered: return "mitered"
        case .round: return "round"
        case .beveled: return "beveled"
        @unknown default:
            preconditionFailure("Unknown case in \(type(of: self)). This shouldn't happen.")
        }
    }
    
}
