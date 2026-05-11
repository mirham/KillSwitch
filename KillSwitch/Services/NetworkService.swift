//
//  NetworkService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import Network
import SystemConfiguration
import Factory

final class NetworkService: ShellAccessible, NetworkServiceType {
    @Injected(\.appState) private var appState
    @Injected(\.ipService) private var ipService
    @LazyInjected(\.loggingService) private var loggingService
    
    func isUrlReachableAsync(url: String) async throws -> Bool {
        guard !Task.isCancelled
        else { throw NetworkError.taskCancelled }
        
        guard let parsedUrl = URL(string: url)
        else { throw NetworkError.invalidUrl(url) }
        
        var request = URLRequest(url: parsedUrl)
        request.httpMethod = Constants.headHttpMethod
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse
        else { throw NetworkError.invalidResponse }
        
        return httpResponse.statusCode == 200
    }
    
    func refreshPublicIpAsync() async {
        await updateStatusAsync { $0.withIsFetchingIp(true) }
        
        defer {
            Task { await updateStatusAsync { $0.withIsFetchingIp(false) } }
        }
        
        let publicIp = await fetchPublicIpAsync()
        
        await updateStatusAsync {
            $0.withIsFetchingIp(false)
                .withPublicIp(publicIp)
        }
    }
    
    func getPhysicalInterfaces() -> [NetworkInterface] {
        let interfaces = SCNetworkInterfaceCopyAll() as? [SCNetworkInterface] ?? []
        
        return interfaces.compactMap { interface in
            guard
                let name = SCNetworkInterfaceGetLocalizedDisplayName(interface) as String?,
                let bsdName = SCNetworkInterfaceGetBSDName(interface) as String?,
                isPhysical(bsdName: bsdName, displayName: name)
            else { return nil }
            
            return NetworkInterface(
                name: bsdName,
                type: interfaceType(for: name),
                localizedName: name
            )
        }
    }
    
    func enableNetworkInterfaceAsync(interfaceName: String) async {
        do {
            try await safeShellAsync(String(
                format: Constants.shCommandEnableNetworkIterface,
                interfaceName))
            
            loggingService.write(
                message: String(
                    format: Constants.logNetworkInterfaceHasBeenEnabled,
                    interfaceName),
                type: .success)
        } catch {
            let networkError = NetworkError.interfaceCommandFailed(
                interfaceName: interfaceName,
                action: .enable
            )
            
            loggingService.write(
                message: networkError.errorDescription ?? networkError.localizedDescription,
                type: .error)
        }
    }
    
    func disableNetworkInterfaceAsync(interfaceName: String) async {
        do {
            try await safeShellAsync(String(
                format: Constants.shCommandDisableNetworkIterface,
                interfaceName))
            
            loggingService.write(
                message: String(
                    format: Constants.logNetworkInterfaceHasBeenDisabled,
                    interfaceName),
                type: .success)
        } catch {
            let networkError = NetworkError.interfaceCommandFailed(
                interfaceName: interfaceName,
                action: .disable
            )
            
            loggingService.write(
                message: networkError.errorDescription ?? networkError.localizedDescription,
                type: .error)
        }
    }
    
    // MARK: Private functions
    
    private func fetchPublicIpAsync() async -> IpInfoBase? {
        let snapshot = await MainActor.run {
            (
                hasActiveApi: appState.userData.hasActiveIpApi(),
                status: appState.network.status
            )
        }
        
        guard !Task.isCancelled, snapshot.hasActiveApi, snapshot.status == .on
        else { return nil }
        
        let publicIpResult = await ipService.getPublicIpAsync(
            ipApiUrl: nil,
            withInfo: true)
        
        guard let result = publicIpResult.result
        else { return nil }
        
        loggingService.write(
            message: String(
                format: Constants.logPublicIp,
                result.ipAddress,
                result.countryName,
                result.fetchedFromApi ?? String()
            ),
            type: .info)
        
        return result
    }
    
    private func isPhysical(bsdName: String, displayName: String) -> Bool {
        bsdName.hasPrefix(Constants.physicalNetworkInterfacePrefix)
        && !displayName.localizedCaseInsensitiveContains(
            Constants.physicalNetworkInterfaceExclusion)
    }
    
    private func interfaceType(for displayName: String) -> NetworkInterfaceType {
        if displayName.localizedCaseInsensitiveContains(
            Constants.physicalNetworkInterfaceWiFi) {
            return .wifi
        }
        
        if displayName.localizedCaseInsensitiveContains(
            Constants.physicalNetworkInterfaceLan) {
            return .wired
        }
        
        return .other
    }
    
    private func updateStatusAsync(
        _ configure: (NetworkStateUpdateBuilder)
        -> NetworkStateUpdateBuilder) async {
        guard !Task.isCancelled
        else { return }
        
        let update = configure(NetworkStateUpdateBuilder()).build()
        
        await MainActor.run {
            appState.applyNetworkUpdate(update)
        }
    }
}
