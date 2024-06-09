//
//  MonitoringService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation
import SwiftData


class MonitoringService: ObservableObject {
    @Published var isMonitoringEnabled = false
    
    static let shared = MonitoringService()
    
    private let networkStatusService = NetworkStatusService.shared
    private let networkManagementService = NetworkManagementService.shared
    private let loggingService = LoggingService.shared
    
    var allowedIpAddresses = [String]()
    
    private var currentIpAddress = String()
    private var currentNetworkStatus = NetworkStatusType.unknown
    
    private init() {
        currentIpAddress = networkStatusService.currentIpAddress
    }
    
    func startMonitoring() -> Bool {
        isMonitoringEnabled = true
        
        let logEntry = LogEntry(message: "Monitoring has been enabled.")
        loggingService.log(logEntry: logEntry)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            if self.isMonitoringEnabled {
                Task {
                    do {
                        self.networkStatusService.$currentStatus.sink(receiveValue: {
                            self.currentNetworkStatus = $0})
                        
                        guard self.currentNetworkStatus == .on else {
                            return
                        }
                        
                        let newIpAddress = await self.networkStatusService.getCurrentIpAddress() ?? String()
                        
                        if (newIpAddress != self.currentIpAddress) {
                            let logEntry = LogEntry(message: "IP has been updated to \(newIpAddress)")
                            self.loggingService.log(logEntry: logEntry)
                            
                            var isMatchFound = false
                            
                            for allowedIpAddress in self.allowedIpAddresses {
                                if newIpAddress == allowedIpAddress {
                                    isMatchFound = true
                                }
                            }
                            
                            if isMatchFound {
                                self.currentIpAddress = newIpAddress
                            }
                            else {
                                self.networkManagementService.disableNetworkInterface(interfaceName: "en0")
                                
                                let logEntry = LogEntry(message: "IP address has been changed to \(newIpAddress) which is not from allowd IPs, network disabled.")
                                self.loggingService.log(logEntry: logEntry)
                            }
                        }
                    }
                }
            }
            else {
                timer.invalidate()
            }
        }
        
        return true
    }
    
    func stopMonitoring() -> Bool {
        isMonitoringEnabled = false
        
        let logEntry = LogEntry(message: "Monitoring has been disabled.")
        loggingService.log(logEntry: logEntry)
        
        return true
    }
}
