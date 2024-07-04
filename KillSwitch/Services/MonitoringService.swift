//
//  MonitoringService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation

class MonitoringService: ServiceBase, Settable {
    static let shared = MonitoringService()
    
    private let locationService = LocationService.shared
    private let addressesService = AddressesService.shared
    private let networkManagementService = NetworkManagementService.shared
    
    private var currentTimer: Timer? = nil
    
    override init() {
        super.init()
        
        if(appState.monitoring.isEnabled){
            startMonitoring()
        }
    }
    
    func startMonitoring() {
        writeSetting(newValue: true, key: Constants.settingsKeyIsMonitoringEnabled)
        
        let interval: Double = readSetting(key: Constants.settingsKeyIntervalBetweenChecks) ?? 10
        
        updateStatus(isMonitoringEnabled: true)
        
        Log.write(message: Constants.logMonitoringHasBeenEnabled)
        
        currentTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if self.appState.monitoring.isEnabled {
                Task {
                    do {
                        guard self.appState.network.status == .on else { return }
                        
                        let useHigherProtection = self.readSetting(key: Constants.settingsKeyHigherProtection) ?? false
                        let updatedIpAddress =  await self.getCurrentIpAddressAsync()
                        let locationServicesEnabled = self.locationService.isLocationServicesEnabled()
                        
                        if (locationServicesEnabled && useHigherProtection) {
                            self.networkManagementService.disableNetworkInterface(
                                interfaceName: Constants.primaryNetworkInterfaceName)
                        }
                        
                        if (updatedIpAddress == nil) {
                            if (useHigherProtection) {
                                self.networkManagementService.disableNetworkInterface(
                                    interfaceName: Constants.primaryNetworkInterfaceName)
                            }
                            
                            return
                        }
                        
                        if (updatedIpAddress! != self.appState.network.ipAddressInfo?.ipAddress ?? "Fix") {
                            Log.write(message: String(format: Constants.logCurrentIpHasBeenUpdated, updatedIpAddress!))
                        }
                            
                        self.performActionForUpdatedIpAddress(updatedIpAddress: updatedIpAddress!)
                    }
                }
            }
            else {
                timer.invalidate()
            }
        }
    }
    
    func stopMonitoring() {
        writeSetting(newValue: false, key: Constants.settingsKeyIsMonitoringEnabled)
        
        currentTimer?.invalidate()
        
        updateStatus(isMonitoringEnabled: false, currentSafetyType: AddressSafetyType.unknown)

        Log.write(message: Constants.logMonitoringHasBeenDisabled, type: LogEntryType.warning)
    }
    
    func restartMonitoring(){
        let isMonitoringEnabled: Bool = readSetting(key: Constants.settingsKeyIsMonitoringEnabled) ?? false
        
        if(isMonitoringEnabled){
            stopMonitoring()
            startMonitoring()
        }
    }
    
    func addAllowedIpAddress(
        ipAddress : String,
        ipAddressInfo: AddressInfoBase?,
        safetyType: AddressSafetyType) {
        let newIpAddress = AddressInfo(ipAddress: ipAddress, ipAddressInfo: ipAddressInfo, safetyType: safetyType)
            
        if !appState.userData.allowedIps.contains(newIpAddress) {
            appState.userData.allowedIps.append(newIpAddress)
        }
        else {
            if let currentAllowedIpAddressIndex = appState.userData.allowedIps.firstIndex(
                where: {$0.ipAddress == ipAddress && $0.safetyType != safetyType}) {
                appState.userData.allowedIps[currentAllowedIpAddressIndex] = newIpAddress
            }
        }
    }
    
    // MARK: Private functions
    
    private func getRandomActiveIpAddressApi() -> ApiInfo? {
        let result = self.addressesService.getRandomActiveAddressApi()
        
        if(result == nil){
            Log.write(message: Constants.logNoActiveAddressApiFound)
            
            if(self.appState.monitoring.isEnabled){
                updateStatus(isMonitoringEnabled: false, currentSafetyType: AddressSafetyType.unknown)
            }
        }
        
        return result
    }
    
    private func getCurrentIpAddressAsync() async -> String? {
        var result: String? = nil
        
        let api = getRandomActiveIpAddressApi()
        
        guard api != nil else { return result }
        
        result = await self.addressesService.getCurrentIpAddress(addressApiUrl: api!.url)
        
        return result
    }
    
    private func checkIfUpdatedIpAddressAllowed(updatedIpAddress: String) -> Bool {
        var result = false
        
        for allowedIpAddress in self.appState.userData.allowedIps {
            if (updatedIpAddress == allowedIpAddress.ipAddress) {
                updateStatus(currentSafetyType: allowedIpAddress.safetyType)
                result = true
            }
        }
        
        return result
    }
    
    private func performActionForUpdatedIpAddress(updatedIpAddress: String) {
        let isAllowed = checkIfUpdatedIpAddressAllowed(updatedIpAddress: updatedIpAddress)
        
        if(!isAllowed){
            updateStatus(currentSafetyType: AddressSafetyType.unknown)
            
            // TODO RUSS: It should be all active interfaces
            self.networkManagementService.disableNetworkInterface(
                interfaceName: Constants.primaryNetworkInterfaceName)
            
            Log.write(
                message: String(format: Constants.logCurrentIpHasBeenUpdatedWithNotFromWhitelist, updatedIpAddress),
                type: LogEntryType.warning)
        }
    }
    
    private func updateStatus(
        isMonitoringEnabled: Bool? = nil,
        currentSafetyType: AddressSafetyType? = nil) {
        DispatchQueue.main.async {
            self.appState.system.locationServicesEnabled = self.locationService.isLocationServicesEnabled()
            
            if(isMonitoringEnabled != nil) {
                self.appState.monitoring.isEnabled = isMonitoringEnabled!
            }
            
            if(currentSafetyType != nil) {
                self.appState.current.safetyType = currentSafetyType!
            }
            
            self.appState.objectWillChange.send()
        }
    }
}
