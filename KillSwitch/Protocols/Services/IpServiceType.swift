//
//  IpServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

protocol IpServiceType {
    func getCurrentIpAsync(ipApiUrl: String?, withInfo: Bool) async -> OperationResult<IpInfoBase>
    func getIpInfoAsync(ip : String) async -> OperationResult<IpInfoBase>
    func addAllowedIp(ip : String, ipInfo: IpInfoBase?, safetyType: SafetyType)
}
