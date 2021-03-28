
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
    class func image(size: CGSize, scales:[CGFloat], flipped: Bool, colorSpace: CGColorSpace, commands:@escaping (_ scale: CGFloat) -> Void) -> AJRImage? {
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
