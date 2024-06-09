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
    
    static let shared = NetworkStatusService()
    
    let monitor = NWPathMonitor()
    // TODO RUSS: Must be background, figue it out.
    let queue = DispatchQueue.global(qos: .default)
    
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
                @unknown default:
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
            
            self.currentNetworkInterfaces.removeAll()
            
            for networkInterface in path.availableInterfaces {
                let networkInterfaceInfo = self.geActiveNetworkInterfaceInfo(interface: networkInterface)
                self.currentNetworkInterfaces.append(networkInterfaceInfo)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func geActiveNetworkInterfaceInfo(interface: NWInterface) -> NetworkInterface {
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
