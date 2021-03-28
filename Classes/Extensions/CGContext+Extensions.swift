
import Foundation
import CoreGraphics

public extension CGContext {
    
    func addRoundedRectToPath(_ rect: CGRect, cornerRadius: CGFloat) -> Void {
        AJRContextAddRoundedRectToPath(self, rect, cornerRadius)
    }
    
    func drawWithSavedGraphicsState(_ block: () -> Void) -> Void {
        self.saveGState()
        block()
        self.restoreGState()
    }
    
    func drawWithTransparencyLayer(_ block: () -> Void) -> Void {
        self.beginTransparencyLayer(auxiliaryInfo: nil)
        block()
        self.endTransparencyLayer()
    }
    
}
