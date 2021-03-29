/*
AJROverlayTextMessageLayer.swift
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

import Cocoa

@objcMembers
open class AJROverlayTextMessageLayer: AJRTextLayer {
    
    // MARK: - Properties
    
    open var _insets : AJREdgeInsets?
    open var insets : AJREdgeInsets! {
        get {
            if let insets = _insets {
                return insets
            }
            let pointSize = font.pointSize
            return AJREdgeInsets(top: pointSize / 2.0, left: pointSize, bottom: pointSize / 2.0, right: pointSize)
        }
        set {
            _insets = newValue
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    // MARK: - Creation
    
    internal func commonInit() -> Void {
        backgroundColor = AJRColor(deviceWhite: 1.0, alpha: 0.33).cgColor
        cornerRadius = frame.size.height / 2.0
    }
    
    public init(message: String ) {
        super.init()
        
        self.string = message
        commonInit()
    }
    
    public override init() {
        super.init()
        commonInit()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Layout
    
    open override func textRect(for bounds: CGRect) -> CGRect {
        return bounds.inset(with: insets)
    }
    
    // MARK: - CALayer
    
    open override func preferredFrameSize() -> CGSize {
        var size = super.preferredFrameSize()
        size.width += (insets.left + insets.right)
        size.height += (insets.top + insets.bottom)
        return size
    }
    
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        cornerRadius = frame.size.height / 2.0
    }
    
}
