//
//  NSAttributedStringAdditions.swift
//  MediaQuery
//
//  Created by A.J. Raftis on 11/9/16.
//  Copyright © 2016 A.J. Raftis. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(iOS) || os(tvOS)
	import UIKit
#endif
#if os(OSX)
	import AppKit
#endif

@available(OSX 10.11, *)
public extension NSAttributedString {
	
	static func attributedString(image:AJRImage, size:CGSize) -> NSAttributedString {
		let attachment = NSTextAttachment()
		attachment.image = image
		attachment.bounds = CGRect(origin:CGPoint.zero, size:size)
		return NSAttributedString(attachment:attachment)
	}
	
	#if os(iOS)
	public func draw(in rect:CGRect, context:CGContext) -> Void {
		// Flip the coordinate system
		context.saveGState()
		context.textMatrix = CGAffineTransform.identity
		context.translateBy(x:0.0, y:rect.size.height)
		context.scaleBy(x:1.0, y:-1.0)
		
		// Create a path to render text in
		let path = CGMutablePath()
		path.addRect(rect)
		
		// create the framesetter and render text
		let framesetter = CTFramesetterCreateWithAttributedString(self)
		let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.length), path, nil)
		
		CTFrameDraw(frame, context)
		context.restoreGState()
	}
	#endif
	
}
