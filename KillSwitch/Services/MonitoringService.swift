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
    private let networkManagementService = NetworkManagementService.shared
    
    private var currentTimer: Timer? = nil
    
    override init() {
        super.init()
        
        if(appState.monitoring.isEnabled){
            startMonitoring()
        }
    }
    
    func startMonitoring() {
        updateStatus(isMonitoringEnabled: true)
        
        Log.write(message: Constants.logMonitoringHasBeenEnabled)
        
        currentTimer = Timer.scheduledTimer(withTimeInterval: appState.userData.intervalBetweenChecks, repeats: true) { timer in
            if self.appState.monitoring.isEnabled {
                Task {
                    do {
                        guard self.appState.network.status == .on else { return }
                        
                        let updatedIpAddressResult =  await self.addressesService.getCurrentIpAsync()
                        
                        self.handleUpdatedIpAddressResult(updatedIpAddressResult: updatedIpAddressResult)
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
    
    func restartMonitoring(){
        if(appState.monitoring.isEnabled){
            stopMonitoring()
            startMonitoring()
        }
    }
    
    // MARK: Private functions
    
    private func handleUpdatedIpAddressResult(updatedIpAddressResult : OperationResult<IpInfoBase>) {
        if (updatedIpAddressResult.error == Constants.errorNoActiveAddressApiFound) {
            updateStatus(isMonitoringEnabled: false)
            Log.write(message: updatedIpAddressResult.error!, type: .error)
        }
        
        if (isUnsafeForHigherProtection(updatedIpAddressResult: updatedIpAddressResult)) {
            networkManagementService.disableNetworkInterface(interfaceName: Constants.primaryNetworkInterfaceName)
        }
        
        guard updatedIpAddressResult.result != nil else { return }
        
        if (updatedIpAddressResult.result!.ipAddress != appState.network.currentIpInfo?.ipAddress) {
            updateStatus(currentIpInfo: updatedIpAddressResult.result)
            Log.write(message: String(format: Constants.logCurrentIpHasBeenUpdated, updatedIpAddressResult.result!.ipAddress))
        }
        
        Log.write(message: String(format: Constants.logCurrentIp, updatedIpAddressResult.result!.ipAddress))
        
        if(!appState.current.isCurrentIpAllowed) {
            networkManagementService.disableNetworkInterface(interfaceName: Constants.primaryNetworkInterfaceName)
            Log.write(
                message: String(format: Constants.logCurrentIpHasBeenUpdatedWithNotFromWhitelist, appState.network.currentIpInfo!.ipAddress),
                type: LogEntryType.warning)
        }
    }
    
    private func isUnsafeForHigherProtection(updatedIpAddressResult: OperationResult<IpInfoBase>) -> Bool {
        let result = appState.userData.useHigherProtection
                        && (appState.system.locationServicesEnabled
                            || updatedIpAddressResult.result == nil)
        
        return result
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
