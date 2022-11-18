//
//  AJRMarkdownStyle.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 11/12/22.
//  Copyright © 2022 Alex Raftis. All rights reserved.
//

import AJRFoundation

@objcMembers
open class AJRMarkdownStyle : NSObject, NSCopying {

    var attributes = [NSAttributedString.Key:Any]()

    var paragraphStyle : NSMutableParagraphStyle {
        get {
            return attributes[.paragraphStyle] as! NSMutableParagraphStyle
        }
        set {
            attributes[.paragraphStyle] = newValue
        }
    }
    var font : AJRFont {
        get {
            return attributes[.font] as! AJRFont
        }
        set {
            attributes[.font] = newValue
        }
    }
    var foregroundColor : AJRColor? {
        get {
            return attributes[.foregroundColor] as? AJRColor
        }
        set {
            attributes[.foregroundColor] = newValue
        }
    }
    var backgroundColor : AJRColor? {
        get {
            return attributes[.backgroundColor] as? AJRColor
        }
        set {
            attributes[.backgroundColor] = newValue
        }
    }
    var insertNewlineAfter = true
    
    var horizonalRuleAttachment : AJRMarkdownHorizontalRuleCell? = nil

    public override init() {
        super.init()
        self.paragraphStyle = NSMutableParagraphStyle()
        self.paragraphStyle.alignment = .left
        self.paragraphStyle.tighteningFactorForTruncation = 0.0
        self.paragraphStyle.allowsDefaultTighteningForTruncation = false
        self.font = AJRFont.userFont(ofSize: 13.0) ?? AJRFont.systemFont(ofSize: 13.0)
    }

    // MARK: - Conveniences
    
    open func createHorizontalRuleAttachment() -> NSTextAttachment {
        let attachment = NSTextAttachment()
        if let horizonalRuleAttachment {
            attachment.attachmentCell = horizonalRuleAttachment.copyHorizontalRule()
        }
        return attachment
    }
    
    // MARK: - NSCopying

    public func copy(with zone: NSZone? = nil) -> Any {
        let new = AJRMarkdownStyle()
        new.attributes = attributes
        if let styleCopy = (attributes[.paragraphStyle] as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle {
            new.attributes[.paragraphStyle] = styleCopy
        }
        new.insertNewlineAfter = insertNewlineAfter
        new.horizonalRuleAttachment = horizonalRuleAttachment?.copyHorizontalRule()
        return new
    }
    
    public func copyStyle() -> AJRMarkdownStyle {
        // If this forced typecast fails, we deserve to crash.
        return self.copy() as! AJRMarkdownStyle
    }

}
