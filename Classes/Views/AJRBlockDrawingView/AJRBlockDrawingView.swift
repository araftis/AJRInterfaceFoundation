//
//  AJRBorderedView.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 3/19/19.
//  Copyright © 2019 Alex Raftis. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif
#if os(OSX)
import AppKit
#endif

public typealias AJRDrawingBlock = (_ context: CGContext, _ bounds: CGRect) -> Void

@objcMembers
open class AJRBlockDrawingView: AJRView {
    
    open var xColor : AJRColor? = nil
    internal var _flipped : Bool = false
    
    public var contentRenderer : AJRDrawingBlock? {
        didSet {
            needsDisplay = true
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public init(frame: CGRect, flipped: Bool) {
        _flipped = flipped
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func draw(_ rect: CGRect) {
        if let context = AJRGetCurrentContext() {
            if let xColor = xColor {
                context.setStrokeColor(xColor.cgColor)
                let path = AJRBezierPath()
                path.appendCrossedRect(bounds.insetBy(dx: 0.5, dy: 0.5))
                path.stroke()
            }
            contentRenderer?(context, bounds)
        }
    }

    open override var isFlipped: Bool {
        return _flipped
    }
    
}
