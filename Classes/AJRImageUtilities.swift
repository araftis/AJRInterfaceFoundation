/*
 AJRImageUtilities.swift
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

import CoreGraphics
import AppKit
import UniformTypeIdentifiers

// MARK: - Generating Image Data

public func AJRDataFromCGImage(_ image: CGImage, _ format: UTType, _ options: [CFString:Any]? = nil) -> Data? {
    var result : NSMutableData? = NSMutableData()
    if let destination = CGImageDestinationCreateWithData(result!, format.identifier as CFString, 1, nil) {
        let options = options == nil ? nil : options! as CFDictionary
        CGImageDestinationAddImage(destination, image, options)
        if (!CGImageDestinationFinalize(destination)) {
            result = nil
        }
    }
    return result as Data?
}

@_cdecl("AJRPNGDataFromCGImage")
public func AJRPNGDataFromCGImage(_ image: CGImage, _ interlace: Bool) -> Data? {
    return AJRDataFromCGImage(image, UTType.png, [kCGImagePropertyPNGInterlaceType: interlace])
}

@_cdecl("AJRJPEGDataFromCGImage")
public func AJRJPEGDataFromCGImage(_ image: CGImage, compression: CGFloat) -> Data? {
    return AJRDataFromCGImage(image, UTType.jpeg, [kCGImageDestinationLossyCompressionQuality: compression])
}

@_cdecl("AJRGIFDataFromCGImage")
public func AJRGIFDataFromCGImage(_ image: CGImage, ditherTransparency: Bool) -> Data? {
    return AJRDataFromCGImage(image, UTType.gif, [kCGImagePropertyHasAlpha: ditherTransparency])
}

@_cdecl("AJRBMPDataFromCGImage")
public func AJRBMPDataFromCGImage(_ image: CGImage) -> Data? {
    return AJRDataFromCGImage(image, UTType.bmp)
}

// MARK: - Creating Images

public func AJRCreateInverseMask(_ input: CGImage) -> CGImage {
    let rect = CGRect(origin: .zero, size: input.size)
    return AJRCreateImage(rect.size,
                          1.0,
                          false,
                          nil) { context in
        context.setFillColor(.white)
        context.fill(rect)
        context.clip(to: rect, mask: input)
        context.clear(rect);
    }
}

// MARK: - Testing

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
