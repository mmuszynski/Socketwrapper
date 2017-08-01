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
    
    func testUDPSend() {
        do {
            //Create a UDP Socket
            let socket = try Socket(format: .udp)
            var f: Float = 4.0
            var data = Data()
            data.encode("is anybody there")
            
            try data.withUnsafeBytes({ (ptr) -> Void in
                try socket.send(message: ptr, ofLength: data.count, toAddress: "www.mmuszynski.com", onService: .port(7000))
            })
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
}
