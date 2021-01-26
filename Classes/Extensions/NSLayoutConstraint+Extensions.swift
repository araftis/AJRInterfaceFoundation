//
//  NSLayoutConstraint+Extensions.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 4/10/19.
//  Copyright © 2019 Alex Raftis. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif
#if os(OSX)
import AppKit
#endif


extension NSLayoutConstraint.Attribute : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .left:
            return "left"
        case .right:
            return "right"
        case .top:
            return "top"
        case .bottom:
            return "bottom"
        case .leading:
            return "leading"
        case .trailing:
            return "trailing"
        case .width:
            return "width"
        case .height:
            return "height"
        case .centerX:
            return "centerX"
        case .centerY:
            return "centerY"
        case .lastBaseline:
            return "lastBaseline"
        case .firstBaseline:
            return "firstBaseline"
        case .notAnAttribute:
            return "notAnAttribute"
        default:
            return "unknown(\(rawValue))"
        }
    }
    
}
