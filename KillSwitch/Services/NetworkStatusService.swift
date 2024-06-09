//
//  NetworkStatus.swift
//  KillSwitch
//
//  Created by UglyGeorge on 07.06.2024.
//

import Foundation
import Network
import Combine

class NetworkStatusService: ObservableObject {
    @Published var currentStatus: NetworkStatusType = NetworkStatusType.unknown
    @Published var currentNetworkInterfaces: [NetworkInterface] = [NetworkInterface]()
    @Published var isSupportsDns: Bool = false
    @Published var isLowDataMode: Bool = false
    @Published var isHotspot: Bool = false
    @Published var supportsIp4: Bool = false
    @Published var supportsIp6: Bool = false
    @Published var description: String = String()
    @Published var currentIpAddress: String = String()
    
    static let shared = NetworkStatusService()
    
    private let loggingService = LoggingService.shared
    
    let monitor = NWPathMonitor()
    // TODO RUSS: Must be background, figue it out.
    let queue = DispatchQueue.main
    
    private var apisList = [
        "http://api.ipify.org",
        "http://icanhazip.com",
        "http://ipinfo.io/ip",
        "http://ipecho.net/plain",
        "http://ident.me",
        "https://checkip.amazonaws.com",
        "http://whatismyip.akamai.com",
        "https://ip.istatmenus.app",
        "https://api.seeip.org"
    ]
    
    init() {        
        monitor.pathUpdateHandler = { path in
            switch path.status {
                case .satisfied:
                    OperationQueue.main.addOperation {
                        self.currentStatus = NetworkStatusType.on
                    }
                case .requiresConnection:
                    OperationQueue.main.addOperation {
                        self.currentStatus = NetworkStatusType.wait
                    }
                case .unsatisfied:
                    OperationQueue.main.addOperation {
                        self.currentStatus = NetworkStatusType.off
                    }
                 default:
                    OperationQueue.main.addOperation {
                        self.currentStatus = NetworkStatusType.unknown
                    }
            }
            
            self.isSupportsDns = path.supportsDNS
            self.isLowDataMode = path.isConstrained
            self.isHotspot = path.isExpensive
            self.supportsIp4 = path.supportsIPv4
            self.supportsIp6 = path.supportsIPv6
            self.description = path.debugDescription
            
            Task {
                do {
                    let ip = await self.getCurrentIpAddress() ?? "None"
                    self.currentIpAddress = ip
                    
                    let logEntry = LogEntry(message: "Current IP:" + ip)
                    self.loggingService.log(logEntry: logEntry)
                }
            }
            
            self.currentNetworkInterfaces = [NetworkInterface]()
            
            // sleep(2)
            
            for networkInterface in path.availableInterfaces {
                let networkInterfaceInfo = self.getActiveNetworkInterfaceInfo(interface: networkInterface)
                self.currentNetworkInterfaces.append(networkInterfaceInfo)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    func getCurrentIpAddress() async -> String?{
        let ipAddressResponse = await callIpAddressApi(urlAddress: apisList.randomElement()!)
        let ipAddressString = ipAddressResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let _ = IPv4Address(ipAddressString) {
            return ipAddressString
        } else if let _ = IPv6Address(ipAddressString) {
            return ipAddressString
        } else {
            return nil
        }
    }
    
    private func getActiveNetworkInterfaceInfo(interface: NWInterface) -> NetworkInterface {
        switch interface.type {
            case .cellular:
                return NetworkInterface(name: interface.name, type: NetworkInterfaceType.cellular)
            case .loopback:
                return NetworkInterface(name: interface.name, type: NetworkInterfaceType.loopback)
            case .wifi:
                return NetworkInterface(name: interface.name, type: NetworkInterfaceType.wifi)
            case .wiredEthernet:
                return NetworkInterface(name: interface.name, type: NetworkInterfaceType.wired)
            case .other:
                return NetworkInterface(name: interface.name, type: NetworkInterfaceType.other)
            @unknown default:
                return NetworkInterface(name: interface.name, type: NetworkInterfaceType.unknown)
        }
    }
    
    private func callIpAddressApi(urlAddress : String) async -> String {
        do {
            let url = URL(string: urlAddress)!
            
            let request = URLRequest(url: url)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response  = String(data: data, encoding: String.Encoding.utf8) as String?
            
            let logEntry = LogEntry(message: "Called API:" + urlAddress)
            loggingService.log(logEntry: logEntry)
            
            return response ?? String()
        }
        catch {
            let logEntry = LogEntry(message: "Error when called API:\(error.localizedDescription)")
            loggingService.log(logEntry: logEntry)
            
            return String()
        }
    }
}
