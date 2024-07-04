//
//  NetworkStatus.swift
//  KillSwitch
//
//  Created by UglyGeorge on 07.06.2024.
//

import Foundation
import Network

class NetworkStatusService: ServiceBase, ApiCallable {    
    private let addressesService = AddressesService.shared
    
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
            
            if (self.appState.network.status != newStatus || self.appState.network.interfaces != newNetworkInterfaces) {
                let updatedStatus = newStatus
                let updatedNetworkInterfaces = newNetworkInterfaces
                
                Task {
                    await MainActor.run {
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
        networkInterfaces: [NetworkInterface]? = nil) {
        DispatchQueue.main.async {
            if(currentStatus != nil){
                self.appState.network.status = currentStatus!
            }
            
            if(currentIpAddressInfo != nil) {
                self.appState.network.ipAddressInfo = currentIpAddressInfo!
            }
                
            if(networkInterfaces != nil) {
                self.appState.network.interfaces = networkInterfaces!
            }
            
            self.appState.objectWillChange.send()
        }
    }
}
