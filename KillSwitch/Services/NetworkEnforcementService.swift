//
//  NetworkEnforcementService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 12.05.2026.
//

import Foundation
import Factory

final class NetworkEnforcementService: NetworkEnforcementServiceType {
    @Injected(\.appState) private var appState
    @Injected(\.networkService) private var networkService
    @Injected(\.processService) private var processService
    @LazyInjected(\.loggingService) private var loggingService
    
    func enforceAsync(for result: OperationResult<IpInfoBase>) async {
        if await shouldDisableConnectionAsync(for: result) {
            await disableActiveNetworkInterfacesAsync()
        }
    }
    
    func enforceIpAllowlistAsync() async {
        let snapshot = await MainActor.run {(
            isPublicIpAllowed: appState.current.isPublicIpAllowed,
            isFetchingIp: appState.network.isFetchingIp,
            publicIp: appState.network.publicIp,
            autoCloseApps: appState.userData.autoCloseApps,
            killingProcesses: appState.system.killingProcesses
        )}
        
        guard
            !snapshot.isPublicIpAllowed,
            !snapshot.isFetchingIp,
            let publicIp = snapshot.publicIp
        else { return }
        
        await disableActiveNetworkInterfacesAsync()
        
        loggingService.write(
            message: String(
                format: Constants.logPublicIpUpdatedWithNotFromWhitelist,
                publicIp.ipAddress
            ),
            type: .warning
        )
        
        if snapshot.autoCloseApps {
            processService.killProcesses(processes: snapshot.killingProcesses)
        }
    }
    
    func enforceIpApiAvailabilityAsync() async {
        let snapshot = await MainActor.run {(
            publicIp: appState.network.publicIp,
            hasActiveIpApi: appState.userData.hasActiveIpApi()
        )}
        
        guard
            snapshot.publicIp == nil,
            !snapshot.hasActiveIpApi
        else { return }
        
        await disableActiveNetworkInterfacesAsync()
        
        loggingService.write(
            message: Constants.errorNoActiveIpApiFound,
            type: .error)
    }
    
    // MARK: Private functions
    
    private func shouldDisableConnectionAsync(
        for result: OperationResult<IpInfoBase>) async -> Bool {
            await isUnsafeUnderExtendedProtectionAsync(result)
                || hasNoActiveIpApi(result)
        }
    
    private func isUnsafeUnderExtendedProtectionAsync(
        _ result: OperationResult<IpInfoBase>) async -> Bool {
            await MainActor.run {
                appState.userData.useExtendedProtection &&
                (appState.system.locationServicesEnabled
                 || appState.network.hasLeak
                 || result.result == nil)
            }
        }
    
    private func hasNoActiveIpApi(
        _ result: OperationResult<IpInfoBase>) -> Bool {
            result.error == Constants.errorNoActiveIpApiFound
        }
    
    private func disableActiveNetworkInterfacesAsync() async {
        let snapshot = await MainActor.run {(
            status: appState.network.status,
            physicalNetworkInterfaces: appState.network.physicalNetworkInterfaces
        )}
        
        guard snapshot.status != .off else { return }
        
        for networkInterface in snapshot.physicalNetworkInterfaces {
            await networkService.disableNetworkInterfaceAsync(
                interfaceName: networkInterface.name)
        }
    }
}
