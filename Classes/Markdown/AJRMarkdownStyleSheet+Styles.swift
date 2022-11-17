//
//  AJRMarkdownStyleSheet+Styles.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 11/17/22.
//  Copyright © 2022 Alex Raftis. All rights reserved.
//

import Foundation

public extension AJRMarkdownStyleSheet {
    
    /**
     A basic style sheet for applying to markdown strings. This is pretty basic, but should make a fairly nice presentation.
     */
    static var basic : AJRMarkdownStyleSheet = {
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
        styleSheet.addStyle(style, for: .paragraph)
        
        style = AJRMarkdownStyle()
        style.font = AJRFont.boldSystemFont(ofSize: 24.0)
        style.paragraphStyle.paragraphSpacing = 18.0
        style.paragraphStyle.paragraphSpacingBefore = 9.0
        style.paragraphStyle.headerLevel = 1
        styleSheet.addStyle(style, for: .header(level: 1))
        
        style = AJRMarkdownStyle()
        style.font = AJRFont.boldSystemFont(ofSize: 18.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.paragraphSpacingBefore = 9.0
        style.paragraphStyle.headerLevel = 2
        styleSheet.addStyle(style, for: .header(level: 2))

        style = AJRMarkdownStyle()
        style.font = AJRFont.boldSystemFont(ofSize: 15.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.paragraphSpacingBefore = 9.0
        style.paragraphStyle.headerLevel = 3
        styleSheet.addStyle(style, for: .header(level: 3))

        style = AJRMarkdownStyle()
        style.font = AJRFont.boldSystemFont(ofSize: 13.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.paragraphSpacingBefore = 9.0
        style.paragraphStyle.headerLevel = 4
        styleSheet.addStyle(style, for: .header(level: 4))

        style = AJRMarkdownStyle()
        style.font = AJRFont.systemFont(ofSize: 13.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.tabStops = tabStops
        styleSheet.addStyle(style, for: .unorderedList)
        
        style = AJRMarkdownStyle()
        style.font = AJRFont.systemFont(ofSize: 13.0)
        style.paragraphStyle.paragraphSpacing = 9.0
        style.paragraphStyle.tabStops = tabStops
        styleSheet.addStyle(style, for: .orderedList)

        return styleSheet
    }()
    
}
