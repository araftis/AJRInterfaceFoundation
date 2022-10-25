/*
AJRImage.swift
AJRInterfaceFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

#if os(iOS) || os(tvOS) || os(watchOS)

import UIKit

public typealias AJRImage = UIImage

public extension UIImage {
    
    public class func image(named name:String, in inputBundle:Bundle?) -> AJRImage? {
        let bundle : Bundle = inputBundle == nil ? Bundle.main : inputBundle!
        #if os(iOS) || os(tvOS)
        return UIImage(named:name, in:bundle, compatibleWith:nil)
        #else
        // Watch has more primitive APIs
        return UIImage(named:name)
        #endif
    }
    
    public class func image(named name:String, forClass objectClass:AnyClass) -> AJRImage? {
        return image(named:name, in:Bundle(for:objectClass))
    }
    
    public class func image(named name:String, forObject object:AnyObject) -> AJRImage? {
        return image(named:name, forClass:type(of:object))
    }
    
    public class func image(contentsOfURL URL : Foundation.URL) -> AJRImage? {
        var image : AJRImage?
        if let data = try? Data(contentsOf:URL) {
            image = AJRImage(data:data)
        }
        return image
    }
    
}

#endif

#if os(OSX)

import AppKit

public typealias AJRImage = NSImage

@available(OSX 10.12, *)
public extension NSImage {
    
    class func image(named name:String, in bundle:Bundle?) -> AJRImage? {
        let bundle : Bundle = bundle == nil ? Bundle.main : bundle!
        return bundle.image(forResource:name)
    }
    
    class func image(named name:String, forClass objectClass:AnyClass) -> AJRImage? {
        return image(named:name, in:Bundle(for:objectClass))
    }
    
    class func image(named name:String, forObject object:AnyObject) -> AJRImage? {
        return image(named:name, forClass:type(of:object))
    }
    
    class func image(contentsOfURL url:Foundation.URL) -> AJRImage? {
        return AJRImage(contentsOf:url)
    }
    
    @objc(imageWithSize:scales:flipped:colorSpace:commands:)
    class func image(size: CGSize, scales:[CGFloat], flipped: Bool, colorSpace: CGColorSpace?, commands:@escaping (_ scale: CGFloat) -> Void) -> AJRImage? {
        var images = [NSBitmapImageRep]()
        
        for scale in scales {
            let subimage = AJRCreateImage(size, scale, flipped, colorSpace, { (context) in
                let savedContext = NSGraphicsContext.current
                let nsContext = NSGraphicsContext(cgContext: context, flipped: flipped)
                NSGraphicsContext.current = nsContext
                commands(scale)
                NSGraphicsContext.current = savedContext
            })
            images.append(NSBitmapImageRep(cgImage: subimage))
        }
        
        var finalImage : NSImage? = nil
        if images.count > 0 {
            finalImage = NSImage(size: size)
            finalImage?.addRepresentations(images)
        }
        
        return finalImage
    }
    
}

#endif
