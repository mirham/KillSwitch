//
//  MonitoringService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation
import Factory

class MonitoringService: ServiceBase, MonitoringServiceType {
    @Injected(\.ipService) private var ipService
    @Injected(\.networkService) private var networkService
    @Injected(\.processService) private var processService
    @Injected(\.computerService) private var computerService
    
    private var monitoringTime: Int = 0
    private var monitoringTask: Task<Void, Never>?
    
    override init() {
        super.init()
        
        if(appState.monitoring.isEnabled){
            startMonitoring()
        }
    }
    
    deinit {
        monitoringTask?.cancel()
    }
    
    func startMonitoring() {
        monitoringTime = 0
        
        loggingService.write(
            message: Constants.logMonitoringHasBeenEnabled,
            type: .info)
        
        computerService.startSleepPreventing()
        
        monitoringTask = Task {
            await updateStatusAsync(update: MonitoringStateUpdateBuilder()
                .withIsMonitoringEnabled(true)
                .build())
            
            while !Task.isCancelled && self.appState.monitoring.isEnabled {
                try? await Task.sleep(nanoseconds:Constants.defaultMonitoringIntervalNanoseconds)
                
                self.monitoringTime += Constants.defaultMonitoringInterval
                
                guard self.appState.network.status == .on else { continue }
                
                let isIpCheckRequired = self.appState.userData.periodicIpCheck &&
                    self.monitoringTime % self.appState.userData.intervalBetweenChecks == 0
                
                if isIpCheckRequired {
                    let updatedIpAddressResult =  await self.ipService.getPublicIpAsync(ipApiUrl: nil, withInfo: true)
                    await self.handleUpdatedPublicIpResultAsync(updatedPublicIpResult: updatedIpAddressResult)
                }

                self.isPublicIpObtainable()
                self.isPublicIpAllowed()
            }
        }
    }
    
    func stopMonitoring() {
        Task {
            await updateStatusAsync(update: MonitoringStateUpdateBuilder()
                .withIsMonitoringEnabled(false)
                .build())
        }
        
        monitoringTask?.cancel()
        computerService.stopSleepPreventing()
        
        loggingService.write(
            message: Constants.logMonitoringHasBeenDisabled,
            type: LogEntryType.warning)
    }
    
    // MARK: Private functions
    
    private func handleUpdatedPublicIpResultAsync (
        updatedPublicIpResult : OperationResult<IpInfoBase>) async {
        let isConnectionMustBeDisabled =
            self.isUnsafeForHigherProtection(updatedIpAddressResult: updatedPublicIpResult) ||
            self.noActiveIpApiFound(updatedIpAddressResult: updatedPublicIpResult)
            
        if (isConnectionMustBeDisabled) {
            self.disableActiveNetworkInterfaces()
        }
        
        guard updatedPublicIpResult.result != nil else {
            self.loggingService.write(
                message: updatedPublicIpResult.error ?? String(),
                type: .error)
            
            return
        }
        
        if (updatedPublicIpResult.result!.ipAddress != appState.network.publicIp?.ipAddress) {
            await updateStatusAsync(update: MonitoringStateUpdateBuilder()
                .withPublicIp(updatedPublicIpResult.result)
                .build())
            
            self.loggingService.write(
                message: String(format: Constants.logPublicIpHasBeenUpdated, updatedPublicIpResult.result!.ipAddress),
                type: .info)
        }
        
        self.loggingService.write(
            message: String(
                format: Constants.logPublicIp,
                updatedPublicIpResult.result!.ipAddress,
                updatedPublicIpResult.result!.countryName),
            type: .info)
    }
    
    private func isPublicIpAllowed() {
        let isNotAllowedIp = !appState.current.isPublicIpAllowed &&
            !appState.network.isObtainingIp &&
            appState.network.publicIp != nil
        
        if isNotAllowedIp {
            let message = String(
                format: Constants.logPublicIpHasBeenUpdatedWithNotFromWhitelist,
                appState.network.publicIp!.ipAddress)
            
            disableActiveNetworkInterfaces()
            
            loggingService.write(
                message: message,
                type: LogEntryType.warning)
            
            if (appState.userData.autoCloseApps) {
                processService.killActiveProcesses()
            }
        }
    }
    
    private func isPublicIpObtainable() {
        let isNoActiveApis = appState.network.publicIp == nil
            && !appState.userData.activeIpApisExist()
        
        if (isNoActiveApis) {
            let message = String(Constants.errorNoActiveIpApiFound)
            
            disableActiveNetworkInterfaces()
            
            loggingService.write(
                message: message,
                type: LogEntryType.error)
        }
    }
    
    private func isUnsafeForHigherProtection (
        updatedIpAddressResult: OperationResult<IpInfoBase>) -> Bool {
        let result = appState.userData.useHigherProtection
                     && (appState.system.locationServicesEnabled 
                         || updatedIpAddressResult.result == nil)
        
        return result
    }
    
    private func noActiveIpApiFound (
        updatedIpAddressResult: OperationResult<IpInfoBase>) -> Bool {
        let result = updatedIpAddressResult.error != nil
                     && updatedIpAddressResult.error == Constants.errorNoActiveIpApiFound
        
        return result
    }
    
    private func disableActiveNetworkInterfaces() {
        if (appState.network.status != .off) {
            for activeInterface in appState.network.physicalNetworkInterfaces {
                networkService.disableNetworkInterface(interfaceName: activeInterface.name)
            }
        }
    }
    
    private func updateStatusAsync(update: MonitoringStateUpdate) async {
        await MainActor.run {
            appState.applyMonitoringUpdate(update)
            appState.objectWillChange.send()
        }
    }
}
