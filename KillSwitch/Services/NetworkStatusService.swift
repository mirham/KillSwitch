//
//  NetworkStatusService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 07.06.2024.
//

import Foundation
import Network
import Factory

class NetworkStatusService: ServiceBase, ApiCallable, NetworkStatusServiceType {
    @Injected(\.ipService) private var ipService
    @Injected(\.networkService) private var networkService
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: Constants.networkMonitorQueryLabel, qos: .background)
    
    override init() {
        super.init()
        
        startNetworkMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: Private functions
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { path in
            let networkInterfaces = self.determineNetworkInterfaces(path: path)
            let physicalNetworkInterfaces = self.networkService.getPhysicalInterfaces()
            let status = self.determineNetworkStatusType(path: path, networkInterfaces: networkInterfaces)
            let isConnectionChanged = self.appState.network.isConnectionChanged (
                status: status, activeNetworkInterfaces: networkInterfaces)
            
            if (isConnectionChanged) {
                let updatedStatus = status
                let updatedActiveNetworkInterfaces = networkInterfaces
                let updatedPhysicalNetworkInterfaces = physicalNetworkInterfaces
                
                Task {
                    await self.updateStatusAsync(update: NetworkStateUpdateBuilder()
                        .withStatus(updatedStatus)
                        .withActiveNetworkInterfaces(updatedActiveNetworkInterfaces)
                        .withPhysicalNetworkInterfaces(updatedPhysicalNetworkInterfaces)
                        .withIsDisconnected(updatedStatus != .on)
                        .build())
                    
                    if status == .on {
                        try await Task.sleep(nanoseconds: Constants.defaultToleranceInNanoseconds)
                        await self.refreshIpAddressAsync()
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func refreshIpAddressAsync() async {
        await updateStatusAsync(update: NetworkStateUpdateBuilder()
            .withIsObtainingIp(true)
            .build())
        
        let publicIp = await fetchPublicIpAsync()
        
        await updateStatusAsync(update: NetworkStateUpdateBuilder()
            .withIsObtainingIp(false)
            .withPublicIp(publicIp)
            .build())
    }
    
    private func fetchPublicIpAsync() async -> IpInfoBase? {
        var isPublicIpNotObtained = true
        
        while isPublicIpNotObtained && appState.userData.activeIpApisExist() && appState.network.status == .on {
            let result = await ipService.getPublicIpAsync(ipApiUrl: nil, withInfo: true)
            
            if result.success {
                isPublicIpNotObtained = false
                
                loggingService.write(
                    message: String(format: Constants.logCurrentIp, result.result!.ipAddress),
                    type: .info)
                
                return result.result
            }
        }
        
        return nil
    }
    
    private func determineNetworkStatusType(
        path: NWPath,
        networkInterfaces: [NetworkInterface]) -> NetworkStatusType {
            switch path.status {
                case .satisfied:
                    return networkInterfaces.contains(where: {$0.isPhysical})
                        ? NetworkStatusType.on
                        : NetworkStatusType.wait
                case .requiresConnection:
                    return NetworkStatusType.wait
                default:
                    return NetworkStatusType.off
            }
        }
    
    private func determineNetworkInterfaces(path: NWPath) -> [NetworkInterface] {
        var result = [NetworkInterface]()
        
        for networkInterface in path.availableInterfaces {
            let networkInterfaceInfo = networkInterface.asNetworkInterface()
            result.append(networkInterfaceInfo)
        }
        
        return result
    }
    
    private func updateStatusAsync(update: NetworkStateUpdate) async {
        await MainActor.run {
            appState.applyNetworkUpdate(update)
            appState.objectWillChange.send()
        }
    }
}
