//
//  MonitoringService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation

class MonitoringService: ServiceBase {
    static let shared = MonitoringService()
    
    private let addressesService = IpService.shared
    private let networkService = NetworkService.shared
    
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
        
        Log.write(message: Constants.logMonitoringHasBeenEnabled)
        
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
                            let updatedIpAddressResult =  await self.addressesService.getCurrentIpAsync()
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
        Log.write(message: Constants.logMonitoringHasBeenDisabled, type: LogEntryType.warning)
    }
    
    // MARK: Private functions
    
    private func handleUpdatedIpAddressResult(updatedIpAddressResult : OperationResult<IpInfoBase>) {
        if (isUnsafeForHigherProtection(updatedIpAddressResult: updatedIpAddressResult)
            || noActiveIpApiFound(updatedIpAddressResult: updatedIpAddressResult)) {
            disableActiveNetworkInterfaces()
        }
        
        guard updatedIpAddressResult.result != nil else {
            Log.write(message: updatedIpAddressResult.error ?? String(), type: .error)
            return
        }
        
        if (updatedIpAddressResult.result!.ipAddress != appState.network.currentIpInfo?.ipAddress) {
            updateStatus(currentIpInfo: updatedIpAddressResult.result)
            Log.write(message: String(format: Constants.logCurrentIpHasBeenUpdated, updatedIpAddressResult.result!.ipAddress))
        }
        
        Log.write(message: String(format: Constants.logCurrentIp, updatedIpAddressResult.result!.ipAddress))
    }
    
    private func checkIfCurrentIpIsAllowed() {
        if (!appState.current.isCurrentIpAllowed && !appState.network.obtainingIp && appState.network.currentIpInfo != nil) {
            let message = String(
                format: Constants.logCurrentIpHasBeenUpdatedWithNotFromWhitelist,
                appState.network.currentIpInfo!.ipAddress)
            
            disableActiveNetworkInterfaces()
            
            Log.write(message: message, type: LogEntryType.warning)
        }
    }
    
    private func checkPossibilityOfObtaininigIp() {
        if (appState.network.currentIpInfo == nil && appState.userData.ipApis.allSatisfy({!$0.isActive()})) {
            let message = String(Constants.errorNoActiveIpApiFound)
            
            disableActiveNetworkInterfaces()
            
            Log.write(message: message, type: LogEntryType.error)
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
        for activeInterface in appState.network.physicalNetworkInterfaces {
            networkService.disableNetworkInterface(interfaceName: activeInterface.name)
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
