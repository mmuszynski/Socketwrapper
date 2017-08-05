//
//  Socket.swift
//  SocketWrapper
//
//  Created by Mike Muszynski on 7/31/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation

//Communication Style: SOCK_STREAM/SOCK_DGRAM
//Namespace
//Protocol

public enum SocketNamespace {
    case local, internet
    
    var value: Int32 {
        switch self {
        case .local:
            return PF_LOCAL
        case .internet:
            return PF_INET
        }
    }
}

public enum SocketFormat {
    case tcp, udp, raw
    
    var value: Int32 {
        switch self {
        case .tcp:
            return SOCK_STREAM
        case .udp:
            return SOCK_DGRAM
        case .raw:
            return SOCK_RAW
        }
    }
}

public enum SocketAddressService {
    case name(_: String)
    case port(_: Int)
    case any
    
    var description: String {
        switch self {
        case .name(let name):
            return name
        case .port(let number):
            return "\(number)"
        case .any:
            return "any"
        }
    }
}

public class Socket {
    var fileDescriptor: Int32?
    var type: SocketFormat
    var namespace: SocketNamespace
    var addressFamily = SocketAddressFamily.inet4
    
    var bufferLength: Int {
        didSet {
            initializeMessageBuffer()
        }
    }
    var messageBuffer: [UInt8]!
    
    private func initializeMessageBuffer() {
        self.messageBuffer = [UInt8](repeatElement(0, count: bufferLength))
    }
    
    /// Initializes and creates a socket. Throws an error if the socket is not able to be created.
    ///
    /// - Parameter format: The `SocketFormat` to be used. Currently supports UDP, TCP, and RAW IP. J/K, only supports UDP right now.
    public init(format: SocketFormat, bufferLength: Int = 512, isLocal: Bool = false) {
        //Not sure if I really need this or not, but I'm going to include it for completeness.
        self.namespace = isLocal ? .local : .internet
        self.type = format
        self.bufferLength = bufferLength
        self.initializeMessageBuffer()
    }
    
    /// Creates the socket and sets the filedescriptor value. This is probably the only thing that needs to happen when sending a packet over UDP.
    ///
    /// - Throws: SocketCreateError translating the appropriate C errno.
    public func open() throws {
        //int socket (int namespace, int style, int protocol)
        let fd = socket(namespace.value, type.value, 0)
        guard fd != -1 else {
            throw SocketCreateError()
        }
        fileDescriptor = fd
    }
    

    /// Gets the address info as a `addrinfo` value
    ///
    /// - Parameters:
    ///   - hostname: A string describing the host name, either as a literal name or an IP string
    ///   - service: The port or service name
    /// - Returns: The address as an `addrinfo` struct
    /// - Throws: No errors yet.
    func getAddressInfo(hostname: String, service: SocketAddressService?) throws -> addrinfo {
        var hints = addrinfo()
        memset(&hints, 0, MemoryLayout<addrinfo>.stride)
        hints.ai_family = AF_INET
        hints.ai_socktype = self.type.value
        hints.ai_protocol = 0
        
        var result: UnsafeMutablePointer<addrinfo>? = nil
        
        let socketService = service ?? SocketAddressService.port(0)
        
        let status = getaddrinfo(hostname, socketService.description, &hints, &result)
        guard status == 0 else {
            //this error needs to be translated so that it makes more sense
            fatalError()
        }
        
        guard let address = result?.pointee else {
            //the memory was nil
            fatalError()
        }
        
        return address
    }
    
    public func bindSelf(to address: String, on service: SocketAddressService) throws {
        guard let fd = fileDescriptor else {
            try self.open()
            try self.bindSelf(to: address, on: service)
            return
        }
        
        let addr = try getAddressInfo(hostname: address, service: service)
        let result = bind(fd, addr.ai_addr, addr.ai_addrlen)
        guard result != -1 else {
            throw SocketError()
        }
    }
    
    func send(data: Data, toAddress address: String, onService service: SocketAddressService) throws {
        try data.withUnsafeBytes({ (dataPtr) -> Void in
            try send(message: dataPtr, ofLength: data.count, toAddress: address, onService: service)
        })
    }
    
    public func send(message: UnsafePointer<CChar>, ofLength length: Int, toAddress address: String, onService service: SocketAddressService) throws {
        switch self.type {
        case .udp:
            try sendUDP(message: message, ofLength: length, toAddress: address, onService: service)
        default:
            fatalError("not implemented")
        }
    }
    
