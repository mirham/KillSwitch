//
//  NetworkService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import Network
import SystemConfiguration

class NetworkService : ServiceBase, ShellAccessible {
    static let shared = NetworkService()
    
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
    
    // MARK: Private functions
    
    func getPhysicalInterfaces() -> [NetworkInterface] {
        let interfaces = SCNetworkInterfaceCopyAll() as? Array<SCNetworkInterface> ?? []
        
        let result = interfaces.compactMap { interface -> NetworkInterface? in
            guard let interfaceName = SCNetworkInterfaceGetLocalizedDisplayName(interface) as? String else { return nil }
            guard let bsdName = SCNetworkInterfaceGetBSDName(interface) as? String else { return nil }
            
            if (bsdName.hasPrefix(Constants.physicalNetworkInterfacePrefix)
               && interfaceName.range(of: Constants.physicalNetworkInterfaceExclusion, options: .caseInsensitive) == nil) {
                return NetworkInterface(
                    name: bsdName as String,
                    type: getNetworkInterfaceTypeByInterfaceName(interfaceName: interfaceName),
                    localizedName: interfaceName)
            }
            
            return nil
        }
        
        return result
    }
    
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
