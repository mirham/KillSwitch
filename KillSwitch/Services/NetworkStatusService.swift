//
//  NetworkStatus.swift
//  KillSwitch
//
//  Created by UglyGeorge on 07.06.2024.
//

import Foundation
import Network

class NetworkStatusService: ServiceBase, ApiCallable, ObservableObject {
    @Published var currentStatus: NetworkStatusType = NetworkStatusType.unknown
    @Published var currentNetworkInterfaces: [NetworkInterface] = [NetworkInterface]()
    @Published var currentIpAddressInfo: AddressInfoBase? = nil
    
    static let shared = NetworkStatusService()
    
    private let addressesService = AddressesService.shared
    
    var currentStatusNonPublished: NetworkStatusType = NetworkStatusType.unknown
    var currentIpAddressNonPublished: String? = nil
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: Constants.networkMonitorQueryLabel, qos: .background)
    
    private var isGettingIpAddressInProcess = false
    
    override init() {
        super.init()
        
        isGettingIpAddressInProcess = false

        monitor.pathUpdateHandler = { path in
            var newStatus = NetworkStatusType.unknown
            var newNetworkInterfaces = [NetworkInterface]()
                
            switch path.status {
                case .satisfied:
                    newStatus = NetworkStatusType.on
                case .requiresConnection:
                    newStatus = NetworkStatusType.wait
                default:
                    newStatus = NetworkStatusType.off
            }
                
            for networkInterface in path.availableInterfaces {
                let networkInterfaceInfo = self.getActiveNetworkInterfaceInfo(interface: networkInterface)
                newNetworkInterfaces.append(networkInterfaceInfo)
            }
            
            if (self.currentStatus != newStatus || self.currentNetworkInterfaces != newNetworkInterfaces) {
                let updatedStatus = newStatus
                let updatedNetworkInterfaces = newNetworkInterfaces
                
                Task {
                    await MainActor.run {
                        self.updateStatus(resetNonPublisedProps: true)
                        self.updateStatus(currentStatus: updatedStatus, networkInterfaces: updatedNetworkInterfaces)
                    }
                }
                
                self.setCurrentIpAddressInfo()
            }
        }
        
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: Private functions
    
    private func setCurrentIpAddressInfo() {
        if(!isGettingIpAddressInProcess) {
            Task {
                do {
                    self.isGettingIpAddressInProcess = true
                    
                    let api = self.addressesService.getRandomActiveAddressApi()
                    
                    if (api != nil) {
                        let currentIp = await self.addressesService.getCurrentIpAddress(addressApiUrl: api!.url)
                        
                        if(currentIp != nil){
                            let info = await self.addressesService.getIpAddressInfo(ipAddress: currentIp!) ?? AddressInfoBase(ipAddress: currentIp!)
                            await MainActor.run {
                                updateStatus(currentIpAddressInfo: info)
                            }
                        }
                    }
                    
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
    
    private func updateStatus(
        currentIpAddressInfo: AddressInfoBase? = nil,
        currentStatus: NetworkStatusType? = nil,
        networkInterfaces: [NetworkInterface]? = nil,
        resetNonPublisedProps: Bool? = nil) {
        DispatchQueue.main.async {
            if(currentStatus != nil){
                self.currentStatus = currentStatus!
                self.currentStatusNonPublished = currentStatus!
            }
            
            if(currentIpAddressInfo != nil) {
                self.currentIpAddressInfo = currentIpAddressInfo!
                self.currentIpAddressNonPublished = currentIpAddressInfo!.ipAddress
            }
                
            if(networkInterfaces != nil) {
                self.currentNetworkInterfaces = networkInterfaces!
            }
            
            self.objectWillChange.send()
        }
            
        if(resetNonPublisedProps != nil && resetNonPublisedProps!) {
            self.currentIpAddressInfo = nil
            self.currentIpAddressNonPublished = nil
        }
    }
}
