//
//  AJRGraphicsUtilities.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 5/16/19.
//  Copyright © 2019 Alex Raftis. All rights reserved.
//

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
