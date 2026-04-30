//
//  NetworkServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

protocol NetworkServiceType {
    func isUrlReachableAsync(url : String) async throws -> Bool
    func refreshPublicIpAsync() async
    func getPhysicalInterfaces() -> [NetworkInterface]
    func enableNetworkInterfaceAsync(interfaceName: String) async
    func disableNetworkInterfaceAsync(interfaceName: String) async
}
