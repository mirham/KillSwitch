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
    @Injected(\.networkService) private var networkService
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: Constants.networkMonitorQueryLabel, qos: .background)
    private var ipUpdateTask: Task<Void, Never>?
    private var checkConnectionTask: Task<Void, Never>?
    
    override init() {
        super.init()
        
        startNetworkMonitoring()
        startConnectionMonitoring()
    }
    
    deinit {
        monitor.cancel()
        ipUpdateTask?.cancel()
        checkConnectionTask?.cancel()
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
                
                self.ipUpdateTask?.cancel()
                
                self.ipUpdateTask = Task {
                    await self.updateStatusAsync(update: NetworkStateUpdateBuilder()
                        .withStatus(updatedStatus)
                        .withActiveNetworkInterfaces(updatedActiveNetworkInterfaces)
                        .withPhysicalNetworkInterfaces(updatedPhysicalNetworkInterfaces)
                        .withIsDisconnected(updatedStatus != .on)
                        .build())
                    
                    if status == .on {
                        do {
                            try await Task.sleep(nanoseconds: Constants.defaultToleranceInNanoseconds)
                            await self.networkService.refreshPublicIpAsync()
                        }
                        catch {
                            self.ipUpdateTask?.cancel()
                        }
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func startConnectionMonitoring() {
        checkConnectionTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: Constants.defaultCheckConnectionIntervalNanoseconds)
                
                guard shouldFetchPublicIp()
                else { continue }
                
                await self.networkService.refreshPublicIpAsync()
            }
        }
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
    
    private func shouldFetchPublicIp() -> Bool {
        return appState.network.status == .on
            && !appState.network.isObtainingIp
            && (appState.network.publicIp == nil
                || (appState.network.publicIp != nil
                    && !appState.network.publicIp!.hasLocation()))
    }
    
    private func updateStatusAsync(update: NetworkStateUpdate) async {
        guard !Task.isCancelled else { return }
        
        await MainActor.run {
            appState.applyNetworkUpdate(update)
            appState.objectWillChange.send()
        }
    }
}
