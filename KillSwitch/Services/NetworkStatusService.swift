//
//  NetworkStatusService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 07.06.2024.
//

import Foundation
import Network

class NetworkStatusService: ServiceBase, ApiCallable {    
    private let ipService = IpService.shared
    private let networkService = NetworkService.shared
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: Constants.networkMonitorQueryLabel, qos: .background)
    
    private let lock = NSLock()
    
    override init() {
        super.init()
        
        monitor.pathUpdateHandler = { path in
            var newStatus = NetworkStatusType.unknown
            var newNetworkInterfaces = [NetworkInterface]()
            
            for networkInterface in path.availableInterfaces {
                let networkInterfaceInfo = networkInterface.asNetworkInterface()
                newNetworkInterfaces.append(networkInterfaceInfo)
            }
            
            switch path.status {
                case .satisfied:
                    newStatus = newNetworkInterfaces.contains(where: {$0.isPhysical})
                        ? NetworkStatusType.on
                        : NetworkStatusType.wait
                case .requiresConnection:
                    newStatus = NetworkStatusType.wait
                default:
                    newStatus = NetworkStatusType.off
            }
            
            if (self.appState.network.status != newStatus || self.appState.network.activeNetworkInterfaces != newNetworkInterfaces) {
                let updatedStatus = newStatus
                let updatedNetworkInterfaces = newNetworkInterfaces
                
                if (newStatus == .on) {
                    self.getCurrentIp()
                }
                
                Task {
                    await MainActor.run {
                        self.updateStatus(
                            currentStatus: updatedStatus,
                            activeNetworkInterfaces: updatedNetworkInterfaces,
                            physicalNetworkInterfaces: self.networkService.getPhysicalInterfaces(),
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
    
    private func updateStatus(
        currentIpInfo: IpInfoBase? = nil,
        currentStatus: NetworkStatusType? = nil,
        activeNetworkInterfaces: [NetworkInterface]? = nil,
        physicalNetworkInterfaces: [NetworkInterface]? = nil,
        disconnected: Bool? = nil) {
        DispatchQueue.main.async {
            if (currentStatus != nil) {
                self.appState.network.status = currentStatus!
            }
            
            if (currentIpInfo != nil) {
                self.appState.network.currentIpInfo = currentIpInfo!
            }
                
            if (activeNetworkInterfaces != nil) {
                self.appState.network.activeNetworkInterfaces = activeNetworkInterfaces!
            }
            
            if (physicalNetworkInterfaces != nil) {
                self.appState.network.physicalNetworkInterfaces = physicalNetworkInterfaces!
            }
            
            if(disconnected != nil && disconnected!) {
                self.appState.network.currentIpInfo = nil
                self.appState.current.safetyType = .unknown
            }
            
            self.appState.objectWillChange.send()
        }
    }
}
