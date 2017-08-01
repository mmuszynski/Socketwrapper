//
//  SocketAddress.swift
//  SocketWrapper
//
//  Created by Mike Muszynski on 7/31/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation

/// Describes the family used in the `SocketAddress`
enum SocketAddressFamily {
    ///**AF_LOCAL:**
    ///This designates the address format that goes with the local namespace. (PF_LOCAL is the name of that namespace.) See Local Namespace Details, for information about this address format.
    case local

    ///**AF_UNIX:**
    ///This is a synonym for AF_LOCAL. Although AF_LOCAL is mandated by POSIX.1g, AF_UNIX is portable to more systems. AF_UNIX was the traditional name stemming from BSD, so even most POSIX systems support it. It is also the name of choice in the Unix98 specification. (The same is true for PF_UNIX vs. PF_LOCAL).
    case unix
    
    ///**AF_FILE:**
    ///This is another synonym for AF_LOCAL, for compatibility. (PF_FILE is likewise a synonym for PF_LOCAL.)
    case file
    
    ///**AF_INET:**
    ///This designates the address format that goes with the Internet namespace. (PF_INET is the name of that namespace.) See Internet Address Formats.
    case inet4
    
    ///**AF_INET6:**
    ///This is similar to AF_INET, but refers to the IPv6 protocol. (PF_INET6 is the name of the corresponding namespace.)
    case inet6
    
    ///**AF_UNSPEC:**
    ///This designates no particular address format. It is used only in rare cases, such as to clear out the default destination address of a “connected” datagram socket. See Sending Datagrams.
    case unspec
    
    var afValue: Int32 {
        switch self {
        case .local, .file:
            return AF_LOCAL
        case .unix:
            return AF_UNIX
        case .inet4:
            return AF_INET
        case .inet6:
            return AF_INET6
        case .unspec:
            return AF_UNSPEC
        }
    }
        
}
