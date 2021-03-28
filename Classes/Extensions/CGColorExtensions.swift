/*
CGColorExtensions.swift
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

import CoreGraphics

public extension CGColor {
    
    // MARK: - Standard Colors
	
//    public static var black : CGColor {
//        return AJRColorBlack()
//    }
    
    static var blue : CGColor {
        return AJRColorBlue()
    }

    static var brown : CGColor {
        return AJRColorBrown()
    }

    static var cyan : CGColor {
        return AJRColorCyan()
    }

    static var green : CGColor {
        return AJRColorGreen()
    }

    static var magenta : CGColor {
        return AJRColorMagenta()
    }

    static var orange : CGColor {
        return AJRColorOrange()
    }

    static var purple : CGColor {
        return AJRColorPurple()
    }

    static var red : CGColor {
        return AJRColorRed()
    }

    static var yellow : CGColor {
        return AJRColorYellow()
    }

    static var gray : CGColor {
        return AJRColorGray()
    }

    static var darkGray : CGColor {
        return AJRColorDarkGray()
    }

    static var lightGray : CGColor {
        return AJRColorLightGray()
    }

    // MARK - Creating Colors
    
    static func color(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) -> CGColor {
		return CGColor(colorSpace:AJRGetSRGBColorSpace(), components:[red, green, blue, alpha])!
	}
	
    static func color(white:CGFloat, alpha:CGFloat) -> CGColor {
		return CGColor(colorSpace:AJRGetGrayColorSpace(), components:[white, alpha])!
	}
	
    static func color(cyan:CGFloat, magenta:CGFloat, yellow:CGFloat, black:CGFloat, alpha:CGFloat) -> CGColor {
		return CGColor(colorSpace:AJRGetCMYKColorSpace(), components:[cyan, magenta, yellow, black, alpha])!
	}
	
    // MARK: - Color Components
    
    /*
     NOTE: desiredColorSpace should be one with components. If you use something like pattern, stuff's gunna blow.
     */
    private func component(at index: Int, using desiredColorSpace: CGColorSpace, convertToHSB: Bool = false) -> CGFloat? {
        var color : CGColor? = self
        var component : CGFloat?
        
        // See if we need to convert the color space
        let colorSpace = color?.colorSpace
        if colorSpace?.model != desiredColorSpace.model {
            color = color?.converted(to: desiredColorSpace, intent: .defaultIntent, options: nil)
        }

        if color != nil {
            if convertToHSB {
                if let components = color?.components {
                    var h: CGFloat = 0.0
                    var s: CGFloat = 0.0
                    var b: CGFloat = 0.0
                    AJRRGBToHSB(components[0], components[1], components[2], &h, &s, &b)
                    switch (index) {
                    case 0: component = h
                    case 1: component = s
                    case 2: component = b
                    case 3: component = components[3]
                    default:
                        preconditionFailure("Asked for a comonent outside the range of [0...\(colorSpace!.numberOfComponents + 1)]")
                    }
                }
            } else {
                if let components = color?.components {
                    component = components[index];
                }
            }
        }

        return component
    }
    
    var redComponent : CGFloat? {
        return component(at: 0, using: AJRGetSRGBColorSpace())
    }
    
    var greenComponent : CGFloat? {
        return component(at: 1, using: AJRGetSRGBColorSpace())
    }

    var blueComponent : CGFloat? {
        return component(at: 2, using: AJRGetSRGBColorSpace())
    }

    var alphaComponent : CGFloat? {
        return component(at: 3, using: AJRGetSRGBColorSpace())
    }
    
    var whiteComponent : CGFloat? {
        return component(at: 0, using: AJRGetGrayColorSpace())
    }

    var hueComponent : CGFloat? {
        return component(at: 0, using: AJRGetSRGBColorSpace(), convertToHSB: true)
    }

    var saturationComponent : CGFloat? {
        return component(at: 1, using: AJRGetSRGBColorSpace(), convertToHSB: true)
    }

    var brightnessComponent : CGFloat? {
        return component(at: 2, using: AJRGetSRGBColorSpace(), convertToHSB: true)
    }

    var cyanComponent : CGFloat? {
        return component(at: 0, using: AJRGetCMYKColorSpace())
    }
    
    var magentaComponent : CGFloat? {
        return component(at: 1, using: AJRGetCMYKColorSpace())
    }
    
    var yellowComponent : CGFloat? {
        return component(at: 2, using: AJRGetCMYKColorSpace())
    }
    
    var blackComponent : CGFloat? {
        return component(at: 3, using: AJRGetCMYKColorSpace())
    }
    
    func get(hue: inout CGFloat, saturation: inout CGFloat, brightness: inout CGFloat, alpha: inout CGFloat) -> Bool {
        if let converted = self.converted(to: AJRGetSRGBColorSpace(), intent: .defaultIntent, options: nil) {
            // Force unwrapping is OK here, because if we converted to sRGB, we'll always get back rgb component.
            AJRRGBToHSB(converted.redComponent!, converted.greenComponent!, converted.blueComponent!, &hue, &saturation, &brightness)
            alpha = converted.alphaComponent!
            return true
        }
        return false
    }
    
    func get(red: inout CGFloat, green: inout CGFloat, blue: inout CGFloat, alpha: inout CGFloat) -> Bool {
        if let converted = self.converted(to: AJRGetSRGBColorSpace(), intent: .defaultIntent, options: nil) {
            red = converted.redComponent!
            green = converted.greenComponent!
            blue = converted.blueComponent!
            alpha = converted.alphaComponent!
            return true
        }
        return false
    }

}
