/*
 NSAttributedStringAdditions.swift
 AJRInterfaceFoundation

 Copyright © 2022, AJ Raftis and AJRInterfaceFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterfaceFoundation nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
