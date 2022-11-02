/*
 AJRXView.swift
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

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif
#if os(OSX)
import AppKit
#endif

@objcMembers
open class AJRXView : AJRView {
    
    private var attributes : [NSAttributedString.Key:Any] = [
        .font: AJRFont.systemFont(ofSize: NSFont.systemFontSize(for: .mini)),
        .foregroundColor: AJRColor.black,
        ]
    @IBInspectable public var clear : Bool = false { didSet { needsDisplay = true } }
    @IBInspectable public var showFrame : Bool = false { didSet { needsDisplay = true } }
    @IBInspectable public var color: AJRColor = AJRColor.black { didSet { needsDisplay = true } }
    @IBInspectable public var backgroundColor: AJRColor = AJRColor.controlColor { didSet { needsDisplay = true } }

    override public init(frame: NSRect) {
        color = AJRColor.black
        backgroundColor = AJRColor.controlColor
        super.init(frame: frame)
    }
    
    override open func draw(_ dirtyRect: NSRect) {
        let bounds = self.bounds
        
        if !clear {
            backgroundColor.set()
            bounds.fill()
        }
    
        color.set()
        
        let path = AJRBezierPath()
        path.appendCrossedRect(bounds)
        path.stroke()

        if showFrame {
            (NSStringFromRect(bounds) as NSString).draw(at: NSPoint(x: 5, y: 5), withAttributes: attributes)
        }
    }
    
    override open var isOpaque: Bool {
        return !clear
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        clear = coder["clear"] ?? false
        showFrame = coder["showFrame"] ?? false
        color = coder["color"] ?? AJRColor.black
        backgroundColor = coder["backgroundColor"] ?? AJRColor.controlColor
    }
    
    override open func encode(with coder: NSCoder) {
        super.encode(with: coder)
        
        coder.encode(clear, forKey: "clear")
        coder.encode(showFrame, forKey: "showFrame")
        coder.encode(color, forKey: "color")
        coder.encode(backgroundColor, forKey: "backgroundColor")
    }
    
    override open var firstBaselineOffsetFromTop : CGFloat {
        return 10.0
    }
    
}

@objcMembers
open class AJRFlippedXView : AJRXView {
    
    open override var isFlipped: Bool {
        return true
    }
    
}
