/*
AJRFont.swift
AJRInterfaceFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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

#if os(iOS) || os(tvOS) || os(watchOS)

import UIKit

public typealias AJRFont = UIFont

public let AJRFontWeightUltraLight   : CGFloat = UIFontWeightUltraLight
public let AJRFontWeightThin         : CGFloat = UIFontWeightThin
public let AJRFontWeightLight        : CGFloat = UIFontWeightLight
public let AJRFontWeightRegular      : CGFloat = UIFontWeightRegular
public let AJRFontWeightMedium       : CGFloat = UIFontWeightMedium
public let AJRFontWeightSemibold     : CGFloat = UIFontWeightSemibold
public let AJRFontWeightBold         : CGFloat = UIFontWeightBold
public let AJRFontWeightHeavy        : CGFloat = UIFontWeightHeavy
public let AJRFontWeightBlack        : CGFloat = UIFontWeightBlack

#endif

#if os(OSX)

import AppKit

public typealias AJRFont = NSFont

public let AJRFontWeightUltraLight   : CGFloat = -0.8
public let AJRFontWeightThin         : CGFloat = -0.6
public let AJRFontWeightLight        : CGFloat = -0.4
public let AJRFontWeightRegular      : CGFloat = 0.0
public let AJRFontWeightMedium       : CGFloat = 0.23
public let AJRFontWeightSemibold     : CGFloat = 0.3
public let AJRFontWeightBold         : CGFloat = 0.4
public let AJRFontWeightHeavy        : CGFloat = 0.56
public let AJRFontWeightBlack        : CGFloat = 0.62

#endif


public func AJRSystemFont(ofSize fontSize:CGFloat, weight:CGFloat) -> CTFont? {
    #if os(iOS) || os(tvOS) || os(watchOS)
    let font = UIFont.systemFont(ofSize:fontSize, weight:weight)
    return CTFontCreateWithName(font.fontName as CFString?, fontSize, nil)
    #else
    if #available(OSX 10.11, *) {
        return NSFont.systemFont(ofSize:fontSize, weight:NSFont.Weight(rawValue: weight))
    } else {
        return NSFont.systemFont(ofSize:fontSize)
    }
    #endif
}
