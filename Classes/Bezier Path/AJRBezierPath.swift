//
//  AJRBezierPath.swift
//  AJRInterfaceFoundation
//

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
    
    func line<T: BinaryInteger>(to point: (T, T)) -> Void {
        line(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
    }
    
    func line<T: BinaryFloatingPoint>(to point: (T, T)) -> Void {
        line(to: CGPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
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
