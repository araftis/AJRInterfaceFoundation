
import Foundation

public extension CATransaction {

    class func executeBlockWithoutAnimations(_ block: () -> Void) -> Void {
        CATransaction.begin()
        //CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        CATransaction.setAnimationDuration(0.0001)
        block()
        CATransaction.commit()
    }
    
}
