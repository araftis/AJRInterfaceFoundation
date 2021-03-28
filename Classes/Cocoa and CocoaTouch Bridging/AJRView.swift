
import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)

import UIKit

public typealias AJRView = UIView

#endif

#if os(OSX)

import AppKit

public typealias AJRView = NSView

#endif
