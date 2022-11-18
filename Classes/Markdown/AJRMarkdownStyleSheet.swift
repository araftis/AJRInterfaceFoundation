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

    var isHorizontalRule : Bool {
        return contains { $0.kind == .thematicBreak }
    }

}

@objcMembers
open class AJRMarkdownStyleSheet : NSObject {

    internal var styles = [PresentationIntent.Kind:AJRMarkdownStyle]()

    internal struct ListTracker {
        internal var start : Int = 0
        internal var end : Int = 0
        internal var style : AJRMarkdownStyle
        internal var lastLevel : Int = 0
        internal var lastStyle : AJRMarkdownStyle?
        internal var lastItemRange : NSRange?
        
        init(style: AJRMarkdownStyle) {
            self.style = style
        }
    }
    internal var currentList : ListTracker?

    /**
     Enumerates the attributed string and replaces the `PresentationIntent` objects with actual styles. As needed, this will also add newlines and other text to the string. For example, lists will add there item markers, such as '•' or '1.'.
     
     This method mostly enumerates the string looking for `PresentationIntent` attributes. It then calls `apply(to:range:kind:)` to actually apply the style. This also supports some of the basic logic necessary for applying the sytles to list presentations.
     
     After all styles have been applied, `fixAttributes(in:)` is called to cleanup the attributes in the strings.
     
     - parameter string: The string on which the style is applied.
     */
    open func apply(to string: NSMutableAttributedString) -> Void {
        string.enumerateAttribute(.presentationIntentAttributeName, in: NSRange(location: 0, length: string.length)) { value, range, stop in
            if let value = value as? PresentationIntent {
                var textRange = range
                apply(to: string, range: &textRange, intent: value)
            }
        }
        string.removeAttribute(.presentationIntentAttributeName, range: string.allRange)
        string.fixAttributes(in: string.allRange)
    }
    
    open func apply(to string: NSMutableAttributedString,
                    range: inout NSRange,
                    intent: PresentationIntent) -> Void {
        //print("\(range): \(value)")
        let components = intent.components

        if components.listType != nil {
            self.apply(to: string, range: &range, listIntent: intent)
        } else if components.isHorizontalRule {
            self.apply(to: string, range: &range, thematicBreakIntent: intent)
        } else {
            if currentList != nil {
                // We can't use the normal "if let" or "if var" pattern here, because we have to modify the original.
                currentList!.end = range.upperBound
                completeList(on: string)
            }
            for component in intent.components {
                self.apply(to: string, range: &range, kind: component.kind)
            }
        }
    }

    /**
     This is the basic application of a style onto the string. I mostly just looks up the `AJRMarkdownStyle` object for the given intent. Likewise, if the style as `insertNewLineAfter` set to `true`, then a newline is inserted at the end of the range.
     */
    open func apply(to string: NSMutableAttributedString,
                    range: inout NSRange,
                    kind: PresentationIntent.Kind) {
        if let style = styles[kind] {
            string.removeAttribute(.presentationIntentAttributeName, range: range)
            if style.insertNewlineAfter {
                string.insert(NSAttributedString(string: "\n"), at: range.upperBound)
                range.length += 1
            }
            string.addAttributes(style.attributes, range: range)
        } else {
            AJRLog.warning("No style for \(kind): \(string[range].string)")
        }
    }

    // MARK: - Lists
    
