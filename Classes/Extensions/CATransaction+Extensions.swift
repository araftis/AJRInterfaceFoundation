/*
 CATransaction+Extensions.swift
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

import Foundation

@objc
public extension CATransaction {

    class func ajr_preservePropertyStateDuring(_ block: () -> Void) {
        // Instead of getting each value locally, another implementation option would have been to have a method +allTransactionPropertyKeys, and then to loop over those and call +valueForKey: and stick each value in a dictionary, and then go through the dictionary after the block was called and call +setValue:forKey:. While this might have been cleaner, because this has the potential to be a hot path, I didn't want to incur a mutable dictionary cost for something that would be more straight-forward.
        let timingFunction = CATransaction.animationTimingFunction()
        let animationDuration = CATransaction.animationDuration()
        let completionBlock = CATransaction.completionBlock()
        let disableActions = CATransaction.disableActions()

        block()

        CATransaction.setAnimationTimingFunction(timingFunction)
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock(completionBlock)
        CATransaction.setDisableActions(disableActions)
    }

    class func executeBlockWithoutAnimations(_ block: () -> Void) -> Void {
        CATransaction.begin()
        //CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        CATransaction.setAnimationDuration(0.0001)
        block()
        CATransaction.commit()
    }
    
}
