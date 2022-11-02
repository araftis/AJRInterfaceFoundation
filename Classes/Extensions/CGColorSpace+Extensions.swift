/*
 CGColorSpace+Extensions.swift
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

public extension CGColorSpace {
    
    private static var _deviceGray : CGColorSpace? = nil
    class var deviceGray : CGColorSpace {
        if _deviceGray == nil {
            _deviceGray = CGColorSpaceCreateDeviceGray()
        }
        return _deviceGray!
    }
    
    private static var _deviceCMYK : CGColorSpace? = nil
    class var deviceCMYK : CGColorSpace {
        if _deviceCMYK == nil {
            _deviceCMYK = CGColorSpaceCreateDeviceCMYK()
        }
        return _deviceCMYK!
    }
    
    private static var _deviceRGB : CGColorSpace? = nil
    class var deviceRGB : CGColorSpace {
        if _deviceRGB == nil {
            _deviceRGB = CGColorSpaceCreateDeviceRGB()
        }
        return _deviceRGB!
    }
    
    private static var _sRGB : CGColorSpace? = nil
    class var sRGB : CGColorSpace {
        if _sRGB == nil {
            _sRGB = CGColorSpace(name: CGColorSpace.extendedSRGB)
        }
        return _sRGB!
    }
    
    private static var _gray : CGColorSpace? = nil
    class var gray : CGColorSpace {
        if _gray == nil {
            _gray = CGColorSpace(name: CGColorSpace.extendedGray)
        }
        return _gray!
    }
    
    private static var _p3 : CGColorSpace? = nil
    class var p3 : CGColorSpace {
        if _p3 == nil {
            _p3 = CGColorSpace(name: CGColorSpace.dcip3)
        }
        return _p3!
    }
    
}
