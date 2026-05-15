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
        let isMonitoringEnabled = MainActor.assumeIsolated {
            appState.monitoring.isEnabled
        }
        
        if isMonitoringEnabled {
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
            
            while await shouldContinueMonitoringAsync() {
                await handleMonitoringCycleAsync()
            }
        }
    }
    
    func stopMonitoringAsync() async {
        monitoringTask?.cancel()
        monitoringTask = nil
        
        await stopLeaksMonitoringAsync()
        computerService.stopSleepPreventing()
        
        loggingService.write(
            message: Constants.logMonitoringHasBeenDisabled,
            type: .success)
        
        await updateStatusAsync {
            $0.withIsMonitoringEnabled(false)
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
        let networkStatus = await MainActor.run { appState.network.status }
        let isVpnConnected = await MainActor.run { appState.network.isVpnConnected }
        
        await updateLeaksMonitoringAsync(isVpnConnected: isVpnConnected)
        
        try? await Task.sleep(nanoseconds: Constants.defaultMonitoringIntervalNanoseconds)
        
        guard !Task.isCancelled
        else { return }
        
        monitoringTime = monitoringTime &+ Constants.defaultMonitoringInterval
        
        guard networkStatus == .on
        else { return }
        
        await runPeriodicChecksAsync()
    }
    
    private func updateLeaksMonitoringAsync(isVpnConnected: Bool) async {
        if isVpnConnected {
            await startLeaksMonitoringAsync()
        } else {
            await stopLeaksMonitoringAsync()
        }
    }
    
    private func startLeaksMonitoringAsync() async {
        await dnsService.startMonitoringAsync()
        await webRtcService.startMonitoringAsync()
    }
    
    private func stopLeaksMonitoringAsync() async {
        await webRtcService.stopMonitoringAsync()
        await dnsService.stopMonitoringAsync()
    }
    
    private func shouldContinueMonitoringAsync() async -> Bool {
        await MainActor.run {
            !Task.isCancelled && appState.monitoring.isEnabled
        }
    }
    
    private func runPeriodicChecksAsync() async {
        let checkIp = await MainActor.run {
            appState.userData.periodicIpCheck &&
            monitoringTime % appState.userData.intervalBetweenChecks == 0
        }
        
        if checkIp {
            let result = await ipService.getPublicIpAsync(
                ipApiUrl: nil,
                withInfo: true)
            
            await handleUpdatedPublicIpResultAsync(result)
        }
        
        await networkEnforcementService.enforceIpApiAvailabilityAsync()
        await networkEnforcementService.enforceIpAllowlistAsync()
    }
        
    private func handleUpdatedPublicIpResultAsync(
        _ result: OperationResult<IpInfoBase>) async {
        guard !Task.isCancelled
        else { return }
        
        await networkEnforcementService.enforceAsync(for: result)
        
        guard let ipInfo = result.result
        else {
            loggingService.write(
                message: result.error!,
                type: .error
            )
            
            return
        }
            
        let currentPublicIp = await MainActor.run {
            appState.network.publicIp?.ipAddress
        }
        
        if ipInfo.ipAddress != currentPublicIp {
            await updateStatusAsync { $0.withPublicIp(ipInfo) }
            
            loggingService.write(
                message: String(
                    format: Constants.logPublicIpUpdated,
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
