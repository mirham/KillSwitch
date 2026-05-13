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
    
    func enforce(for result: OperationResult<IpInfoBase>) {
        if shouldDisableConnection(for: result) {
            disableActiveNetworkInterfaces()
        }
    }
    
    func enforceIpAllowlist() {
        guard
            !appState.current.isPublicIpAllowed,
            !appState.network.isFetchingIp,
            let publicIp = appState.network.publicIp
        else { return }
        
        disableActiveNetworkInterfaces()
        
        loggingService.write(
            message: String(
                format: Constants.logPublicIpHasBeenUpdatedWithNotFromWhitelist,
                publicIp.ipAddress
            ),
            type: .warning
        )
        
        if appState.userData.autoCloseApps {
            processService.killProcesses(
                processes: appState.system.killingProcesses)
        }
    }
    
    func enforceIpApiAvailability() {
        guard
            appState.network.publicIp == nil,
            !appState.userData.hasActiveIpApi()
        else { return }
        
        disableActiveNetworkInterfaces()
        
        loggingService.write(
            message: Constants.errorNoActiveIpApiFound,
            type: .error)
    }
    
    // MARK: Private functions
    
    private func shouldDisableConnection(
        for result: OperationResult<IpInfoBase>) -> Bool {
            isUnsafeUnderExtendedProtection(result) || hasNoActiveIpApi(result)
        }
    
    private func isUnsafeUnderExtendedProtection(
        _ result: OperationResult<IpInfoBase>) -> Bool {
            appState.userData.useExtendedProtection &&
            (appState.system.locationServicesEnabled
             || appState.network.hasLeak
             || result.result == nil)
        }
    
    private func hasNoActiveIpApi(
        _ result: OperationResult<IpInfoBase>) -> Bool {
            result.error == Constants.errorNoActiveIpApiFound
        }
    
    private func disableActiveNetworkInterfaces() {
        guard appState.network.status != .off
        else { return }
        
        appState.network.physicalNetworkInterfaces.forEach { networkInterface in
            Task {
                await networkService.disableNetworkInterfaceAsync(
                    interfaceName: networkInterface.name)
            }
        }
    }
}
