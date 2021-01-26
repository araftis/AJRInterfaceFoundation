//
//  AJRImageUtilities.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 10/1/20.
//  Copyright © 2020 Alex Raftis. All rights reserved.
//

import CoreGraphics
import AppKit

private func test(width pixelsWide: CGFloat, height pixelsHigh: CGFloat, colorSpace colorSpaceIn: CGColorSpace?) -> Void {
    if let colorSpace = colorSpaceIn ?? CGColorSpace(name: CGColorSpace.sRGB as! CFString) {
        _ = CGContext(data:nil,
                  width: Int(pixelsWide),
                  height: Int(pixelsHigh),
                  bitsPerComponent:8,
                  bytesPerRow: Int(pixelsWide) * (colorSpace.numberOfComponents + 1),
                  space:colorSpace,
                  bitmapInfo:CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
    }
}
