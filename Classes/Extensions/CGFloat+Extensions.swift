//
//  CGFloat+Extensions.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 3/28/23.
//  Copyright © 2023 Alex Raftis. All rights reserved.
//

import Foundation

public extension CGFloat {

    init?(_ string: String) {
        if let value = Double(string) {
            self.init(value)
        } else {
            return nil
        }
    }

}
