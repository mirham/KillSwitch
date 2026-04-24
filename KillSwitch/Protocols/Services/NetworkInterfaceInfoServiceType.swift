//
//  NetworkInterfaceInfoServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 21.04.2026.
//

protocol NetworkInterfaceInfoServiceType {
    func getFriendlyNameAsync(for interface: NetworkInterface) async -> String?
}
