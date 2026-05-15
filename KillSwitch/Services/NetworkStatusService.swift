//
//  NetworkStatusService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 07.06.2024.
//

import Foundation
import Network
import Factory

final class NetworkStatusService: ApiCallable, NetworkStatusServiceType {
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
    
    func setNetworkStatusAsync(status: NetworkStatusType) async {
        await updateStatusAsync {
            $0.withStatus(status)
        }
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
            let activeInterfaces = path.availableInterfaces
                .map { $0.asNetworkInterface() }
            
            Task { [weak self] in
                guard let self else { return }
                
                let changed = await MainActor.run {
                    self.appState.network.isConnectionChanged(
                        status: quickStatus,
                        activeNetworkInterfaces: activeInterfaces
                    )
                }
                
                guard changed else { return }
                handleNetworkChange(path: path)
            }
            
            handleNetworkChange(path: path)
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
                
                guard await shouldFetchPublicIpAsync()
                else { continue }
                
                await networkService.refreshPublicIpAsync()
            }
        }
    }
    
    private func handleNetworkChange(path: NWPath) {
        ipUpdateTask?.cancel()
        
        ipUpdateTask = Task { [weak self] in
            guard let self
            else { return }
            
            let activeInterfaces = await determineNetworkInterfacesAsync(path: path)
            let physicalInterfaces = networkService.getPhysicalInterfaces()
            let status = determineNetworkStatus(
                path: path,
                activeInterfaces: activeInterfaces)
            
            let shouldUpdate = await MainActor.run {
                self.appState.network.isConnectionChanged(
                    status: status,
                    activeNetworkInterfaces: activeInterfaces
                )
            }
            
            guard shouldUpdate
            else { return }
            
            await updateStatusAsync {
                $0.withStatus(status)
                    .withActiveNetworkInterfaces(activeInterfaces)
                    .withPhysicalNetworkInterfaces(physicalInterfaces)
                    .withIsDisconnected(status != .on)
            }
            
            await refreshPublicIpIfNeededAsync(status: status)
        }
    }
    
    private func determineNetworkStatus(
        path: NWPath,
        activeInterfaces: [NetworkInterface]
    ) -> NetworkStatusType {
        switch path.status {
            case .satisfied:
                return activeInterfaces.contains(where: \.isPhysical)
                    ? .on
                    : .wait
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
    
    private func shouldFetchPublicIpAsync() async -> Bool {
        await MainActor.run {
            guard appState.network.status == .on,
                  !appState.network.isFetchingIp
            else { return false }
            
            return appState.network.publicIp?.hasLocation() != true
        }
    }
    
    private func refreshPublicIpIfNeededAsync(status: NetworkStatusType) async {
        guard status == .on, !Task.isCancelled
        else { return }
        
        do {
            try await Task.sleep(nanoseconds: Constants.defaultToleranceInNanoseconds)
            await networkService.refreshPublicIpAsync()
        } catch {
            // Sleep was cancelled externally — task exits cleanly
        }
    }
    
    private func updateStatusAsync(
        _ configure: (NetworkStateUpdateBuilder) ->
        NetworkStateUpdateBuilder) async {
        guard !Task.isCancelled
        else { return }
        
        let update = configure(NetworkStateUpdateBuilder())
                .build()
        
        await MainActor.run {
            appState.applyNetworkUpdate(update)
        }
    }
}
