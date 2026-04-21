//
//  NetworkStatusService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 07.06.2024.
//

import Foundation
import Network
import Factory

class NetworkStatusService: ApiCallable, NetworkStatusServiceType {
    @Injected(\.appState) private var appState
    @Injected(\.networkService) private var networkService
    @Injected(\.networkInterfaceInfoService) private var networkInterfaceInfoService
    
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(
        label: Constants.networkMonitorQueryLabel,
        qos: .background
    )
    private var ipUpdateTask: Task<Void, Never>?
    private var checkConnectionTask: Task<Void, Never>?
    
    init() {
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
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self
            else { return }
            
            let quickStatus = determineNetworkStatus(
                path: path,
                activeInterfaces: path.availableInterfaces
                    .map { $0.asNetworkInterface() }
            )
            
            guard appState.network.isConnectionChanged(
                status: quickStatus,
                activeNetworkInterfaces: path.availableInterfaces.map { $0.asNetworkInterface() }
            )
            else { return }
            
            ipUpdateTask?.cancel()
            
            ipUpdateTask = Task { [weak self] in
                guard let self else { return }
                
                let activeInterfaces = await determineNetworkInterfacesAsync(path: path)
                let physicalInterfaces = networkService.getPhysicalInterfaces()
                let status = determineNetworkStatus(path: path, activeInterfaces: activeInterfaces)
                
                guard appState.network.isConnectionChanged(
                    status: status,
                    activeNetworkInterfaces: activeInterfaces
                ) else { return }
                
                await updateStatusAsync {
                    $0.withStatus(status)
                        .withActiveNetworkInterfaces(activeInterfaces)
                        .withPhysicalNetworkInterfaces(physicalInterfaces)
                        .withIsDisconnected(status != .on)
                }
                
                guard status == .on, !Task.isCancelled
                else { return }
                
                do {
                    try await Task.sleep(nanoseconds: Constants.defaultToleranceInNanoseconds)
                    await networkService.refreshPublicIpAsync()
                } catch {
                    // Sleep was cancelled externally — task exits cleanly
                }
            }
        }
        
        monitor.start(queue: monitorQueue)
    }
    
    private func startConnectionMonitoring() {
        checkConnectionTask = Task { [weak self] in
            guard let self
            else { return }
            
            while !Task.isCancelled {
                try? await Task.sleep(
                    nanoseconds: Constants.defaultCheckConnectionIntervalNanoseconds
                )
                
                guard shouldFetchPublicIp()
                else { continue }
                
                await networkService.refreshPublicIpAsync()
            }
        }
    }
    
    // MARK: - Pure Helpers
    
    private func determineNetworkStatus(
        path: NWPath,
        activeInterfaces: [NetworkInterface]
    ) -> NetworkStatusType {
        switch path.status {
            case .satisfied:
                return activeInterfaces.contains(where: \.isPhysical) ? .on : .wait
            case .requiresConnection:
                return .wait
            default:
                return .off
        }
    }
    
    private func determineNetworkInterfacesAsync(path: NWPath) async -> [NetworkInterface] {
        var seen = Set<String>()
        
        let interfaces: [NetworkInterface] = path.availableInterfaces.compactMap {
            let interface = $0.asNetworkInterface()
            return seen.insert(interface.name).inserted ? interface : nil
        }
        
        var result = [NetworkInterface]()
        
        for var interface in interfaces {
            interface.friendlyName = await networkInterfaceInfoService
                .getFriendlyNameAsync(for: interface)
            result.append(interface)
        }
        
        return result
    }
    
    private func shouldFetchPublicIp() -> Bool {
        guard appState.network.status == .on,
              !appState.network.isObtainingIp
        else { return false }
        
        return appState.network.publicIp?.hasLocation() != true
    }
    
    private func updateStatusAsync(
        _ configure: (NetworkStateUpdateBuilder) -> NetworkStateUpdateBuilder
    ) async {
        guard !Task.isCancelled
        else { return }
        
        let update = configure(NetworkStateUpdateBuilder()).build()
        
        await MainActor.run {
            appState.applyNetworkUpdate(update)
        }
    }
}
