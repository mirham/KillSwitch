//
//  NetworkStatusServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

protocol NetworkStatusServiceType {
    func setNetworkStatusAsync(status: NetworkStatusType) async
}
