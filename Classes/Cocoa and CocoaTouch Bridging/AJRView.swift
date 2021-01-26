//
//  AJRView.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 2/8/19.
//  Copyright © 2019 A.J. Raftis. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)

import UIKit

public typealias AJRView = UIView

#endif

#if os(OSX)

import AppKit

public typealias AJRView = NSView

#endif
