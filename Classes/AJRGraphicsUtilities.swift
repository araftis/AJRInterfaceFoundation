//
//  AJRGraphicsUtilities.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 9/30/21.
//  Copyright © 2021 Alex Raftis. All rights reserved.
//

import Foundation

public func drawWithSavedGraphicsState(_ block: () -> Void) -> Void {
    AJRGetCurrentContext()?.drawWithSavedGraphicsState(block)
}
