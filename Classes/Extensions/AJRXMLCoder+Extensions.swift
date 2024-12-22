/*
 AJRXMLCoder+Extensions.m
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

import AJRFoundation

@objc
public extension AJRXMLCoder {

    @objc(encodePoint:forKey:)
    func encode(point: CGPoint, forKey key: String) {
    }

    @objc(encodeSize:forKey:)
    func encode(size: CGSize, forKey key: String) {
    }

    @objc(encodeRect:forKey:)
    func encode(rect: CGRect, forKey key: String) {
    }

    func decodePoint(forKey key: String, setter: @escaping (_ point: CGPoint) -> Void) {
    }

    func decodeSize(forKey key: String, setter: @escaping (_ point: CGSize) -> Void) {
    }

    func decodeRect(forKey key: String, setter: @escaping (_ point: CGRect) -> Void) {
    }

}

@objc
public extension AJRXMLArchiver {

    @objc(encodePoint:forKey:)
    override func encode(point: CGPoint, forKey key: String) {
        encodeGroup(forKey: key) {
            self.encode(point.x, forKey: "x")
            self.encode(point.y, forKey: "y")
        }
    }

    @objc(encodeSize:forKey:)
    override func encode(size: CGSize, forKey key: String) {
        encodeGroup(forKey: key) {
            self.encode(size.width, forKey: "width")
            self.encode(size.height, forKey: "height")
        }
    }

    @objc(encodeRect:forKey:)
    override func encode(rect: CGRect, forKey key: String) {
        encodeGroup(forKey: key) {
            self.encode(rect.origin.x, forKey: "x")
            self.encode(rect.origin.y, forKey: "y")
            self.encode(rect.size.width, forKey: "width")
            self.encode(rect.size.height, forKey: "height")
        }
    }

}


@objc
public extension AJRXMLUnarchiver {

    override func decodePoint(forKey key: String, setter: @escaping (_ point: CGPoint) -> Void) {
        var point = CGPoint.zero
        decodeGroup(forKey: key) {
            self.decodeDouble(forKey: "x") { value in
                point.x = value
            }
            self.decodeDouble(forKey: "y") { value in
                point.y = value
            }
        } setter: {
            setter(point)
        }
    }

    override func decodeSize(forKey key: String, setter: @escaping (_ size: CGSize) -> Void) {
        var size = CGSize.zero
        decodeGroup(forKey: key) {
            self.decodeDouble(forKey: "width") { value in
                size.width = value
            }
            self.decodeDouble(forKey: "height") { value in
                size.height = value
            }
        } setter: {
            setter(size)
        }
    }

    override func decodeRect(forKey key: String, setter: @escaping (_ size: CGRect) -> Void) {
        var rect = CGRect.zero
        decodeGroup(forKey: key) {
            self.decodeDouble(forKey: "x") { value in
                rect.origin.x = value
            }
            self.decodeDouble(forKey: "y") { value in
                rect.origin.y = value
            }
            self.decodeDouble(forKey: "width") { value in
                rect.size.width = value
            }
            self.decodeDouble(forKey: "height") { value in
                rect.size.height = value
            }
        } setter: {
            setter(rect)
        }
    }

}

