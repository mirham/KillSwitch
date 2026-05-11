//
//  MonitoringService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation
import Factory

final class MonitoringService: MonitoringServiceType {
    @Injected(\.appState) private var appState
    @Injected(\.ipService) private var ipService
    @Injected(\.dnsService) private var dnsService
    @Injected(\.webRtcService) private var webRtcService
    @Injected(\.networkService) private var networkService
    @Injected(\.processService) private var processService
    @Injected(\.computerService) private var computerService
    @LazyInjected(\.loggingService) private var loggingService
    
    private var monitoringTime: Int = 0
    private var monitoringTask: Task<Void, Never>?
    
    init() {
        if appState.monitoring.isEnabled {
            startMonitoring()
        }
    }
    
    deinit {
        monitoringTask?.cancel()
    }
    
    func startMonitoring() {
        monitoringTime = 0
        
        monitoringTask = Task { [weak self] in
            guard let self
            else { return }
            
            loggingService.write(
                message: Constants.logMonitoringHasBeenEnabled,
                type: .success)
            
            await updateStatusAsync { $0.withIsMonitoringEnabled(true) }
            
            computerService.startSleepPreventing()
            dnsService.startMonitoring()
            webRtcService.startMonitoring()
            
            while !Task.isCancelled && appState.monitoring.isEnabled {
                try? await Task.sleep(nanoseconds: Constants.defaultMonitoringIntervalNanoseconds)
                
                guard !Task.isCancelled
                else { break }
                
                monitoringTime = monitoringTime &+ Constants.defaultMonitoringInterval
                
                guard appState.network.status == .on
                else { continue }
                
                await runPeriodicChecksAsync()
            }
        }
    }
    
    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
        
        webRtcService.stopMonitoring()
        dnsService.stopMonitoring()
        computerService.stopSleepPreventing()
        
        loggingService.write(
            message: Constants.logMonitoringHasBeenDisabled,
            type: .success)
        
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            appState.applyMonitoringUpdate(
                MonitoringStateUpdateBuilder()
                    .withIsMonitoringEnabled(false)
                    .build()
            )
        }
    }
    
    // MARK: Private functions
    
    private func runPeriodicChecksAsync() async {
        let checkIp = appState.userData.periodicIpCheck &&
        monitoringTime % appState.userData.intervalBetweenChecks == 0
        
        if checkIp {
            let result = await ipService.getPublicIpAsync(
                ipApiUrl: nil,
                withInfo: true)
            
            await handleUpdatedPublicIpResultAsync(result)
        }
        
        enforceIpApiAvailability()
        enforceIpAllowlist()
    }
        
    private func handleUpdatedPublicIpResultAsync(
        _ result: OperationResult<IpInfoBase>) async {
        guard !Task.isCancelled
        else { return }
        
        if shouldDisableConnection(for: result) {
            disableActiveNetworkInterfaces()
        }
        
        guard let ipInfo = result.result
        else {
            loggingService.write(
                message: result.error!,
                type: .error
            )
            
            return
        }
        
        if ipInfo.ipAddress != appState.network.publicIp?.ipAddress {
            await updateStatusAsync { $0.withPublicIp(ipInfo) }
            
            loggingService.write(
                message: String(
                    format: Constants.logPublicIpHasBeenUpdated,
                    ipInfo.ipAddress),
                type: .info
            )
        }
        
        loggingService.write(
            message: String(
                format: Constants.logPublicIp,
                ipInfo.ipAddress,
                ipInfo.countryName,
                ipInfo.fetchedFromApi!
            ),
            type: .info
        )
    }
    
    private func enforceIpAllowlist() {
        guard
            !appState.current.isPublicIpAllowed,
            !appState.network.isFetchingIp,
            let publicIp = appState.network.publicIp
        else { return }
        
        let message = String(
            format: Constants.logPublicIpHasBeenUpdatedWithNotFromWhitelist,
            publicIp.ipAddress
        )
        
        disableActiveNetworkInterfaces()
        
        loggingService.write(
            message: message,
            type: .warning)
        
        if appState.userData.autoCloseApps {
            processService.killProcesses(
                processes: appState.system.killingProcesses)
        }
    }
    
    private func enforceIpApiAvailability() {
        guard
            appState.network.publicIp == nil,
            !appState.userData.hasActiveIpApi()
        else { return }
        
        disableActiveNetworkInterfaces()
        
        loggingService.write(
            message: Constants.errorNoActiveIpApiFound,
            type: .error)
    }
    
    private func shouldDisableConnection(
        for result: OperationResult<IpInfoBase>) -> Bool {
            isUnsafeUnderExtendedProtection(result) || hasNoActiveIpApi(result)
    }
    
    private func isUnsafeUnderExtendedProtection(
        _ result: OperationResult<IpInfoBase>) -> Bool {
        appState.userData.useExtendedProtection &&
        (appState.system.locationServicesEnabled
         || appState.network.hasDnsLeak
         || appState.network.hasWebRtcLeak
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
    
    private func updateStatusAsync(
        _ configure: (MonitoringStateUpdateBuilder) -> MonitoringStateUpdateBuilder
    ) async {
        guard !Task.isCancelled
        else { return }
        
        let update = configure(MonitoringStateUpdateBuilder())
            .build()
        
        await MainActor.run {
            appState.applyMonitoringUpdate(update)
        }
    }
}
