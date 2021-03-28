/*
AJRColor.swift
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
