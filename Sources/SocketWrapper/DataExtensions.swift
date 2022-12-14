//
//  DataExtensions.swift
//  SocketWrapper
//
//  Created by Mike Muszynski on 7/31/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation

public extension Data {
    func decode<T: NetworkRepresentable>(atOffset offset: inout Int) throws -> T {
        let value = try self.decode(T.self, atOffset: offset)
        offset += MemoryLayout.size(ofValue: value)
        return value
    }
    
    func decode<T: NetworkRepresentable>(atOffset offset: Int) throws -> T {
        return try self.decode(T.self, atOffset: offset)
    }
    
    func decode<T: NetworkRepresentable>(_: T.Type, atOffset offset: Int, withLength length: Int = MemoryLayout<T>.stride) throws -> T {
        let range = offset..<(offset + length)
        let subData = self[range]
        guard let value = T(withNetworkRepresentation: Data(subData)) else {
            fatalError("Couldn't decode \(T.self)")
        }
        return value
    }
    
    var hexEncodedString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
