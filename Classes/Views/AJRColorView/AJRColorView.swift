//
//  AJRColorView.swift
//  AJRInterface
//
//  Created by AJ Raftis on 2/8/19.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif
#if os(OSX)
import AppKit
#endif

@objcMembers
open class AJRColorView: AJRView {

    // MARK: - Properties
    
    public var color: AJRColor = AJRColor(white: 0.0, alpha: 0.25) {
        didSet {
            needsDisplay = true
        }
    }
    
    // MARK: - Creation
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        color = coder["color"] ?? AJRColor(white: 0.0, alpha: 0.25)
        super.init(coder: coder)
    }
    
    // MARK: - NSView
    
    open override var isOpaque: Bool {
        return false
    }
    
    open override func draw(_ dirtyRect: CGRect) {
        color.setFill()
        dirtyRect.fill(using: .sourceOver)
    }
    
}
