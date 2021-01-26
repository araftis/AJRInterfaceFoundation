//
//  AJRColor.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 2/8/19.
//  Copyright © 2019 A.J. Raftis. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)

import UIKit

public typealias AJRColor = UIColor

#endif

#if os(OSX)

import AppKit

public typealias AJRColor = NSColor

#endif

public extension AJRColor {
    
    func multiply(saturation percent: CGFloat, brightness brightnessPercent: CGFloat) -> AJRColor? {
        var h : CGFloat = 0.0
        var s : CGFloat = 0.0
        var b : CGFloat = 0.0
        var a : CGFloat = 0.0
        
        if get(hue: &h, saturation: &s, brightness: &b, alpha: &a) {
            s *= percent;
            b *= brightnessPercent;
            return AJRColor(hue: h, saturation: s, brightness: b, alpha: a)
        }
        
        return nil;
    }

    func get(hue: inout CGFloat, saturation: inout CGFloat, brightness: inout CGFloat, alpha: inout CGFloat) -> Bool {
        return cgColor.get(hue: &hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    }
    
    func get(red: inout CGFloat, green: inout CGFloat, blue: inout CGFloat, alpha: inout CGFloat) -> Bool {
        return cgColor.get(red: &red, green: &green, blue: &blue, alpha: &alpha)
    }
    
    /**
     Returns true if the color is "dark", but which it's gray scale value is &lt; 0.25 on a scale of 0.0 to 1.0.
     */
    var isDark : Bool {
        return cgColor.whiteComponent ?? 1.0 < 0.25
    }

}
