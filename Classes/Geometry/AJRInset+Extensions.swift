//
//  AJRInset+Extensions.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 6/14/19.
//  Copyright © 2019 Alex Raftis. All rights reserved.
//

import Foundation

extension AJRInset : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> AJRInset? {
        if let rawInset = userDefaults.string(forKey: key) {
            return AJRInsetFromString(rawInset)
        }
        return nil
    }
    
    public static func setUserDefault(_ value: AJRInset?, forKey key: String, into userDefaults: UserDefaults) {
        if let value = value {
            userDefaults.set(AJRStringFromInset(value), forKey: key)
        } else {
            userDefaults.set(nil, forKey: key)
        }
    }
    
    public static var zero : AJRInset {
        return AJRInsetZero
    }
    
}
