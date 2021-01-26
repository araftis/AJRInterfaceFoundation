
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif
#if os(OSX)
import AppKit
#endif

@objcMembers
open class AJRXView : AJRView {
    
    private var attributes : [NSAttributedString.Key:Any] = [
        .font: AJRFont.systemFont(ofSize: NSFont.systemFontSize(for: .mini)),
        .foregroundColor: AJRColor.black,
        ]
    @IBInspectable public var clear : Bool = false { didSet { needsDisplay = true } }
    @IBInspectable public var showFrame : Bool = false { didSet { needsDisplay = true } }
    @IBInspectable public var color: AJRColor = AJRColor.black { didSet { needsDisplay = true } }
    @IBInspectable public var backgroundColor: AJRColor = AJRColor.controlColor { didSet { needsDisplay = true } }

    override public init(frame: NSRect) {
        color = AJRColor.black
        backgroundColor = AJRColor.controlColor
        super.init(frame: frame)
    }
    
    override open func draw(_ dirtyRect: NSRect) {
        let bounds = self.bounds
        
        if !clear {
            backgroundColor.set()
            bounds.fill()
        }
    
        color.set()
        
        let path = AJRBezierPath()
        path.appendCrossedRect(bounds)
        path.stroke()

        if showFrame {
            (NSStringFromRect(bounds) as NSString).draw(at: NSPoint(x: 5, y: 5), withAttributes: attributes)
        }
    }
    
    override open var isOpaque: Bool {
        return !clear
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        clear = coder["clear"] ?? false
        showFrame = coder["showFrame"] ?? false
        color = coder["color"] ?? AJRColor.black
        backgroundColor = coder["backgroundColor"] ?? AJRColor.controlColor
    }
    
    override open func encode(with coder: NSCoder) {
        super.encode(with: coder)
        
        coder.encode(clear, forKey: "clear")
        coder.encode(showFrame, forKey: "showFrame")
        coder.encode(color, forKey: "color")
        coder.encode(backgroundColor, forKey: "backgroundColor")
    }
    
    override open var firstBaselineOffsetFromTop : CGFloat {
        return 10.0
    }
    
}

@objcMembers
open class AJRFlippedXView : AJRXView {
    
    open override var isFlipped: Bool {
        return true
    }
    
}
