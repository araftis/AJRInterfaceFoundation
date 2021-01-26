//
//  AJRFont.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 2/8/19.
//  Copyright © 2019 A.J. Raftis. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)

import UIKit

public typealias AJRFont = UIFont

public let AJRFontWeightUltraLight   : CGFloat = UIFontWeightUltraLight
public let AJRFontWeightThin         : CGFloat = UIFontWeightThin
public let AJRFontWeightLight        : CGFloat = UIFontWeightLight
public let AJRFontWeightRegular      : CGFloat = UIFontWeightRegular
public let AJRFontWeightMedium       : CGFloat = UIFontWeightMedium
public let AJRFontWeightSemibold     : CGFloat = UIFontWeightSemibold
public let AJRFontWeightBold         : CGFloat = UIFontWeightBold
public let AJRFontWeightHeavy        : CGFloat = UIFontWeightHeavy
public let AJRFontWeightBlack        : CGFloat = UIFontWeightBlack

#endif

#if os(OSX)

import AppKit

public typealias AJRFont = NSFont

public let AJRFontWeightUltraLight   : CGFloat = -0.8
public let AJRFontWeightThin         : CGFloat = -0.6
public let AJRFontWeightLight        : CGFloat = -0.4
public let AJRFontWeightRegular      : CGFloat = 0.0
public let AJRFontWeightMedium       : CGFloat = 0.23
public let AJRFontWeightSemibold     : CGFloat = 0.3
public let AJRFontWeightBold         : CGFloat = 0.4
public let AJRFontWeightHeavy        : CGFloat = 0.56
public let AJRFontWeightBlack        : CGFloat = 0.62

#endif


public func AJRSystemFont(ofSize fontSize:CGFloat, weight:CGFloat) -> CTFont? {
    #if os(iOS) || os(tvOS) || os(watchOS)
    let font = UIFont.systemFont(ofSize:fontSize, weight:weight)
    return CTFontCreateWithName(font.fontName as CFString?, fontSize, nil)
    #else
    if #available(OSX 10.11, *) {
        return NSFont.systemFont(ofSize:fontSize, weight:NSFont.Weight(rawValue: weight))
    } else {
        return NSFont.systemFont(ofSize:fontSize)
    }
    #endif
}
