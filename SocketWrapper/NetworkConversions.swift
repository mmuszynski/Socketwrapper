//
//  NetworkConversions.swift
//  SocketWrapper
//
//  Created by Mike Muszynski on 7/31/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation

extension Data {
    mutating func encode(_ f: Float) {
        var f = f
        let newData = Data(bytes: &f, count: MemoryLayout<Float>.stride).reversed()
        self.append(contentsOf: newData)
    }
    
    mutating func encode(_ str: String) {
        guard let newData = str.data(using: .utf8) else {
            return
        }
        self.append(contentsOf: newData)
    }
}
