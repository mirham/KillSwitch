//
//  MonitoringService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation
import SwiftData


class MonitoringService: ObservableObject {
    @Published var currentIpAddress = String()
    @Published var isMonitoringEnabled = false
    
    static let shared = MonitoringService()
    
    let networkStatusService = NetworkStatusService.shared
    
    private let ipAddressesService = IpAddressesService.shared
    private let networkManagementService = NetworkManagementService.shared
    private let loggingService = LoggingService.shared
    
    var allowedIpAddresses = [String]()
    
    private var previousIpAddress = String()
    private var lastAttempt = Date()
    
    private init() {
        setCurrentIpAddress()
    }
    
    func startMonitoring() -> Bool {
        isMonitoringEnabled = true
        
        let logEntry = LogEntry(message: "Monitoring has been enabled.")
        loggingService.log(logEntry: logEntry)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            if self.isMonitoringEnabled {
                Task {
                    do {
                        guard self.networkStatusService.currentStatus == .on else {
                            self.currentIpAddress = "None".uppercased()
                            return
                        }
                        
                        let ipAddress = await self.ipAddressesService.getCurrentIpAddress()
                        
                        if (ipAddress == nil) {
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from:  self.lastAttempt, to: Date())
                            let seconds = components.second
                            
                            if(seconds! > 60){
                                self.lastAttempt = Date()
                            }
                            else{
                                return
                            }
                        }
                        
                        self.currentIpAddress = ipAddress!
                        
                        if (self.currentIpAddress != self.previousIpAddress) {
                            let logEntry = LogEntry(message: "Updated IP:" + self.currentIpAddress)
                            self.loggingService.log(logEntry: logEntry)
                            
                            var isMatchFound = false
                            
                            for allowedIpAddress in self.allowedIpAddresses {
                                if self.currentIpAddress == allowedIpAddress {
                                    isMatchFound = true
                                }
                            }
                            
                            if isMatchFound {
                                self.previousIpAddress = self.currentIpAddress
                            }
                            else {
                                self.networkManagementService.disableNetworkInterface(interfaceName: "en0")
                                
                                if(self.networkStatusService.currentStatus == .off){
                                    let logEntry = LogEntry(message: "IP address changed to \(self.currentIpAddress) which is not from allowd IPs, network disabled.")
                                    self.loggingService.log(logEntry: logEntry)
                                }
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
    
    func resetMonitoring() {
        if isMonitoringEnabled {
            stopMonitoring()
            setCurrentIpAddress()
            startMonitoring()
        }
        else {
            setCurrentIpAddress()
        }
    }
    
    func resetCurrentIpAddress() {
        currentIpAddress = "None".uppercased()
    }
    
    private func setCurrentIpAddress() {
        Task {
            do {
                currentIpAddress = await ipAddressesService.getCurrentIpAddress() ?? String()
                previousIpAddress = currentIpAddress
                
                let logEntry = LogEntry(message: "Initial IP:" + currentIpAddress)
                loggingService.log(logEntry: logEntry)
            }
        }
    }
}
