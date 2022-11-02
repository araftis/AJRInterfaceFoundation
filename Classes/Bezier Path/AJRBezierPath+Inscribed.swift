/*
 AJRBezierPath+Inscribed.swift
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

public struct AJRIntersectionRect: Equatable {

    public struct Direction : OptionSet {

        public let rawValue: UInt

        public init(rawValue: UInt) { self.rawValue = rawValue }

        /// We began inside the range.
        public static let beganInside = Direction(rawValue: 1 << 0)
        /// We entered the rect from the bottom.
        public static let enterBottom = Direction(rawValue: 1 << 1)
        /// We entered the rect from the top.
        public static let enterTop    = Direction(rawValue: 1 << 2)
        /// We ended inside the range.
        public static let endedInside = Direction(rawValue: 1 << 3)
        /// We exited the rect from the bottom.
        public static let exitBottom  = Direction(rawValue: 1 << 4)
        /// We exited the rect from the top.
        public static let exitTop     = Direction(rawValue: 1 << 5)
        /// The entry point was to the left of the exit point.
        public static let enterLeft   = Direction(rawValue: 1 << 6)
        /// The entry point was to the right of the exit point.
        public static let enterRight  = Direction(rawValue: 1 << 7)

    }

    /**
     The rectangle represented the intersection with the path.
     */
    public var rect : CGRect
    /**
     The direction of the intersections. This is used to determine the direction of the underlying path.
     */
    public var direction : Direction = []

    public init(point: CGPoint, y: CGFloat, height: CGFloat) {
        rect = CGRect(x: point.x, y: y, width: 0, height: height)
    }

    /**
     Adds the point such that `rect` will contain point. Note that the way these rectangles work, it and its peers will all share the same `y` and `height`, so by calling this method, you're basically making sure the `x` and `width` of `rect` contains the `x` of `point`.

     - parameter point: The point to add. Only the `x` coordinate is really important, but it's convenient to pass in a point, since that's what the caller is likely to already have. Plus, someday, we'll likely want to make this work with up/down sweapings as well, in which case `y` will be important.
     */
    public mutating func add(point: CGPoint) {
        rect = rect.union(CGRect(origin: point, size: .zero))
    }

    /**
     Adds a direction to the `direction ` masks. The mask are values like enters from bottom, or exits from top. These are used to determine how the rectangle will determine the interrior of the bezier path.

     - parameter direction: The direction mask to add to `direction`.
     */
    public mutating func add(direction: Direction) {
        self.direction.insert(direction)
    }

    /**
     Returns true if the receiver fully contains other.

     - parameter other: The other rect to check for containment.

     - returns `true` if `other` is fully contained within the receiver, otherwise, `false`.
     */
    public func contains(_ other: AJRIntersectionRect) -> Bool {
        return other.rect.minX >= rect.minX && other.rect.maxX < rect.maxX
    }

    /**
     Returns `true` if the receiver and `other` overlap.

     - parameter other: The other rect to check for overlap.

     - returns `true` if the receiver and `other` overlap, `false` otherwise.
     */
    public func intersects(_ other: AJRIntersectionRect) -> Bool {
        return false
    }

}

/**
 Objective-C API.
 */
@objc public extension AJRBezierPath {

    @objc
    func inscribedRectangles(from baseline: CGFloat, height: CGFloat) -> [NSValue]? {
        if let rects : [CGRect] = inscribedRectangles(from: baseline, height: height) {
            var values = [NSValue]()
            for rect in rects {
                values.append(NSValue(rect: rect))
            }
            return values
        }
        return nil
    }

}

/**
 Swift only API.
 */
public extension AJRBezierPath {

    /**
     Takes in an array of intersection rects and modify them as appropriate.

     This mehod basically entails making sure that no rectangles overlap with any other rectangles. When rectangles overlap, the following happens:

     1. If the rectangles don't overlap any other rectangles, then the rectangles are left alone.
     2. If the one rectangle is fully contained by other rectangle, it's removed.
     3. If the rectangles overlap, but don't intersect, then we split the rectangles and selectively remove the rectangles that no longer matter.

     Note that this isn't necessarily super efficient, but since we should only ever be dealing with a relatively small number of rectangles, we're not going to worry too much about complex optimizations. We can revisit that decision if we find that we're spending a lot of time in this method.

     - parameter rects: The input rects to clean up.

     - returns An array of rectangles that should not overlap with each other.
     */
    func cleanUp(rects: [AJRIntersectionRect]) -> [AJRIntersectionRect] {
        let newRects = [AJRIntersectionRect](rects)

        for index1 in stride(from: 0, to: rects.count, by: 1) {
            let rect1 = rects[index1]
            for index2 in stride(from: index1, to: rects.count, by: 1) {
                let rect2 = rects[index2]

                if rect1.contains(rect2) {
                    //newRects.remove(element: rect2)
                } else if rect2.contains(rect1) {
                    //newRects.remove(element: rect1)
                }
            }
        }

        return newRects
    }

