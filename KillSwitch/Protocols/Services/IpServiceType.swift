//
//  IpServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

protocol IpServiceType {
    func getPublicIpAsync(ipApiUrl: String?, withInfo: Bool) async -> OperationResult<IpInfoBase>
    func getPublicIpInfoAsync(ip : String) async -> OperationResult<IpInfoBase>
    func addAllowedPublicIp(ip : String, ipInfo: IpInfoBase?, safetyType: SafetyType)
}
