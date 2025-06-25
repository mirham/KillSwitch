//
//  IpApiServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 19.05.2025.
//

protocol IpApiServiceType {
    func getRandomActiveIpApi() -> IpApiInfo?
    func prepareIpInfoApiUrl(publicIp: String, ipInfoApiUrl: String) -> String?
    func callIpApiAsync(ipApiUrl : String) async -> OperationResult<String>
}
