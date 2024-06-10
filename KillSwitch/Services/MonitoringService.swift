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
    
    static let shared = MonitoringService()
    
    private let networkStatusService = NetworkStatusService.shared
    private let networkManagementService = NetworkManagementService.shared
    private let loggingService = LoggingService.shared
    
    var allowedIpAddresses = [String]()
    
    private init() {
    }
    
    func startMonitoring() {
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
                            if updatedIpAddress == allowedIpAddress {
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
        isMonitoringEnabled = false
        
        let logEntry = LogEntry(message: "Monitoring has been disabled.")
        loggingService.log(logEntry: logEntry)
    }
}
