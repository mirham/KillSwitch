//
//  NetworkManagementService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation

class NetworkManagementService{
    static let shared = NetworkManagementService()
    
    private let shellService = ShellService.shared
    private let loggingServie = LoggingService.shared
    
    func enableNetworkInterface(interfaceName: String){
        do {
            try shellService.safeShell(String(format: Constants.shCommandEnableNetworkIterface, interfaceName))
            
            loggingServie.log(message: String(format: Constants.logNetworkInterfaceHasBeenEnabled, interfaceName))
        }
        catch {
            loggingServie.log(message: String(format: Constants.logCannotEnableNetworkInterface, interfaceName), type: .error)
        }
    }
    
    func disableNetworkInterface(interfaceName: String) {
        do {
            try shellService.safeShell(String(format: Constants.shCommandDisableNetworkIterface, interfaceName))
            
            loggingServie.log(message: String(format: Constants.logNetworkInterfaceHasBeenDisabled, interfaceName))
        }
        catch {
            loggingServie.log(message: String(format: Constants.logCannotDisableNetworkInterface, interfaceName), type: .error)
        }
    }
}