    private func sendUDP(message: UnsafePointer<CChar>, ofLength length: Int, toAddress address: String, onService service: SocketAddressService) throws {
        
        guard let fd = fileDescriptor else {
            try open()
            try sendUDP(message: message, ofLength: length, toAddress: address, onService: service)
            return
        }
        
        //get the address info
        let addrinfo = try getAddressInfo(hostname: address, service: service)
        
        var adr: addrinfo? = addrinfo
        while adr != nil {
            if adr?.ai_family == self.addressFamily.afValue {
                break
            }
            adr = adr?.ai_next.pointee
        }
        
        guard let finalAddress = adr else {
            fatalError("Couldn't get an address for the send.")
        }
                
        sendto(fd,
               message,
               length,
               0,
               finalAddress.ai_addr,
               finalAddress.ai_addrlen)
        
    }
    
    /// Blocking listener implementing `recvfrom()`. The arguments for this method are optional for va
    ///
    /// - Throws: Don't know yet
    public func blockingReceive() throws {
        guard let fd = fileDescriptor else {
            try open()
            try blockingReceive()
            return
        }
        
        var fromAddr = sockaddr()
        var fromAddrLen = socklen_t()
        
        var buffer = [UInt8](repeatElement(0, count: bufferLength))
        let bytes = recvfrom(fd, &buffer, buffer.count, 0, &fromAddr, &fromAddrLen)
        self.messageBuffer = buffer
        
        guard bytes != -1 else {
            throw SocketError()
        }
    }
    
    public func setReceiveTimeout(seconds: Double) throws {
        guard let fd = fileDescriptor else {
            try self.open()
            try setReceiveTimeout(seconds: seconds)
            return
        }
        var time = timeval(tv_sec: Int(seconds), tv_usec: __darwin_suseconds_t(seconds.truncatingRemainder(dividingBy: 1.0) * 1000000))
        let code = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &time, socklen_t(MemoryLayout<timeval>.size))
        guard code == 0 else {
            fatalError("\(errno)")
        }
    }
    
}

public enum SocketCreateError: Error {
    ///*EPERM:*
    ///Insufficient privileges to create the socket.
    case insufficientPrivileges

    ///*EPROTONOSUPPORT*:
    ///The protocol or style is not supported by the namespace specified.
    case noSupportForProtocol
    
    ///*EMFILE*:
    ///The process already has too many file descriptors open.
    case tooManyProcessSocketsOpen
    
    ///*ENFILE*:
    ///The system already has too many file descriptors open.
    case tooManySystemSocketsOpen
    
    ///*EACCES*:
    ///The process does not have the privilege to create a socket of the specified style or protocol.
    case noAccessToCreateSocket

    ///*ENOBUFS*:
    ///The system ran out of internal buffer space.
    case bufferSpaceFull
    
    case unknownError(errno: Int32)
    
    init(errno: Int32 = errno) {
        switch errno {
        case EPROTONOSUPPORT:
            self = .noSupportForProtocol
        case EMFILE:
            self = .tooManyProcessSocketsOpen
        case ENFILE:
            self = .tooManySystemSocketsOpen
        case EACCES:
            self = .noAccessToCreateSocket
        case ENOBUFS:
            self = .bufferSpaceFull
        case EPERM:
            self = .insufficientPrivileges
        default:
            self = .unknownError(errno: errno)
        }
    }
}

/// Errors generated while binding a `SocketAddress` to a `Socket`
///
/// Further information found in the [GNU Manual](http://www.gnu.org/software/libc/manual/html_node/Setting-Address.html#Setting-Address).
public enum SocketBindError: Error {
    ///*EBADF:*
    ///The socket argument is not a valid file descriptor.
    case socketDescriptorInvalid

    ///*ENOTSOCK:*
    ///The descriptor socket is not a socket.
    case socketDescriptorNotASocket

    ///*EADDRNOTAVAIL:*
    //The specified address is not available on this machine.
    case addressNotAvailable

    ///*EADDRINUSE:*
    ///Some other socket is already using the specified address.
    case addressInUse

    /// *EINVAL:*
    ///The socket already has an address.
    case socketAlreadyHasAddress

    /// *EACCES:*
    ///You do not have permission to access the requested address.
    ///
    ///In the Internet domain, only the super-user is allowed to specify a port number in the range 0 through IPPORT_RESERVED minus one; see [Ports](http://www.gnu.org/software/libc/manual/html_node/Ports.html#Ports)
    case addressNoPermissionToAccess
    
    case unknownError(errno: Int32)
    
    init(errno: Int32 = errno) {
        switch errno {
        case EBADF:
            self = .socketDescriptorInvalid
        case ENOTSOCK:
            self = .socketDescriptorNotASocket
        case EADDRNOTAVAIL:
            self = .addressNotAvailable
        case EADDRINUSE:
            self = .addressInUse
        case EINVAL:
            self = .socketAlreadyHasAddress
        case EACCES:
            self = .addressNoPermissionToAccess
        default:
            self = .unknownError(errno: errno)
        }
    }
}
