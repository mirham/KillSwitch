//
//  MonitoringService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation
import SwiftData
import Combine

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
                        guard self.networkStatusService.currentStatusNonPublished == .on else {
                            return
                        }
                        
                        let api = self.addressesService.getRandomActiveAddressApi()
                        
                        if(api == nil){
                            self.loggingService.log(message: Constants.logNoActiveAddressApiFound)
                            
                            if(self.isMonitoringEnabled){
                                DispatchQueue.main.async {
                                    self.isMonitoringEnabled = false
                                    self.currentSafetyType = AddressSafetyType.unknown
                                }
                            }
                        }
                        
                        let updatedIpAddress = await self.addressesService.getCurrentIpAddress(addressApiUrl: api!.url) ?? String()
                        
                        if (updatedIpAddress != self.networkStatusService.currentIpAddressNonPublished) {
                            self.loggingService.log(message: String(format: Constants.logCurrentIpHasBeenUpdated, updatedIpAddress))
                        }
                            
                        var isMatchFound = false
                            
                        for allowedIpAddress in self.allowedIpAddresses {
                            if updatedIpAddress == allowedIpAddress.ipAddress {
                                isMatchFound = true
                                
                                DispatchQueue.main.async {
                                    self.currentSafetyType = allowedIpAddress.safetyType
                                }
                            }
                        }
                            
                        if !isMatchFound {
                            // TODO RUSS: It should be all active interfaces
                            DispatchQueue.main.async {
                                self.currentSafetyType = AddressSafetyType.unknown
                            }
                            
                            self.networkManagementService.disableNetworkInterface(interfaceName: "en0")
                            
                            self.loggingService.log(
                                message: String(format: Constants.logCurrentIpHasBeenUpdatedWithNotFromWhitelist, updatedIpAddress),
                                type: LogEntryType.warning)
                        }
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
}
