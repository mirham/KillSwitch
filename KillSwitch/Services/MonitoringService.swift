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
    @Published var allowedIpAddresses = [IpAddressInfo]()
    
    static let shared = MonitoringService()
    
    private let networkStatusService = NetworkStatusService.shared
    private let networkManagementService = NetworkManagementService.shared
    private let loggingService = LoggingService.shared
    
    // var allowedIpAddresses = [IpAddressInfo]()
    
    private init() {
        let isMonitoringEnabled = UserDefaults.standard.bool(forKey: "isMonitoringEnabled")
        let allowedIpAddresses = getAllObjects()
        
        if(allowedIpAddresses != nil){
            self.allowedIpAddresses = allowedIpAddresses!
        }
        
        if(isMonitoringEnabled){
            startMonitoring()
        }
    }
    
    func startMonitoring() {
        UserDefaults.standard.set(true, forKey: "isMonitoringEnabled")
        
        isMonitoringEnabled = true
        
        let logEntry = LogEntry(message: "Monitoring has been enabled.")
        loggingService.log(logEntry: logEntry)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            if self.isMonitoringEnabled {
                Task {
                    do {
                        guard self.networkStatusService.status == .on else {
                            return
                        }
                        
                        let updatedIpAddress = await self.networkStatusService.getCurrentIpAddress() ?? String()
                        
                        if (updatedIpAddress != self.networkStatusService.ip) {
                            let logEntry = LogEntry(message: "IP has been updated to \(updatedIpAddress)")
                            self.loggingService.log(logEntry: logEntry)
                        }
                            
                        var isMatchFound = false
                            
                        for allowedIpAddress in self.allowedIpAddresses {
                            if updatedIpAddress == allowedIpAddress.ipAddress {
                                isMatchFound = true
                            }
                        }
                            
                        if !isMatchFound {
                            self.networkManagementService.disableNetworkInterface(interfaceName: "en0")
                            
                            // self.networkStatusService.status = .off
                                
                            let logEntry = LogEntry(message: "IP address has been changed to \(updatedIpAddress) which is not from allowd IPs, network disabled.")
                            self.loggingService.log(logEntry: logEntry)
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
        saveAllObjects(allObjects: self.allowedIpAddresses)
        UserDefaults.standard.set(false, forKey: "isMonitoringEnabled")
        
        isMonitoringEnabled = false
        
        let logEntry = LogEntry(message: "Monitoring has been disabled.")
        loggingService.log(logEntry: logEntry)
    }
    
    func getAllObjects() -> [IpAddressInfo]? {
        if let objects = UserDefaults.standard.value(forKey: "user_objects") as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [IpAddressInfo] {
                return objectsDecoded
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func saveAllObjects(allObjects: [IpAddressInfo]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(allObjects){
            UserDefaults.standard.set(encoded, forKey: "user_objects")
        }
    }
}
