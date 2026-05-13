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
    @Injected(\.networkEnforcementService) private var networkEnforcementService
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
            
            await enableMonitoringAsync()
            
            while shouldContinueMonitoring() {
                await handleMonitoringCycleAsync()
            }
        }
    }
    
    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
        
        stopLeaksMonitoring()
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
    
    private func enableMonitoringAsync() async {
        loggingService.write(
            message: Constants.logMonitoringHasBeenEnabled,
            type: .success)
        
        await updateStatusAsync { $0.withIsMonitoringEnabled(true) }
        computerService.startSleepPreventing()
    }
    
    private func handleMonitoringCycleAsync() async {
        updateLeaksMonitoring()
        
        try? await Task.sleep(nanoseconds: Constants.defaultMonitoringIntervalNanoseconds)
        
        guard !Task.isCancelled
        else { return }
        
        monitoringTime = monitoringTime &+ Constants.defaultMonitoringInterval
        
        guard appState.network.status == .on
        else { return }
        
        await runPeriodicChecksAsync()
    }
    
    private func updateLeaksMonitoring() {
        if appState.network.isVpnConnected {
            startLeaksMonitoring()
        } else {
            stopLeaksMonitoring()
        }
    }
    
    private func startLeaksMonitoring() {
        dnsService.startMonitoring()
        webRtcService.startMonitoring()
    }
    
    private func stopLeaksMonitoring() {
        webRtcService.stopMonitoring()
        dnsService.stopMonitoring()
    }
    
    private func shouldContinueMonitoring() -> Bool {
        return !Task.isCancelled && appState.monitoring.isEnabled
    }
    
    private func runPeriodicChecksAsync() async {
        let checkIp = appState.userData.periodicIpCheck &&
        monitoringTime % appState.userData.intervalBetweenChecks == 0
        
        if checkIp {
            let result = await ipService.getPublicIpAsync(
                ipApiUrl: nil,
                withInfo: true)
            
            await handleUpdatedPublicIpResultAsync(result)
        }
        
        networkEnforcementService.enforceIpApiAvailability()
        networkEnforcementService.enforceIpAllowlist()
    }
        
    private func handleUpdatedPublicIpResultAsync(
        _ result: OperationResult<IpInfoBase>) async {
        guard !Task.isCancelled
        else { return }
        
        networkEnforcementService.enforce(for: result)
        
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