    open func apply(to string: NSMutableAttributedString,
                    range: inout NSRange,
                    listIntent: PresentationIntent) {
        if currentList == nil {
            var listStyle : AJRMarkdownStyle? = nil
            if listIntent.components.isOrderedList {
                listStyle = styles[.orderedList]
            } else if listIntent.components.isUnorderedList {
                listStyle = styles[.unorderedList]
            }
            if let listStyle {
                currentList = ListTracker(style: listStyle)
                currentList!.start = range.lowerBound
            } else {
                AJRLog.warning("No style for \(listIntent)")
            }
        }

        string.insert(NSAttributedString(string: "\n"), at: range.upperBound)
        range.length += 1

        if let prefix = prefix(for: listIntent) {
            let attributes = string.attributes(at: range.lowerBound, effectiveRange: nil)
            string.insert(NSAttributedString(string: prefix, attributes: attributes), at: range.lowerBound)
            range.length += prefix.count
        }

        if currentList != nil {
            let style = currentList!.style
            if currentList!.lastLevel != listIntent.indentationLevel {
                currentList!.lastLevel = listIntent.indentationLevel
                currentList!.lastStyle = copy(listStyle: style, for: listIntent)
            }
            string.addAttributes(currentList!.lastStyle!.attributes, range: range)
        }

        // Track where the last item in the list resides within the string.
        currentList?.lastItemRange = range
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
            return "\t\(marker)\t"
        }
        return nil
    }

    open func copy(listStyle: AJRMarkdownStyle, for intent: PresentationIntent) -> AJRMarkdownStyle {
        let new = listStyle.copyStyle()
        var tabStops = new.paragraphStyle.tabStops ?? []

        if tabStops.count < intent.indentationLevel - 1 {
            for i in 1 ... intent.indentationLevel - 1 {
                tabStops.append(NSTextTab(textAlignment: .left, location: CGFloat(i + intent.indentationLevel) * 0.25))
            }
        } else {
            tabStops.removeFirst(intent.indentationLevel - 1)
            while tabStops.count < intent.indentationLevel + 1 {
                if let last = tabStops.last {
                    tabStops.append(NSTextTab(textAlignment: .left, location: last.location + 0.25))
                }
            }
        }
        new.paragraphStyle.tabStops = tabStops

        var textLists = [NSTextList]()
        for i in 1 ... intent.indentationLevel {
            if intent.components.isOrderedList {
                textLists.append(NSTextList(markerFormat: .decimal, options: 0))
            } else if intent.components.isUnorderedList {
                textLists.append(NSTextList(markerFormat: unorderedListMarker(forLevel: i), options: 0))
            }
        }
        new.paragraphStyle.textLists = textLists

        let stop = tabStops[1]
        new.paragraphStyle.headIndent = stop.location

        return new
    }

    open func completeList(on string: NSMutableAttributedString) -> Void {
//        if let currentList {
//            let style = currentList.style.copyStyle()
//            let lastItemStyle = style.copyStyle()
//            let range = NSRange(location: currentList.start, length: currentList.end - currentList.start)

//            // Modify the style, as needed
//            style.paragraphStyle.paragraphSpacing = style.paragraphStyle.lineSpacing
//            style.paragraphStyle.textLists = currentList.textLists
//            lastItemStyle.paragraphStyle.textLists = currentList.textLists

//            string.removeAttribute(.presentationIntentAttributeName, range: range)
//            string.addAttributes(style.attributes, range: range)
//
//            // Quick check...
//            if let lastRange = currentList.lastItemRange {
//                string.addAttribute(.paragraphStyle, value: lastItemStyle.paragraphStyle, range: lastRange)
//            }

            self.currentList = nil
//        }
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
    
    // MARK: - Thematic Breaks
    
    open func apply(to string: NSMutableAttributedString,
                    range: inout NSRange,
                    thematicBreakIntent: PresentationIntent) {
        if let style = style(for: .thematicBreak) {
            let attachmentString = NSMutableAttributedString(attachment: style.createHorizontalRuleAttachment())
            attachmentString.append(NSAttributedString(string: "\n"))
            attachmentString.addAttributes(style.attributes, range: attachmentString.allRange)
            let oldLength = range.length
            let newLength = attachmentString.length
            
            string.replaceCharacters(in: range, with: attachmentString)
            
            range.length += (newLength - oldLength)
        } else {
            AJRLog.warning("No style defined for thematicBreak.")
        }
    }
    
    // MARK: - Managing Styles
    
    open func addStyle(_ style: AJRMarkdownStyle, for intent: PresentationIntent.Kind) -> Void {
        styles[intent] = style
    }
    
    open func removeStyle(for intent: PresentationIntent.Kind) -> Void {
        styles.removeValue(forKey: intent)
    }
    
    open func style(for intent: PresentationIntent.Kind) -> AJRMarkdownStyle? {
        return styles[intent]
    }
    
    open subscript(_ intent: PresentationIntent.Kind) -> AJRMarkdownStyle? {
        return styles[intent]
    }

}
