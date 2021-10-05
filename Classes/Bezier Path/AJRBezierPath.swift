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
