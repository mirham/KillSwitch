//
//  NetworkService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import Network
import SystemConfiguration

class NetworkService : ServiceBase, ShellAccessible, NetworkServiceType {
    func getPhysicalInterfaces() -> [NetworkInterface] {
        let interfaces = SCNetworkInterfaceCopyAll() as? Array<SCNetworkInterface> ?? []
        
        let result = interfaces.compactMap { interface -> NetworkInterface? in
            guard let interfaceName = SCNetworkInterfaceGetLocalizedDisplayName(interface) as? String else { return nil }
            guard let bsdName = SCNetworkInterfaceGetBSDName(interface) as? String else { return nil }
            
            let isPhysicalInterface = bsdName.hasPrefix(Constants.physicalNetworkInterfacePrefix) &&
                interfaceName.range(of: Constants.physicalNetworkInterfaceExclusion, options: .caseInsensitive) == nil
            
            guard isPhysicalInterface else { return nil }
            
            return NetworkInterface(
                name: bsdName as String,
                type: getNetworkInterfaceTypeByInterfaceName(interfaceName: interfaceName),
                localizedName: interfaceName)
        }
        
        return result
    }
    
    func enableNetworkInterface(interfaceName: String) {
        do {
            try safeShell(String(format: Constants.shCommandEnableNetworkIterface, interfaceName))
            
            loggingService.write(
                message: String(format: Constants.logNetworkInterfaceHasBeenEnabled, interfaceName),
                type: .info)
        }
        catch {
            loggingService.write(
                message: String(format: Constants.logCannotEnableNetworkInterface, interfaceName),
                type: .error)
        }
    }
    
    func disableNetworkInterface(interfaceName: String) {
        do {
            try safeShell(String(format: Constants.shCommandDisableNetworkIterface, interfaceName))
            
            loggingService.write(
                message: String(format: Constants.logNetworkInterfaceHasBeenDisabled, interfaceName),
                type: .info)
        }
        catch {
            loggingService.write(
                message: String(format: Constants.logCannotDisableNetworkInterface, interfaceName),
                type: .error)
        }
    }
    
    // MARK: Private functions
    
    private func getNetworkInterfaceTypeByInterfaceName(interfaceName: String) -> NetworkInterfaceType {
        if (interfaceName.range(of: Constants.physicalNetworkInterfaceWiFi, options: .caseInsensitive) != nil) {
            return NetworkInterfaceType.wifi
        }
        
        if (interfaceName.range(of: Constants.physicalNetworkInterfaceLan, options: .caseInsensitive) != nil) {
            return NetworkInterfaceType.wired
        }
        
        return NetworkInterfaceType.other
    }
}
