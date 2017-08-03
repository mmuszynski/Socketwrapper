//
//  NetworkRepresentable.swift
//  SocketWrapper
//
//  Created by Mike Muszynski on 8/1/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation

protocol NetworkRepresentable {
    var networkRepresentation: Data { get } 
    
    init?(fromNetworkRepresentation: Data)
}

extension NetworkRepresentable {
    init?(fromNetworkRepresentation networkRepresentation: Data) {
        let data = Data(networkRepresentation.reversed())
        self = data.withUnsafeBytes { (ptr: UnsafePointer<Self>) -> Self in
            return ptr.pointee
        }
    }
    
    var networkRepresentation: Data {
        var f = self
        let newData = Data(bytes: &f, count: MemoryLayout<Self>.stride).reversed()
        return Data(newData)
    }
}

extension Int8: NetworkRepresentable {}
extension Int16: NetworkRepresentable {}
extension Int32: NetworkRepresentable {}
extension Int: NetworkRepresentable {}
extension UInt8: NetworkRepresentable {}
extension UInt16: NetworkRepresentable {}
extension UInt32: NetworkRepresentable {}
extension UInt: NetworkRepresentable {}
extension Float: NetworkRepresentable {}
extension Double: NetworkRepresentable {}
extension CGFloat: NetworkRepresentable {}

extension String: NetworkRepresentable {
    init?(fromNetworkRepresentation networkRepresentation: Data) {
        guard let string = String(bytes: networkRepresentation, encoding: .utf8) else {
            return nil
        }
        self = string
    }
    
    var networkRepresentation: Data {
        guard let data = self.data(using: .utf8) else {
            fatalError()
        }
        return data
    }
}
