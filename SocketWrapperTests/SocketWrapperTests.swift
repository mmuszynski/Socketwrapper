//
//  SocketWrapperTests.swift
//  SocketWrapperTests
//
//  Created by Mike Muszynski on 7/31/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import XCTest
@testable import SocketWrapper

class SocketWrapperTests: XCTestCase {
    
    func testSocketCreate() {
        do {
            let socket = Socket(format: .udp)
            try socket.setReceiveTimeout(seconds: 5.1)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testUDPSend() {
        do {
            //Create a UDP Socket
            let socket = Socket(format: .udp)
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
        let unsignedInt32 = Data([0x00, 0x02, 0x10, 0x04])
        let unsignedInt = Data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        
        let uint8 = UInt8(withNetworkRepresentation: unsignedInt8)
        XCTAssertEqual(uint8, 255)
        let uint16 = UInt16(withNetworkRepresentation: unsignedInt16)
        XCTAssertEqual(uint16, 4096 + 256 + 1)
        let uint32 = UInt32(withNetworkRepresentation: unsignedInt32)
        XCTAssertEqual(uint32, 135172)
        let uint = UInt(withNetworkRepresentation: unsignedInt)
        XCTAssertEqual(uint, 72623859790382856)
    }
    
    func testPacketDecoding() {
        let hex: [UInt8] = [0x41, 0x70, 0x00, 0x00, 0x46, 0xDF, 0xC0, 0xB8, 0x48, 0x92, 0xE2, 0x33, 0x3F, 0x7E, 0xAB, 0x1D, 0xC0, 0x49, 0x0F, 0xD8, 0x3D, 0x44, 0x14, 0x1E, 0x43, 0x5F, 0x1E, 0xB7, 0x42, 0xB5, 0x3B, 0x4C, 0x49, 0x12, 0x7C, 0x00, 0x54, 0x4D, 0x90, 0xF1, 0x40, 0xF0, 0x00, 0x00, 0x40, 0xF0, 0x00, 0x00, 0x43, 0x70, 0x00, 0x00, 0x43, 0x70, 0x00, 0x00, 0xB8, 0x6D, 0x80, 0xB0, 0x3A, 0xCD, 0xFD, 0xA6, 0xBA, 0x86, 0xBA, 0xCA, 0x3F, 0xB5, 0xAC, 0x69, 0xBA, 0x0D, 0xA1, 0x5D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        
        let data = Data(bytes: hex)
        XCTAssertEqual(try! data.decode(Float.self, atOffset: 0), 15)
        XCTAssertEqual(try! data.decode(Float.self, atOffset: 4), 28640.359)
        XCTAssertEqual(try! data.decode(Float.self, atOffset: 8), 300817.59)
        XCTAssertEqual(try! data.decode(Float.self, atOffset: 12), 0.994798481464385986328125)
        XCTAssertEqual(try! data.decode(Float.self, atOffset: 16), -3.1415920257568359375)
        XCTAssertEqual(try! data.decode(Float.self, atOffset: 20), 0.047870747745037078857421875)
        XCTAssertEqual(try! data.decode(Float.self, atOffset: 24), 223.1199798583984375)
    }
    
    func testPacketReceive() {
        let expectation = self.expectation(description: "waiting on timeout")
        DispatchQueue.global().async {
            do {
                let sender = Socket(format: .udp)
                let receiver = Socket(format: .udp)
                
                DispatchQueue.global().async {
                    do {
                        try receiver.setReceiveTimeout(seconds: 5.0)
                        try receiver.bindSelf(to: "localhost", on: .port(54321))
                        try receiver.blockingReceive()
                        
                        let buffer = Data(bytes: receiver.messageBuffer[0..<2])
                        let string = String(withNetworkRepresentation: buffer)
                        XCTAssertEqual(string, "yo")
                        
                        expectation.fulfill()
                    } catch {
                        XCTFail("\(error)")
                        expectation.fulfill()
                    }
                }
                
                try sender.send(data: "yo".networkRepresentation, toAddress: "localhost", onService: .port(54321))
            } catch {
                XCTFail("\(error)")
                expectation.fulfill()
            }
        }
        self.waitForExpectations(timeout: 20.0, handler: nil)
    }
    
    func testPacketReceiveTimeout() {
        let expectation = self.expectation(description: "waiting on timeout")
        DispatchQueue.global().async {
            do {
                let socket = Socket(format: .udp)
                //try! socket.send(message: "ready player one", ofLength: "ready player one".count, toAddress: "localhost", onService: .port(62997))
                try socket.setReceiveTimeout(seconds: 1.0)
                try socket.blockingReceive()
                expectation.fulfill()
            } catch SocketError.timeout {
                expectation.fulfill()
            } catch {
                XCTFail("Wrong error: \(error)")
                expectation.fulfill()
            }
        }
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testHeartbeatReceiver() {
        XCTFail()
        let heartbeatSender = Socket(format: .udp)
        let receiver = Socket(format: .udp)
        
        do {
            try receiver.bindSelf(to: "localhost", on: .port(12345))
            try receiver.setReceiveTimeout(seconds: 2.0)
        } catch {
            XCTFail()
        }
        
        let timer = Timer(timeInterval: 0.5, repeats: true) { timer in
            do {
                try heartbeatSender.send(data: "beat".networkRepresentation, toAddress: "localhost", onService: .port(12345))
            } catch {
                XCTFail()
            }
        }
        
        DispatchQueue.global().async {
            do {
                try receiver.blockingReceive()
            } catch {
                XCTFail()
            }
        }
    }
    
}
