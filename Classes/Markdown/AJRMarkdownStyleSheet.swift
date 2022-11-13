//
//  AJRMarkdownStyleSheet.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 11/12/22.
//  Copyright © 2022 Alex Raftis. All rights reserved.
//

import AJRFoundation

@objcMembers
open class AJRMarkdownStyleSheet : NSObject {

    open var styles = [PresentationIntent.Kind:AJRMarkdownStyle]()

    public static var basic : AJRMarkdownStyleSheet = {
        let styleSheet = AJRMarkdownStyleSheet()

        var style = AJRMarkdownStyle()
        style.font = AJRFont.systemFont(ofSize: 13.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        styleSheet.styles[.paragraph] = style

        style = AJRMarkdownStyle()
        style.font = AJRFont.boldSystemFont(ofSize: 18.0)
        style.paragraphStyle.paragraphSpacing = 18.0
        style.paragraphStyle.paragraphSpacingBefore = 9.0
        styleSheet.styles[.header(level: 1)] = style

        style = AJRMarkdownStyle()
        style.font = AJRFont.boldSystemFont(ofSize: 15.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.paragraphSpacingBefore = 9.0
        styleSheet.styles[.header(level: 2)] = style

        style = AJRMarkdownStyle()
        style.font = AJRFont.boldSystemFont(ofSize: 13.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.paragraphSpacingBefore = 9.0
        styleSheet.styles[.header(level: 3)] = style

        return styleSheet
    }()

    open func apply(to string: NSMutableAttributedString) -> Void {
        string.enumerateAttribute(.presentationIntentAttributeName, in: NSRange(location: 0, length: string.length)) { value, range, stop in
            if let value = value as? PresentationIntent {
                //print("\(range): \(value)")
                for component in value.components {
                    if let style = styles[component.kind] {
                        if style.insertNewlineAfter {
                            string.addAttributes(style.attributes, range: range)
                            string.insert(NSAttributedString(string: "\n"), at: range.upperBound)
                        }
                    } else {
                        AJRLog.warning("No style for \(component): \(string[range].string)")
                    }
                }
            }
        }
    }
}
