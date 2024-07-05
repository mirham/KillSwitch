//
//  NetworkStatus.swift
//  KillSwitch
//
//  Created by UglyGeorge on 07.06.2024.
//

import Foundation
import Network

class NetworkStatusService: ServiceBase, ApiCallable {    
    private let ipService = IpService.shared
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: Constants.networkMonitorQueryLabel, qos: .background)
    
    let lock = NSLock()
    
    override init() {
        super.init()
        
        monitor.pathUpdateHandler = { path in
            var newStatus = NetworkStatusType.unknown
            var newNetworkInterfaces = [NetworkInterface]()
             
            for networkInterface in path.availableInterfaces {
                let networkInterfaceInfo = self.getActiveNetworkInterfaceInfo(interface: networkInterface)
                newNetworkInterfaces.append(networkInterfaceInfo)
            }
            
            switch path.status {
                case .satisfied:
                    newStatus = self.networkInterfacesContainsPhysical(interfaces: newNetworkInterfaces) 
                        ? NetworkStatusType.on
                        : NetworkStatusType.wait
                case .requiresConnection:
                    newStatus = NetworkStatusType.wait
                default:
                    newStatus = NetworkStatusType.off
            }
            
            if (self.appState.network.status != newStatus || self.appState.network.interfaces != newNetworkInterfaces) {
                let updatedStatus = newStatus
                let updatedNetworkInterfaces = newNetworkInterfaces
                
                if (newStatus == .on) {
                    self.getCurrentIp()
                }
                
                Task {
                    await MainActor.run {
                        self.updateStatus(
                            currentStatus: updatedStatus,
                            networkInterfaces: updatedNetworkInterfaces,
                            disconnected: updatedStatus != .on)
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: Private functions
    
    private func getCurrentIp() {
        lock.lock()
        Task {
            do {
                try await Task.sleep(nanoseconds: 100_000_000) // Fixes SSL errors after network changes
                
                let updatedIpResult = await self.ipService.getCurrentIpAsync()
                
                if (updatedIpResult.success) {
                    await MainActor.run {
                        updateStatus(currentIpInfo: updatedIpResult.result)
                    }
                    Log.write(message: String(format: Constants.logCurrentIp, updatedIpResult.result!.ipAddress))
                }
            }
        }
        lock.unlock()
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
                return NetworkInterface(
                    name: interface.name,
                    type: interface.name.hasPrefix(Constants.utun) ? NetworkInterfaceType.vpn : NetworkInterfaceType.other)
            @unknown default:
                return NetworkInterface(name: interface.name, type: NetworkInterfaceType.unknown)
        }
    }
    
    private func networkInterfacesContainsPhysical(interfaces: [NetworkInterface]) -> Bool {
        let result = interfaces.contains(where: {$0.type == .cellular || $0.type == .wifi || $0.type == .wired})
        
        return result
    }
    
    private func updateStatus(
        currentIpInfo: IpInfoBase? = nil,
        currentStatus: NetworkStatusType? = nil,
        networkInterfaces: [NetworkInterface]? = nil,
        disconnected: Bool? = nil) {
        DispatchQueue.main.async {
            if (currentStatus != nil) {
                self.appState.network.status = currentStatus!
            }
            
            if (currentIpInfo != nil) {
                self.appState.network.currentIpInfo = currentIpInfo!
            }
                
            if (networkInterfaces != nil) {
                self.appState.network.interfaces = networkInterfaces!
            }
            
            if(disconnected != nil && disconnected!) {
                self.appState.network.currentIpInfo = nil
                self.appState.current.safetyType = .unknown
            }
            
            self.appState.objectWillChange.send()
        }
    }
}
