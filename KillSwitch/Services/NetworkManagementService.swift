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
            
            loggingServie.log(message: String(format: Constants.logNetworkInterfaceHasBeenEnabled, interfaceName))
        }
        catch {
            loggingServie.log(message: String(format: Constants.logCannotEnableNetworkInterface, interfaceName), type: .error)
        }
    }
    
    func disableNetworkInterface(interfaceName: String) {
        do {
            try shellService.safeShell("networksetup -setairportpower \(interfaceName) off")
            
            loggingServie.log(message: String(format: Constants.logNetworkInterfaceHasBeenDisabled, interfaceName))
        }
        catch {
            loggingServie.log(message: String(format: Constants.logCannotDisableNetworkInterface, interfaceName), type: .error)
        }
    }
}
