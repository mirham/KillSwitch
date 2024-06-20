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
    @Published var allowedIpAddresses = [AddressInfo]()
    
    static let shared = MonitoringService()
    
    private let networkStatusService = NetworkStatusService.shared
    private let addressesService = AddressesService.shared
    private let networkManagementService = NetworkManagementService.shared
    private let loggingService = LoggingService.shared
    private let appManagementService = AppManagementService.shared
    
    init() {
        let isMonitoringEnabled = UserDefaults.standard.bool(forKey: "isMonitoringEnabled")
        let savedAllowedIpAddresses: [AddressInfo]? = appManagementService.readSettingsArray(key: Constants.settingsKeyAddresses)
        
        if(savedAllowedIpAddresses != nil){
            self.allowedIpAddresses = savedAllowedIpAddresses!
        }
        
        if(isMonitoringEnabled){
            startMonitoring()
        }
    }
    
    deinit{
        appManagementService.writeSettingsArray(
         allObjects: allowedIpAddresses,
         key: Constants.settingsKeyAddresses)
    }
    
    func startMonitoring() {
        UserDefaults.standard.set(true, forKey: "isMonitoringEnabled")
        
        isMonitoringEnabled = true
        
        loggingService.log(message: Constants.logMonitoringHasBeenEnabled)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            if self.isMonitoringEnabled {
                Task {
                    do {
                        guard self.networkStatusService.status == .on else {
                            return
                        }
                        
                        let api = self.addressesService.getRandomActiveAddressApi()
                        
                        if(api == nil){
                            self.loggingService.log(message: Constants.logNoActiveAddressApiFound)
                            
                            if(self.isMonitoringEnabled){
                                self.isMonitoringEnabled = false
                            }
                        }
                        
                        let updatedIpAddress = await self.addressesService.getCurrentIpAddress(addressApiUrl: api!.url) ?? String()
                        
                        if (updatedIpAddress != self.networkStatusService.ip) {
                            self.loggingService.log(message: String(format: Constants.logCurrentIpHasBeenUpdated, updatedIpAddress))
                        }
                            
                        var isMatchFound = false
                            
                        for allowedIpAddress in self.allowedIpAddresses {
                            if updatedIpAddress == allowedIpAddress.ipAddress {
                                isMatchFound = true
                            }
                        }
                            
                        if !isMatchFound {
                            // TODO RUSS: It should be all active interfaces
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
        UserDefaults.standard.set(false, forKey: "isMonitoringEnabled")
        
        isMonitoringEnabled = false

        loggingService.log(message: Constants.logMonitoringHasBeenDisabled, type: LogEntryType.warning)
    }
}
