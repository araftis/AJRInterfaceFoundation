
import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)

import UIKit

#endif

#if os(OSX)

import AppKit

public typealias AJRGradient = NSGradient

#endif
