//
//  NetworkStatus.swift
//  KillSwitch
//
//  Created by UglyGeorge on 07.06.2024.
//

import Foundation
import Network

class NetworkStatusService: NetworkServiceBase, ObservableObject {
    @Published var currentStatus: NetworkStatusType = NetworkStatusType.unknown
    @Published var currentNetworkInterfaces: [NetworkInterface] = [NetworkInterface]()
    @Published var isSupportsDns: Bool = false
    @Published var isLowDataMode: Bool = false
    @Published var isHotspot: Bool = false
    @Published var supportsIp4: Bool = false
    @Published var supportsIp6: Bool = false
    @Published var description: String = String()
    @Published var currentIpAddressInfo: AddressInfoBase? = nil
    
    static let shared = NetworkStatusService()
    
    private let addressesService = AddressesService.shared
    private let loggingService = LoggingService.shared
    
    var currentStatusNonPublished: NetworkStatusType = NetworkStatusType.unknown
    var currentIpAddressNonPublished: String? = nil
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: Constants.networkMonitorQueryLabel, qos: .background)
    
    private var isGettingIpAddressInProcess = false
    
    init() {
        isGettingIpAddressInProcess = false

        monitor.pathUpdateHandler = { path in
            var newStatus = NetworkStatusType.unknown
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
               || self.currentNetworkInterfaces != newNetworkInterfaces
               || self.isSupportsDns != newIsSupportsDns
               || self.isLowDataMode != newIsLowDataMode
               || self.isHotspot != newIsHotspot
               || self.supportsIp4 != newSupportsIp4
               || self.supportsIp6 != newSupportsIp6
               || self.description != newDescription
            {
                DispatchQueue.main.async {
                    self.currentStatus = newStatus
                    self.isSupportsDns = newIsSupportsDns
                    self.isLowDataMode = newIsLowDataMode
                    self.isHotspot = newIsHotspot
                    self.supportsIp4 = newSupportsIp4
                    self.supportsIp6 = newSupportsIp6
                    self.description = newDescription
                    self.currentNetworkInterfaces = newNetworkInterfaces
                    
                    self.currentStatusNonPublished = newStatus
                    
                    self.setCurrentIpAddressInfo()
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: Private functions
    
    private func setCurrentIpAddressInfo() {
        if(!isGettingIpAddressInProcess)
        {
            Task {
                do {
                    self.isGettingIpAddressInProcess = true
                    
                    let api = addressesService.getRandomActiveAddressApi()
                    
                    if(api == nil) {
                        resetCurrentIpAddressData()
                    }
                    else{
                        let currentIp = await addressesService.getCurrentIpAddress(addressApiUrl: api!.url)
                        
                        if(currentIp == nil) {
                            resetCurrentIpAddressData()
                        }
                        else {
                            self.currentIpAddressNonPublished = currentIp
                            self.currentIpAddressInfo = await addressesService.getIpAddressInfo(ipAddress: currentIp!) ?? AddressInfoBase(ipAddress: currentIp!)
                        }
                    }
                    
                    self.isGettingIpAddressInProcess = false
                    
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                    }
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
    
    private func resetCurrentIpAddressData() {
        self.currentIpAddressInfo = nil
        self.currentIpAddressNonPublished = nil
    }
}
