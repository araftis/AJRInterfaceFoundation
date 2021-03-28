
#if os(OSX)
import AppKit
#else
import UIKit
#endif

@objcMembers
open class AJRTextLayer : CALayer {
    
    // MARK: - Defaults
    
    internal static var defaultFont : AJRFont  = {
        return NSFont.systemFont(ofSize: AJRFont.systemFontSize(for: .regular))
    }()
    
    internal static var defaultForegroundColor : CGColor = {
        return CGColor.black
    }()
    
    // MARK: - Properties
    
    internal func resetAttributedString(_ string: String) -> Void {
        attributedString = NSAttributedString(string: string, attributes: [.foregroundColor:NSColor(cgColor: foregroundColor)!, .font:font])
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    public var font : AJRFont { didSet { resetAttributedString(string) } }
    public var foregroundColor : CGColor { didSet { resetAttributedString(string) } }
    
    public var string : String {
        get {
            return attributedString.string
        }
        set {
            resetAttributedString(newValue)
        }
    }

    public var attributedString : NSAttributedString {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: - Creation
    
    public override init() {
        self.attributedString = NSAttributedString()
        self.font = AJRTextLayer.defaultFont
        self.foregroundColor = AJRTextLayer.defaultForegroundColor
        super.init()
    }
    
    public override init(layer: Any) {
        let other = layer as! AJRTextLayer
        self.font = other.font
        self.foregroundColor = other.foregroundColor
        self.attributedString = other.attributedString
        super.init(layer: layer)
    }
    
    // MARK: - NSCoding
    
    required public init?(coder: NSCoder) {
        self.attributedString = coder.decodeObject(forKey: "attributedString") as? NSAttributedString ?? NSAttributedString()
        self.font = coder.decodeObject(of: NSFont.self, forKey: "font") ?? AJRTextLayer.defaultFont
        self.foregroundColor = AJRTextLayer.defaultForegroundColor
        super.init(coder: coder)
    }
    
    override open func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(attributedString, forKey: "attributedString")
        coder.encode(font, forKey: "font")
    }
    
    // MARK: - Layout
    
    open func textRect(for bounds: CGRect) -> CGRect {
        return bounds
    }
    
    // MARK: - CALayer
    
    open override func draw(in context: CGContext) {
        #if os(OSX)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        self.attributedString.draw(in: textRect(for: bounds))
        NSGraphicsContext.restoreGraphicsState()
        #else
        UIGraphicsPushContext(context)
        self.attributedString.draw(in: self.bounds)
        UIGraphicsPopContext()
        #endif
    }
    
    open override func preferredFrameSize() -> CGSize {
        return attributedString.size()
    }

}
