//
//  NetworkRepresentable.swift
//  SocketWrapper
//
//  Created by Mike Muszynski on 8/1/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation

public protocol NetworkRepresentable {
    var networkRepresentation: Data { get }
    init?(withNetworkRepresentation: Data)
}

extension NetworkRepresentable {
    public init?(withNetworkRepresentation networkRepresentation: Data) {
        let data = Data(networkRepresentation.reversed())
        self = data.withUnsafeBytes { (ptr: UnsafePointer<Self>) -> Self in
            return ptr.pointee
        }
    }
    
    public var networkRepresentation: Data {
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
    public init?(withNetworkRepresentation networkRepresentation: Data) {
        guard let string = String(bytes: networkRepresentation, encoding: .utf8) else {
            return nil
        }
        self = string
    }
    
    public var networkRepresentation: Data {
        guard let data = self.data(using: .utf8) else {
            fatalError()
        }
        return data
    }
}
