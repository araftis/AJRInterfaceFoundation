//
//  AJRMarkdownStyleSheet.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 11/12/22.
//  Copyright © 2022 Alex Raftis. All rights reserved.
//

import AJRFoundation

internal extension Array where Element == PresentationIntent.IntentType {

    var listType : PresentationIntent.IntentType? {
        return self.first { $0.kind == .orderedList || $0.kind == .unorderedList }
    }

    var listOrdinal : Int? {
        for possible in self {
            switch possible.kind {
            case .listItem(let ordinal):
                return ordinal
            default:
                break
            }
        }
        return nil
    }

    var isOrderedList : Bool {
        return contains { $0.kind == .orderedList }
    }

    var isUnorderedList : Bool {
        return contains { $0.kind == .unorderedList }
    }

}

@objcMembers
open class AJRMarkdownStyleSheet : NSObject {

    open var styles = [PresentationIntent.Kind:AJRMarkdownStyle]()

    public static var basic : AJRMarkdownStyleSheet = {
        let styleSheet = AJRMarkdownStyleSheet()
        var tabStops = [NSTextTab]()

        // Creat 20 default tab stops at quarter inch intervals.
        for i in 0 ..< 20 {
            let tabStop = NSTextTab(textAlignment: .left, location: CGFloat(i + 1) * 0.25 * 72.0, options: [:])
            tabStops.append(tabStop)
        }

        var style = AJRMarkdownStyle()
        style.font = AJRFont.systemFont(ofSize: 13.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.tabStops = tabStops
        styleSheet.styles[.paragraph] = style

        style = AJRMarkdownStyle()
        style.font = AJRFont.boldSystemFont(ofSize: 24.0)
        style.paragraphStyle.paragraphSpacing = 18.0
        style.paragraphStyle.paragraphSpacingBefore = 9.0
        style.paragraphStyle.headerLevel = 1
        styleSheet.styles[.header(level: 1)] = style

        style = AJRMarkdownStyle()
        style.font = AJRFont.boldSystemFont(ofSize: 18.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.paragraphSpacingBefore = 9.0
        style.paragraphStyle.headerLevel = 2
        styleSheet.styles[.header(level: 2)] = style

        style = AJRMarkdownStyle()
        style.font = AJRFont.boldSystemFont(ofSize: 15.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.paragraphSpacingBefore = 9.0
        style.paragraphStyle.headerLevel = 3
        styleSheet.styles[.header(level: 3)] = style

        style = AJRMarkdownStyle()
        style.font = AJRFont.boldSystemFont(ofSize: 13.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.paragraphSpacingBefore = 9.0
        style.paragraphStyle.headerLevel = 4
        styleSheet.styles[.header(level: 4)] = style

        style = AJRMarkdownStyle()
        style.font = AJRFont.systemFont(ofSize: 13.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.tabStops = tabStops
        styleSheet.styles[.unorderedList] = style

        style = AJRMarkdownStyle()
        style.font = AJRFont.systemFont(ofSize: 13.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.tabStops = tabStops
        styleSheet.styles[.orderedList] = style

        return styleSheet
    }()

    internal var currentSpecialStart : Int?
    internal var currentSpecialEnd : Int?
    internal var currentTextLists : [NSTextList]?
    internal var currentListStyle : AJRMarkdownStyle?

    open func apply(to string: NSMutableAttributedString) -> Void {
        string.enumerateAttribute(.presentationIntentAttributeName, in: NSRange(location: 0, length: string.length)) { value, range, stop in
            if let value = value as? PresentationIntent {
                //print("\(range): \(value)")
                let components = value.components
                var textRange = range

                if components.listType != nil {
                    self.apply(to: string, range: range, listIntent: value)
                } else {
                    if currentSpecialStart != nil {
                        currentSpecialEnd = range.upperBound
                        completeListIfNecessary(on: string)
                    }
                    for component in value.components {
                        self.apply(to: string, range: &textRange, kind: component.kind)
                    }
                }
            }
        }
        string.fixAttributes(in: NSRange(location: 0, length: string.length))
    }

    open func apply(to string: NSMutableAttributedString,
                    range: inout NSRange,
                    kind: PresentationIntent.Kind) {
        if let style = styles[kind] {
            string.addAttributes(style.attributes, range: range)
            if style.insertNewlineAfter {
                string.insert(NSAttributedString(string: "\n"), at: range.upperBound)
                range.length += 1
            }
        } else {
            AJRLog.warning("No style for \(kind): \(string[range].string)")
        }
    }

    open func apply(to string: NSMutableAttributedString,
                    range: NSRange,
                    listIntent: PresentationIntent) {
        var textRange = range

        if currentTextLists == nil {
            currentTextLists = [NSTextList]()
            currentSpecialStart = range.lowerBound
            if listIntent.components.isOrderedList {
                currentListStyle = styles[.orderedList]
            } else if listIntent.components.isUnorderedList {
                currentListStyle = styles[.unorderedList]
            }
        }

        // Make sure we have an NSTextList for the current level.
        if currentTextLists!.count < listIntent.indentationLevel {
            var textList : NSTextList? = nil
            if listIntent.components.isOrderedList {
                textList = NSTextList(markerFormat: .decimal, options: 0)
            } else if listIntent.components.isUnorderedList {
                textList = NSTextList(markerFormat: unorderedListMarker(forLevel: listIntent.indentationLevel), options: 0)
            }
            if let textList {
                currentTextLists!.append(textList)
            }
        }

        //apply(to: string, range: &textRange, kind: .paragraph)
        string.insert(NSAttributedString(string: "\n"), at: textRange.upperBound)
        textRange.length += 1

        if let prefix = prefix(for: listIntent) {
            let attributes = string.attributes(at: textRange.lowerBound, effectiveRange: nil)
            string.insert(NSAttributedString(string: prefix, attributes: attributes), at: textRange.lowerBound)
            textRange.length += string.length
        }
    }

    open func prefix(for intent: PresentationIntent) -> String? {
        var marker : String? = nil

        if intent.components.isOrderedList {
            if let ordinal = intent.components.listOrdinal {
                marker = "\(ordinal)."
            }
        } else if intent.components.isUnorderedList {
            marker = unorderedListMarkerString(forLevel: intent.indentationLevel)
        }
        if let marker {
            var prefix = ""
            for _ in 0 ..< intent.indentationLevel {
                prefix += "\t"
            }
            prefix += marker
            prefix += "\t"
            return prefix
        }
        return nil
    }

    open func completeListIfNecessary(on string: NSMutableAttributedString) -> Void {
        if let currentTextLists,
           let currentSpecialStart,
           let currentSpecialEnd,
           let currentListStyle {
            let style = currentListStyle.copy() as! AJRMarkdownStyle
            let range = NSRange(location: currentSpecialStart, length: currentSpecialEnd - currentSpecialStart)

            // Modify the style, as needed
            style.paragraphStyle.textLists = currentTextLists

            string.removeAttribute(.presentationIntentAttributeName, range: range)
            string.addAttributes(style.attributes, range: range)

            self.currentTextLists = nil
            self.currentListStyle = nil
            self.currentSpecialStart = nil
            self.currentSpecialEnd = nil
        }
    }

    // MARK: - Unordered List Markers

    open var unorderedListMarkers : [NSTextList.MarkerFormat] = [.disc, .circle, .box]

    internal var unorderedListMarkerStrings : [NSTextList.MarkerFormat : String] = [
        .disc : "•",
        .circle : "◦",
        .box : "■",
    ]

    open func setUnorderedListMarker(_ markerFormat: NSTextList.MarkerFormat, to string: String) {
        unorderedListMarkerStrings[markerFormat] = string
    }

    open func unorderedListMarker(for markerFormat: NSTextList.MarkerFormat) -> String? {
        return unorderedListMarkerStrings[markerFormat]
    }

    open func unorderedListMarkerString(forLevel level: Int) -> String? {
        var index = level
        if index > unorderedListMarkers.count {
            index = unorderedListMarkers.count
        }
        return unorderedListMarkerStrings[unorderedListMarkers[index - 1]]
    }

    open func unorderedListMarker(forLevel level: Int) -> NSTextList.MarkerFormat {
        var index = level
        if index > unorderedListMarkers.count {
            index = unorderedListMarkers.count
        }
        return unorderedListMarkers[index - 1]
    }

}
