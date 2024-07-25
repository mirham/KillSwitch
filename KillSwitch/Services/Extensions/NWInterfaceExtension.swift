//
//  NwPathExtension.swift
//  KillSwitch
//
//  Created by UglyGeorge on 25.07.2024.
//

import Foundation
import Network

extension NWInterface {
    internal func asNetworkInterface() -> NetworkInterface {
        switch self.type {
            case .cellular:
                return NetworkInterface(name: self.name, type: NetworkInterfaceType.cellular)
            case .loopback:
                return NetworkInterface(name: self.name, type: NetworkInterfaceType.loopback)
            case .wifi:
                return NetworkInterface(name: self.name, type: NetworkInterfaceType.wifi)
            case .wiredEthernet:
                return NetworkInterface(name: self.name, type: NetworkInterfaceType.wired)
            case .other:
                return NetworkInterface(
                    name: self.name,
                    type: isVpn(name: self.name) ? NetworkInterfaceType.vpn : NetworkInterfaceType.other)
            @unknown default:
                return NetworkInterface(name: self.name, type: NetworkInterfaceType.unknown)
        }
    }
    
    // MARK: Private functions
    
    private func isVpn(name: String) -> Bool {
        for vpnProtocol in Constants.vpnProtocols
        where name.starts(with: vpnProtocol) {
            return true
        }
        
        return false
    }
}
