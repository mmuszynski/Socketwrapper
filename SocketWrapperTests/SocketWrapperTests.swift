//
//  SocketWrapperTests.swift
//  SocketWrapperTests
//
//  Created by Mike Muszynski on 7/31/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import XCTest
@testable import SocketWrapper

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

class SocketWrapperTests: XCTestCase {
    
    func testUDPSend() {
        do {
            //Create a UDP Socket
            let socket = try Socket(format: .udp)
            var data = "send once".networkRepresentation
            
            try data.withUnsafeBytes({ (ptr) -> Void in
                try socket.send(message: ptr, ofLength: data.count, toAddress: "192.168.1.4", onService: .port(7000))
            })
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testNetworkRepresentable() {
        let unsignedInt8 = Data([0xFF])
        let unsignedInt16 = Data([0x11, 0x01])
        let unsignedInt32 = Data([0, 0, 0, 0])
        let unsignedInt = Data([0, 0, 0, 0, 0, 0, 0, 0])
        
        let uint8 = UInt8(fromNetworkRepresentation: unsignedInt8)
        XCTAssertEqual(uint8, 255)
        let uint16 = UInt16(fromNetworkRepresentation: unsignedInt16)
        XCTAssertEqual(uint16, 4096 + 256 + 1)
//        let uint32 = UInt32(fromNetworkRepresentation: unsignedInt32)
//        XCTAssertEqual(uint32, 0)
//        let uint = UInt(fromNetworkRepresentation: unsignedInt)
//        XCTAssertEqual(uint, 2)
        
        do {
            let socket = try Socket(format: .udp)
//            try socket.send(data: unsignedInt8.networkRepresentation, toAddress: "192.168.1.6", onService: .port(58228))
            let int: UInt16 = 4353
            try socket.send(data: int.networkRepresentation, toAddress: "192.168.1.6", onService: .port(53589))
//            try socket.send(data: unsignedInt32.networkRepresentation, toAddress: "192.168.1.6", onService: .port(58228))
//            try socket.send(data: unsignedInt.networkRepresentation, toAddress: "192.168.1.6", onService: .port(58228))
        } catch {
            XCTFail("\(error)")
        }
    }
    
}
