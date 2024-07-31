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
                await MainActor.run { updateStatus(obtainingIp: true) }
                
                // Fixes SSL errors after network changes
                try await Task.sleep(nanoseconds: Constants.defaultToleranceInNanoseconds)
                
                var ipNotObtained = true
                
                while ipNotObtained && self.appState.userData.ipApis.contains(where: {$0.isActive()}) {
                    let updatedIpResult = await self.ipService.getCurrentIpAsync()
                    
                    if (updatedIpResult.success) {
                        ipNotObtained = false
                        await MainActor.run { updateStatus(currentIpInfo: updatedIpResult.result) }
                        Log.write(message: String(format: Constants.logCurrentIp, updatedIpResult.result!.ipAddress))
                    }
                }
                
                if (ipNotObtained) {
                    await MainActor.run { updateStatus(currentIpInfo: nil, allowCurrentIpInfoNil: true) }
                }
                
                await MainActor.run { updateStatus(obtainingIp: false) }
            }
        }
        lock.unlock()
    }
    
    private func updateStatus(
        currentIpInfo: IpInfoBase? = nil,
        currentStatus: NetworkStatusType? = nil,
        activeNetworkInterfaces: [NetworkInterface]? = nil,
        physicalNetworkInterfaces: [NetworkInterface]? = nil,
        disconnected: Bool? = nil,
        obtainingIp: Bool? = nil,
        allowCurrentIpInfoNil: Bool = false) {
        DispatchQueue.main.async {
            if (currentStatus != nil) {
                self.appState.network.status = currentStatus!
            }
            
            if (currentIpInfo != nil || allowCurrentIpInfoNil) {
                self.appState.network.currentIpInfo = currentIpInfo ?? nil
            }
                
            if (activeNetworkInterfaces != nil) {
                self.appState.network.activeNetworkInterfaces = activeNetworkInterfaces!
            }
            
            if (physicalNetworkInterfaces != nil) {
                self.appState.network.physicalNetworkInterfaces = physicalNetworkInterfaces!
            }
            
            if (disconnected != nil && disconnected!) {
                self.appState.network.currentIpInfo = nil
            }
            
            if (obtainingIp != nil) {
                self.appState.network.obtainingIp = obtainingIp!
            }
            
            self.appState.objectWillChange.send()
        }
    }
}
