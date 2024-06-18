//
//  NetworkManagementService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import Network
import Combine

class NetworkManagementService{
    static let shared = NetworkManagementService()
    
    private let shellService = ShellService.shared
    private let loggingServie = LoggingService.shared
    
    func enableNetworkInterface(interfaceName: String){
        do {
            try shellService.safeShell("networksetup -setairportpower \(interfaceName) on")
            
            let logEntry = LogEntry(message: "Network interface \(interfaceName) has been enabled.")
            loggingServie.log(logEntry: logEntry)
        }
        catch {
            let logEntry = LogEntry(message: "Cannot enable network interface \(interfaceName).")
            loggingServie.log(logEntry: logEntry)
        }
    }
    
    func disableNetworkInterface(interfaceName: String) {
        do {
            try shellService.safeShell("networksetup -setairportpower \(interfaceName) off")
            
            let logEntry = LogEntry(message: "Network interface \(interfaceName) has been disabled.")
            loggingServie.log(logEntry: logEntry)
        }
        catch {
            let logEntry = LogEntry(message: "Cannot disable network interface \(interfaceName).")
            loggingServie.log(logEntry: logEntry)
        }
    }
}
