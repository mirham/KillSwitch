//
//  NetworkStatus.swift
//  KillSwitch
//
//  Created by UglyGeorge on 07.06.2024.
//

import Foundation
import Network
import Combine

class NetworkStatusService: NetworkServiceBase, ObservableObject {
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
    
    private let addressesService = AddressesService.shared
    private let loggingService = LoggingService.shared
    
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitor", qos: .background)
    //let queue = DispatchQueue.main
    
    var status: NetworkStatusType = NetworkStatusType.unknown
    var ip: String? = nil
    
    private var isGettingIpAddressInProcess = false
    
    init() {
        isGettingIpAddressInProcess = false

        monitor.pathUpdateHandler = { path in
            var newStatus = NetworkStatusType.unknown
            var newIpAddress = "None"
            var newIsSupportsDns = false
            var newIsLowDataMode = false
            var newIsHotspot = false
            var newSupportsIp4 = false
            var newSupportsIp6 = false
            var newDescription = String()
            var newNetworkInterfaces = [NetworkInterface]()
                
            switch path.status {
                case .satisfied:
                    newStatus = NetworkStatusType.on
                case .requiresConnection:
                    newStatus = NetworkStatusType.wait
                case .unsatisfied:
                    newStatus = NetworkStatusType.off
                default:
                    newStatus = NetworkStatusType.off
            }
                
            newIsSupportsDns = path.supportsDNS
            newIsLowDataMode = path.isConstrained
            newIsHotspot = path.isExpensive
            newSupportsIp4 = path.supportsIPv4
            newSupportsIp6 = path.supportsIPv6
            newDescription = path.debugDescription
                
            for networkInterface in path.availableInterfaces {
                let networkInterfaceInfo = self.getActiveNetworkInterfaceInfo(interface: networkInterface)
                newNetworkInterfaces.append(networkInterfaceInfo)
            }
            
            if self.currentStatus != newStatus
                || Set(self.currentNetworkInterfaces) != Set(newNetworkInterfaces)
               || self.isSupportsDns != newIsSupportsDns
               || self.isLowDataMode != newIsLowDataMode
               || self.isHotspot != newIsHotspot
               || self.supportsIp4 != newSupportsIp4
               || self.supportsIp6 != newSupportsIp6
               || self.description != newDescription
            {
                DispatchQueue.main.async(execute: {
                    self.currentStatus = newStatus
                    self.status = newStatus
                    self.isSupportsDns = newIsSupportsDns
                    self.isLowDataMode = newIsLowDataMode
                    self.isHotspot = newIsHotspot
                    self.supportsIp4 = newSupportsIp4
                    self.supportsIp6 = newSupportsIp6
                    self.description = newDescription
                    self.currentNetworkInterfaces = newNetworkInterfaces
                    
                    self.setCurrentIpAddress()
                })
            }
        }
        
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func setCurrentIpAddress(){
        if(!isGettingIpAddressInProcess)
        {
            Task {
                do {
                    self.isGettingIpAddressInProcess = true
                    
                    let currentIp = await addressesService.getCurrentIpAddress()
                    
                    if(currentIp != nil){
                        let logEntry = LogEntry(message: "Current IP: \(currentIp!)")
                        self.loggingService.log(logEntry: logEntry)
                    }
                    
                    let valueToSet = currentIp ?? "None"
                    
                    self.currentIpAddress = valueToSet
                    self.ip = valueToSet
                    
                    self.isGettingIpAddressInProcess = false
                }
            }
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
}
