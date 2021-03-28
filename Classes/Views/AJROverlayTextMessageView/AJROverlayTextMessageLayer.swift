
import Cocoa

@objcMembers
open class AJROverlayTextMessageLayer: AJRTextLayer {
    
    // MARK: - Properties
    
    open var _insets : AJREdgeInsets?
    open var insets : AJREdgeInsets! {
        get {
            if let insets = _insets {
                return insets
            }
            let pointSize = font.pointSize
            return AJREdgeInsets(top: pointSize / 2.0, left: pointSize, bottom: pointSize / 2.0, right: pointSize)
        }
        set {
            _insets = newValue
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    // MARK: - Creation
    
    internal func commonInit() -> Void {
        backgroundColor = AJRColor(deviceWhite: 1.0, alpha: 0.33).cgColor
        cornerRadius = frame.size.height / 2.0
    }
    
    public init(message: String ) {
        super.init()
        
        self.string = message
        commonInit()
    }
    
    public override init() {
        super.init()
        commonInit()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Layout
    
    open override func textRect(for bounds: CGRect) -> CGRect {
        return bounds.inset(with: insets)
    }
    
    // MARK: - CALayer
    
    open override func preferredFrameSize() -> CGSize {
        var size = super.preferredFrameSize()
        size.width += (insets.left + insets.right)
        size.height += (insets.top + insets.bottom)
        return size
    }
    
    
    open override func layoutSublayers() {
        super.layoutSublayers()
        cornerRadius = frame.size.height / 2.0
    }
    
}
