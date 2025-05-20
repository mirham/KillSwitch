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
    
    private var currentTimer: Timer? = nil
    private var monitoringTime: Int = 0
    
    override init() {
        super.init()
        
        if(appState.monitoring.isEnabled){
            startMonitoring()
        }
    }
    
    func startMonitoring() {
        updateStatus(isMonitoringEnabled: true)
        
        monitoringTime = 0
        
        loggingService.write(
            message: Constants.logMonitoringHasBeenEnabled,
            type: .info)
        
        computerService.startSleepPreventing()
        
        currentTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(Constants.defaultMonitoringInterval), repeats: true) { 
            timer in
            if self.appState.monitoring.isEnabled {
                Task {
                    do {
                        self.monitoringTime += Constants.defaultMonitoringInterval
                        
                        guard self.appState.network.status == .on else { return }
                        
                        let ipCheckNeeded = self.appState.userData.periodicIpCheck
                        && self.monitoringTime % self.appState.userData.intervalBetweenChecks == 0
                        
                        if (ipCheckNeeded) {
                            let updatedIpAddressResult =  await self.ipService.getCurrentIpAsync(ipApiUrl: nil, withInfo: true)
                            self.handleUpdatedIpAddressResult(updatedIpAddressResult: updatedIpAddressResult)
                        }
                        
                        self.checkIfCurrentIpIsAllowed()
                        self.checkPossibilityOfObtaininigIp()
                    }
                }
            }
            else {
                timer.invalidate()
            }
        }
    }
    
    func stopMonitoring() {
        updateStatus(isMonitoringEnabled: false)
        currentTimer?.invalidate()
        
        computerService.stopSleepPreventing()
        
        loggingService.write(message: Constants.logMonitoringHasBeenDisabled, type: LogEntryType.warning)
    }
    
    // MARK: Private functions
    
    private func handleUpdatedIpAddressResult(
        updatedIpAddressResult : OperationResult<IpInfoBase>) {
        if (isUnsafeForHigherProtection(updatedIpAddressResult: updatedIpAddressResult)
            || noActiveIpApiFound(updatedIpAddressResult: updatedIpAddressResult)) {
            disableActiveNetworkInterfaces()
        }
        
        guard updatedIpAddressResult.result != nil else {
            loggingService.write(
                message: updatedIpAddressResult.error ?? String(),
                type: .error)
            
            return
        }
        
        if (updatedIpAddressResult.result!.ipAddress != appState.network.currentIpInfo?.ipAddress) {
            updateStatus(currentIpInfo: updatedIpAddressResult.result)
            loggingService.write(
                message: String(format: Constants.logCurrentIpHasBeenUpdated, updatedIpAddressResult.result!.ipAddress),
                type: .info)
        }
        
        loggingService.write(
            message: String(format: Constants.logCurrentIp, updatedIpAddressResult.result!.ipAddress),
            type: .info)
    }
    
    private func checkIfCurrentIpIsAllowed() {
        if (!appState.current.isCurrentIpAllowed && !appState.network.obtainingIp && appState.network.currentIpInfo != nil) {
            let message = String(
                format: Constants.logCurrentIpHasBeenUpdatedWithNotFromWhitelist,
                appState.network.currentIpInfo!.ipAddress)
            
            disableActiveNetworkInterfaces()
            
            loggingService.write(
                message: message,
                type: LogEntryType.warning)
            
            if (appState.userData.autoCloseApps) {
                processService.killActiveProcesses()
            }
        }
    }
    
    private func checkPossibilityOfObtaininigIp() {
        if (appState.network.currentIpInfo == nil && appState.userData.ipApis.allSatisfy({!$0.isActive()})) {
            let message = String(Constants.errorNoActiveIpApiFound)
            
            disableActiveNetworkInterfaces()
            
            loggingService.write(
                message: message,
                type: LogEntryType.error)
        }
    }
    
    private func isUnsafeForHigherProtection(updatedIpAddressResult: OperationResult<IpInfoBase>) -> Bool {
        let result = appState.userData.useHigherProtection
                     && (appState.system.locationServicesEnabled 
                         || updatedIpAddressResult.result == nil)
        
        return result
    }
    
    private func noActiveIpApiFound(updatedIpAddressResult: OperationResult<IpInfoBase>) -> Bool {
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
    
    private func updateStatus(
        isMonitoringEnabled: Bool? = nil,
        currentIpInfo: IpInfoBase? = nil) {
        DispatchQueue.main.async {
            if (isMonitoringEnabled != nil) {
                self.appState.monitoring.isEnabled = isMonitoringEnabled!
            }
            
            if (currentIpInfo != nil) {
                self.appState.network.currentIpInfo = currentIpInfo
            }
            
            self.appState.objectWillChange.send()
        }
    }
}
