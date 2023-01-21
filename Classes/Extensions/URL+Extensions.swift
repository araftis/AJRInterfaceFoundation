//
//  URL+Extensions.swift
//  AJRInterfaceFoundation
//
//  Created by AJ Raftis on 12/22/22.
//  Copyright © 2022 Alex Raftis. All rights reserved.
//

import AJRFoundation

public extension URL {

    var isImageURL : Bool {
        if let type = self.pathType?.identifier {
            return AJRImage.imageTypes.contains(type)
        }
        return false
    }

    init?(imageString string: String) {
        if let url = URL(string: string) {
            if url.isImageURL {
                self.init(string: string)
                return
            }
        }
        return nil
    }

}
