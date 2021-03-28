/*
AJROverlayTextMessageView.swift
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

import Cocoa

open class AJROverlayTextMessageView: AJRView {

    open var textLayer : AJROverlayTextMessageLayer {
        return layer as! AJROverlayTextMessageLayer
    }
    
    @IBInspectable var topMargin : CGFloat {
        get {
            return insets.top
        }
        set {
            var insets = self.insets
            insets.top = newValue
            self.insets = insets
        }
    }
    
    @IBInspectable var bottomMargin : CGFloat {
        get {
            return insets.bottom
        }
        set {
            var insets = self.insets
            insets.bottom = newValue
            self.insets = insets
        }
    }
    
    @IBInspectable var leftMargin : CGFloat {
        get {
            return insets.left
        }
        set {
            var insets = self.insets
            insets.left = newValue
            self.insets = insets
        }
    }
    
    @IBInspectable var rightMargin : CGFloat {
        get {
            return insets.right
        }
        set {
            var insets = self.insets
            insets.right = newValue
            self.insets = insets
        }
    }
    
    open var insets = AJREdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0) {
        didSet {
            textLayer.insets = insets
            needsLayout = true
        }
    }
    
    @IBInspectable open var font : AJRFont {
        didSet {
            textLayer.font = font
            needsLayout = true
        }
    }
    @IBInspectable open var textColor : AJRColor {
        didSet {
            textLayer.foregroundColor = textColor.cgColor
        }
    }
    @IBInspectable open var backgroundColor : AJRColor {
        didSet {
            textLayer.backgroundColor = backgroundColor.cgColor
        }
    }
    @IBInspectable open var message : String {
        didSet {
            textLayer.string = message
            needsLayout = true
        }
    }
    
    /**
     Here to allow bindings in IB.
     */
    open var value : Any? {
        get {
            return message
        }
        set(objectValue) {
            // Because we can bind to a single image or multiple images.
            if let objectValue = objectValue as? String {
                message = objectValue
            } else if let objectValue = objectValue as? CustomStringConvertible {
                message = objectValue.description
            } else {
                message = String(describing: objectValue)
            }
        }
    }
    
    public override init(frame frameRect: NSRect) {
        self.font = AJRFont.systemFont(ofSize: 18.0, weight: .semibold)
        self.textColor = AJRColor.textColor
        self.backgroundColor = AJRColor(deviceWhite: 1.0, alpha: 0.25)
        self.message = ""
        
        super.init(frame: frameRect)

        self.wantsLayer = true
    }
    
    required public init?(coder: NSCoder) {
        self.font = coder.decodeObject(of: AJRFont.self, forKey: "font") ?? AJRFont.systemFont(ofSize: 18.0, weight: .semibold)
        self.textColor = coder.decodeObject(of: AJRColor.self, forKey: "textColor") ?? AJRColor.textColor
        self.backgroundColor = coder.decodeObject(of: AJRColor.self, forKey: "backgroundColor") ?? AJRColor(deviceWhite: 1.0, alpha: 0.25)
        self.message = (coder.decodeObject(of: NSString.self, forKey: "message") ?? "") as String
        super.init(coder: coder)
        self.wantsLayer = true
    }
    
    open override func makeBackingLayer() -> CALayer {
        let layer = AJROverlayTextMessageLayer(message: message)
        layer.backgroundColor = backgroundColor.cgColor
        layer.foregroundColor = textColor.cgColor
        layer.font = font
        if let screen = self.window?.screen {
            layer.contentsScale = screen.backingScaleFactor
        }
        return layer
    }
    
    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(font, forKey: "font")
        coder.encode(textColor, forKey: "textColor")
        coder.encode(backgroundColor, forKey: "backgroundColor")
        coder.encode(message, forKey: "message")
    }
    
    open override var intrinsicContentSize: CGSize {
        return textLayer.preferredFrameSize()
    }
    
}
