//
//  AJRBezierPathTests.swift
//  AJRInterfaceFoundationTests
//
//  Created by AJ Raftis on 12/23/20.
//  Copyright © 2020 Alex Raftis. All rights reserved.
//

import XCTest
import AJRFoundation
@testable import AJRInterfaceFoundation

class AJRBezierPathTests: XCTestCase {

    func testCoding() throws {
        let path = AJRBezierPath()

        path.move(to: CGPoint(x: -10, y: -10))
        path.line(to: CGPoint(x: -10, y: 10))
        path.line(to: CGPoint(x: 10, y: 10))
        path.line(to: CGPoint(x: 10, y: -10))
        path.close()

        let data = AJRXMLArchiver.archivedData(withRootObject: path)
        XCTAssert(data != nil)
        if let data = data {
            if let string = String(data: data, encoding: .utf8) {
                print(string)
            }
            let newPath = try? AJRXMLUnarchiver.unarchivedObject(with: data)
            XCTAssert(newPath != nil)
            XCTAssert(path.isEqual(to: newPath))
        }
    }

}
