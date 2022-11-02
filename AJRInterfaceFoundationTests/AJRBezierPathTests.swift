/*
 AJRBezierPathTests.swift
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

    func testSetDashExtensions() throws {
        let dash : [CGFloat] = [1.000000, 3.000000]
        let path = AJRBezierPath()
        var phase : CGFloat? = 0.0
        
        path.lineWidth = 2.0
        path.setLineDash(dash, phase: 1.0)

        let newDash = path.getLineDash(phase: &phase)
        XCTAssert(dash == newDash)
        XCTAssert(phase == 1.0)
    }

}
