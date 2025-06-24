//
//  IpServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

protocol IpServiceType {
    func getPublicIpAsync(ipApiUrl: String?, withInfo: Bool) async -> OperationResult<IpInfoBase>
    func getPublicIpInfoAsync(
        apiUrl: String,
        publicIp: String,
        keyMapping: [String:String]) async -> OperationResult<IpInfoBase>
    func addAllowedPublicIp(publicIp: IpInfo)
}
