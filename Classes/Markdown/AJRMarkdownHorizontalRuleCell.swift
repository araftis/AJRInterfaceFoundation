//
//  AJRMarkdownHorizontalRule.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 11/17/22.
//  Copyright © 2022 Alex Raftis. All rights reserved.
//

import Cocoa

@objcMembers
open class AJRMarkdownHorizontalRuleCell : NSTextAttachmentCell {
    
    open var thickness = CGFloat(2.0)
    open var height = CGFloat(2.0)
    /// The width of the horizontal rule expressed as a percentage (0.0 - 1.0) of the text container's width.
    open var width = CGFloat(1.0)
    open var color = NSColor(calibratedWhite: 0.0, alpha: 0.75)

    public override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        var rect = cellFrame
        rect.size.width *= width
        switch alignment {
        case .left:
            // Do nothing. We start off left justified.
            break
        case .justified: fallthrough
        case .center:
            rect.origin.x += (cellFrame.width - rect.width) / 2.0
        case .right:
            rect.origin.x += cellFrame.width - rect.width
        case .natural:
            break
        @unknown default:
            fatalError()
        }
        rect.size.height = thickness
        rect.origin.y += (cellFrame.height - rect.height) / 2.0
        rect = rect.integral
        // Sometimes making ourself "integral" changes our height. This happens to the width two, but visually speaking, we don't care about that.
        rect.size.height = thickness
        
//        NSColor.red.set()
//        cellFrame.frame()

        color.set()
        rect.fill()
    }
    
    public override func wantsToTrackMouse() -> Bool {
        return false
    }
    
    public override func cellSize() -> NSSize {
        return NSSize(width: 100, height: height)
    }
    
    public override func cellSize(forBounds rect: NSRect) -> NSSize {
        return NSSize(width: rect.width, height: height)
    }
    
    public override func cellFrame(for textContainer: NSTextContainer, proposedLineFragment lineFrag: NSRect, glyphPosition position: NSPoint, characterIndex charIndex: Int) -> NSRect {
        var rect = NSRect.zero
        
        rect.origin.x = 0
        rect.origin.y = 0
        rect.size.width = textContainer.size.width
        rect.size.height = height
        
        return rect
    }
    
    // MARK: - NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        let new = super.copy(with: zone) as! AJRMarkdownHorizontalRuleCell
        
        new.thickness = thickness
        new.height = height
        new.width = width
        new.color = color
        
        return new
    }
    
    open func copyHorizontalRule() -> AJRMarkdownHorizontalRuleCell {
        return copy() as! AJRMarkdownHorizontalRuleCell
    }
    
}
