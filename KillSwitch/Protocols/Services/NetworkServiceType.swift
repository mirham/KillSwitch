//
//  NetworkServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

protocol NetworkServiceType {
    func getPhysicalInterfaces() -> [NetworkInterface]
    func enableNetworkInterface(interfaceName: String)
    func disableNetworkInterface(interfaceName: String)
}
