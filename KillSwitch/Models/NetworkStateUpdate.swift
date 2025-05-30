//
//  NetworkStateUpdate.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.05.2025.
//

struct NetworkStateUpdate {
    var status: NetworkStatusType?
    var publicIp: IpInfoBase?
    var activeNetworkInterfaces: [NetworkInterface]?
    var physicalNetworkInterfaces: [NetworkInterface]?
    var isDisconnected: Bool?
    var isObtainingIp: Bool?
    var forceUpdatePublicIp: Bool = false
}
