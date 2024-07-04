//
//  NetworkManagementService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation

class NetworkManagementService : ServiceBase, ShellAccessible {
    static let shared = NetworkManagementService()
    
    func enableNetworkInterface(interfaceName: String){
        do {
            try safeShell(String(format: Constants.shCommandEnableNetworkIterface, interfaceName))
            
            Log.write(message: String(format: Constants.logNetworkInterfaceHasBeenEnabled, interfaceName))
        }
        catch {
            Log.write(message: String(format: Constants.logCannotEnableNetworkInterface, interfaceName), type: .error)
        }
    }
    
    func disableNetworkInterface(interfaceName: String) {
        do {
            try safeShell(String(format: Constants.shCommandDisableNetworkIterface, interfaceName))
            
            Log.write(message: String(format: Constants.logNetworkInterfaceHasBeenDisabled, interfaceName))
        }
        catch {
            Log.write(message: String(format: Constants.logCannotDisableNetworkInterface, interfaceName), type: .error)
        }
    }
}
