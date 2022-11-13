//
//  AJRMarkdownStyle.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 11/12/22.
//  Copyright © 2022 Alex Raftis. All rights reserved.
//

import AJRFoundation

@objcMembers
open class AJRMarkdownStyle : NSObject {

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
    var foregroundColor : AJRColor {
        get {
            return attributes[.foregroundColor] as! AJRColor
        }
        set {
            attributes[.foregroundColor] = newValue
        }
    }
    var backgroundColor : AJRColor {
        get {
            return attributes[.backgroundColor] as! AJRColor
        }
        set {
            attributes[.backgroundColor] = newValue
        }
    }
    var insertNewlineAfter = true

    public override init() {
        super.init()
        self.paragraphStyle = NSMutableParagraphStyle()
        self.font = AJRFont.userFont(ofSize: 13.0) ?? AJRFont.systemFont(ofSize: 13.0)
        self.foregroundColor = AJRColor.black
        self.backgroundColor = AJRColor.clear
    }

}
