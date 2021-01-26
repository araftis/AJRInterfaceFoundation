//
//  CGColorSpace+Extensions.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 7/7/19.
//  Copyright © 2019 Alex Raftis. All rights reserved.
//

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
