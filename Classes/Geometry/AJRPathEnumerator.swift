//
//  AJRPathEnumerator.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 3/24/23.
//  Copyright © 2023 Alex Raftis. All rights reserved.
//

import Foundation

public extension AJRPathEnumerator {

    func nextElement(withPoints points: inout [CGPoint]) -> AJRBezierPathElement? {
        assert(points.count >= 3, "points must contain at least three points")
        if let next = _nextElement(withPoints: &points) {
            return next.pointee
        }
        return nil
    }

}