    func intersectingRectangles(from baseline: CGFloat, height: CGFloat) -> [AJRIntersectionRect]? {
        // bottom and top represent an infinite line along the baseline and top, and are used to determine rectangles that contain segments of our path.
        let top = AJRLine(start: CGPoint(x: -100000000, y: baseline + height), end: CGPoint(x: 100000000, y: baseline + height))
        let bottom = AJRLine(start: CGPoint(x: -100000000, y: baseline), end: CGPoint(x: 100000000, y: baseline))

        var intersectionRects = [AJRIntersectionRect]()
        var currentRect : AJRIntersectionRect? = nil

        let addPoint = { (_ point: CGPoint) -> Bool in
            if currentRect == nil {
                currentRect = AJRIntersectionRect(point: point, y: baseline, height: height)
                return true
            } else {
                currentRect?.add(point: point)
                return false
            }
        }

        let close = {
            if let currentRect = currentRect {
                // TODO: Extend the rect to make sure it starts on our baseline and is the same height as our range.
                intersectionRects.append(currentRect)
            }
            currentRect = nil
        }

        // This will track when we visit the first point. This is necessary because if we start within our range, we'll need to merge the first and last rectangle.
        enumerateFlattenedPath { line, isNewSubpath, stop in
            if (line.start.y < baseline && line.end.y < baseline)
                || (line.start.y > baseline + height && line.end.y > baseline + height) {
                // We definitely don't intersect. We do this check, because it saves us the math if we don't need to do it. However, if we have an intersection, we need to close it.
                close()
            } else {
                let startWithin = line.start.y >= baseline && line.start.y <= baseline + height
                let endWithin = line.end.y >= baseline && line.end.y <= baseline + height
                // First, see if the line starts within our range.
                if startWithin && endWithin {
                    if addPoint(line.start) && startWithin {
                        currentRect?.add(direction: .beganInside)
                    }
                    _ = addPoint(line.end)
                } else if (startWithin && !endWithin) {
                    // We track this, because we we're new, we're entering the range, so we obviously won't close, but if we're not new we're exiting, so we will close.
                    let isNew = addPoint(line.start) // Since we know start is within our range, add it.

                    if !isNew {
                        if line.start.y < line.end.y {
                            currentRect?.add(direction: .exitTop)
                        } else {
                            currentRect?.add(direction: .exitBottom)
                        }
                    }

                    // Now, since start was within our range, but end wasn't, we'll only have one intersection. Let's check to see if we cross the bottom (baseline). Saves us some math.
                    let intersection : CGPoint?
                    if line.end.y < baseline {
                        intersection = bottom.intersect(with: line)
                    } else {
                        intersection = top.intersect(with: line)
                    }
                    assert(intersection != nil, "We should have intersection with the top or bottom of our range, but we didn't. Something's probably wrong.")
                    _ = addPoint(intersection!)

                    if !isNew {
                        close()
                    }
                } else if endWithin {
                    // We track this, because if we're new, we're entering the range, so we obviously won't close, but if we're not new we're exiting, so we will close.
                    let isNew = addPoint(line.end) // We know end is within our range, so add it.

                    if isNew {
                        if line.start.y < line.end.y {
                            currentRect?.add(direction: .enterBottom)
                        } else {
                            currentRect?.add(direction: .enterTop)
                        }
                    }

                    // Now, since end was within our range, but start wasn't, we'll only have one intersection. Let's check to see if we cross the bottom (baseline). Saves us some math.
                    let intersection : CGPoint?
                    if line.start.y < baseline {
                        intersection = bottom.intersect(with: line)
                    } else {
                        intersection = top.intersect(with: line)
                    }
                    assert(intersection != nil, "We should have intersection with the top or bottom of our range, but we didn't. Something's probably wrong.")
                    _ = addPoint(intersection!)

                    if !isNew {
                        close()
                    }
                } else {
                    // We crossed our range, so we'll have two intersections.
                    let bottomIntersection = bottom.intersect(with: line)
                    let topIntersection = top.intersect(with: line)

                    // We have to close the current rect, if one exists. This can happen when we have multiple subpaths within the bezier path.
                    close()

                    // Now we have just add the two intersection points, but let's throw a warning if needed (shouldn't occur, but for debugging purposes...)
                    if let bottomIntersection = bottomIntersection,
                       let topIntersection = topIntersection {
                        _ = addPoint(topIntersection)
                        _ = addPoint(bottomIntersection)
                        if line.start.y < line.end.y {
                            currentRect?.add(direction: [.enterBottom, .exitTop])
                        } else {
                            currentRect?.add(direction: [.exitBottom, .enterTop])
                        }
                    } else {
                        AJRLog.warning("We supposedly cross our path, but we didn't have both a top and bottom intersection, which should be impossible.")
                    }

                    // And close, since we passed in and out.
                    close()
                }
            }
        }

        // We may have an open intersection, so close it.
        close()

        return intersectionRects.count == 0 ? nil : cleanUp(rects: intersectionRects)
    }

    // TODO: Currently this is wrong, but it will be made right by the time we finish.
    /**

     */
    func inscribedRectangles(from baseline: CGFloat, height: CGFloat) -> [CGRect]? {
        return nil
    }

}

