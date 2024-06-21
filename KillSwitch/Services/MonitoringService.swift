//
//  MonitoringService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation

class MonitoringService: ObservableObject {
    @Published var isMonitoringEnabled = false
    @Published var currentSafetyType = AddressSafetyType.unknown
    @Published var allowedIpAddresses = [AddressInfo]()
    
    static let shared = MonitoringService()
    
    private let networkStatusService = NetworkStatusService.shared
    private let addressesService = AddressesService.shared
    private let networkManagementService = NetworkManagementService.shared
    private let loggingService = LoggingService.shared
    private let appManagementService = AppManagementService.shared
    
    private var currentTimer: Timer? = nil
    
    init() {
        let isMonitoringEnabled: Bool = appManagementService.readSetting(key: Constants.settingsKeyIsMonitoringEnabled) ?? false
        let savedAllowedIpAddresses: [AddressInfo]? = appManagementService.readSettingsArray(key: Constants.settingsKeyAddresses)
        
        if(savedAllowedIpAddresses != nil){
            self.allowedIpAddresses = savedAllowedIpAddresses!
        }
        
        if(isMonitoringEnabled){
            startMonitoring()
        }
    }
    
    func startMonitoring() {
        appManagementService.writeSetting(newValue: true, key: Constants.settingsKeyIsMonitoringEnabled)
        let interval: Double = appManagementService.readSetting(key: Constants.settingsIntervalBetweenChecks) ?? 10
        
        isMonitoringEnabled = true
        
        loggingService.log(message: Constants.logMonitoringHasBeenEnabled)
        
        currentTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if self.isMonitoringEnabled {
                Task {
                    do {                        
                        guard self.networkStatusService.currentStatusNonPublished == .on else { return }
                        
                        let updatedIpAddress = await self.getCurrentIpAddressAsync()
                        
                        guard updatedIpAddress != nil else { return }
                        
                        if (updatedIpAddress! != self.networkStatusService.currentIpAddressNonPublished) {
                            self.loggingService.log(message: String(format: Constants.logCurrentIpHasBeenUpdated, updatedIpAddress!))
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
        appManagementService.writeSetting(newValue: false, key: Constants.settingsKeyIsMonitoringEnabled)
        
        currentTimer?.invalidate()
        currentSafetyType = AddressSafetyType.unknown
        
        isMonitoringEnabled = false

        loggingService.log(message: Constants.logMonitoringHasBeenDisabled, type: LogEntryType.warning)
    }
    
    func restartMonitoring(){
        let isMonitoringEnabled: Bool = appManagementService.readSetting(key: Constants.settingsKeyIsMonitoringEnabled) ?? false
        
        if(isMonitoringEnabled){
            stopMonitoring()
            startMonitoring()
        }
    }
    
    func addAllowedIpAddress(
        ipAddress : String,
        ipAddressInfo: AddressInfoBase?,
        safetyType: AddressSafetyType) {
        let newIpAddress = AddressInfo(
            ipVersion: ipAddressInfo!.ipVersion,
            ipAddress: ipAddress,
            countryName: ipAddressInfo!.countryName,
            countryCode: ipAddressInfo!.countryCode,
            safetyType: safetyType)
            
        if !allowedIpAddresses.contains(newIpAddress) {
            allowedIpAddresses.append(newIpAddress)
        }
        else {
            if let currentAllowedIpAddressIndex = allowedIpAddresses.firstIndex(
                where: {$0.ipAddress == ipAddress && $0.safetyType != safetyType}) {
                allowedIpAddresses[currentAllowedIpAddressIndex] = newIpAddress
            }
        }
    }
    
    // MARK: Private functions
    
    private func getRandomActiveIpAddressApi() -> ApiInfo? {
        let result = self.addressesService.getRandomActiveAddressApi()
        
        if(result == nil){
            self.loggingService.log(message: Constants.logNoActiveAddressApiFound)
            
            if(self.isMonitoringEnabled){
                DispatchQueue.main.async {
                    self.isMonitoringEnabled = false
                    self.currentSafetyType = AddressSafetyType.unknown
                }
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
        
        for allowedIpAddress in self.allowedIpAddresses {
            if updatedIpAddress == allowedIpAddress.ipAddress {
                result = true
                
                DispatchQueue.main.async {
                    self.currentSafetyType = allowedIpAddress.safetyType
                }
            }
        }
        
        return result
    }
    
    private func performActionForUpdatedIpAddress(updatedIpAddress: String) {
        
        let isAllowed = checkIfUpdatedIpAddressAllowed(updatedIpAddress: updatedIpAddress)
        
        if(!isAllowed){
            DispatchQueue.main.async {
                self.currentSafetyType = AddressSafetyType.unknown
            }
            
            // TODO RUSS: It should be all active interfaces
            self.networkManagementService.disableNetworkInterface(
                interfaceName: Constants.primaryNetworkInterfaceName)
            
            self.loggingService.log(
                message: String(format: Constants.logCurrentIpHasBeenUpdatedWithNotFromWhitelist, updatedIpAddress),
                type: LogEntryType.warning)
        }
    }
}
