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
    func enableNetworkInterface(interfaceName: String)
    func disableNetworkInterface(interfaceName: String)
}
