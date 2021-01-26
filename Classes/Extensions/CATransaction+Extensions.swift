//
//  CATransaction+Extensions.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 3/8/19.
//  Copyright © 2019 Alex Raftis. All rights reserved.
//

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
