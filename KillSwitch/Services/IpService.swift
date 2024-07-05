//
//  IpAddressesService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation
import Network

class IpService : ServiceBase, ApiCallable {
    static let shared = IpService()
    
    func getCurrentIpAsync(ipApiUrl: String? = nil, withInfo: Bool = true) async -> OperationResult<IpInfoBase> {
        var currentIpApiUrl = ipApiUrl
        
        if (currentIpApiUrl == nil) {
            let randomIpApi = getRandomActiveIpApi()
            currentIpApiUrl = randomIpApi?.url
        }
        
        guard currentIpApiUrl != nil else { return OperationResult(error: Constants.errorNoActiveAddressApiFound) }
        
        let ipAddressResult = await callIpApiAsync(ipApiUrl: currentIpApiUrl!)
        
        guard ipAddressResult.success else { return OperationResult(error: ipAddressResult.error!) }
        
        let ipAddressString = ipAddressResult.result!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard ipAddressString.isValidIp() else { return OperationResult(error: Constants.errorIpApiResponseIsInvalid) }
        
        if (withInfo) {
            let ipWithInfoResult = await getIpInfoAsync(ip: ipAddressString)
            
            return OperationResult(result: ipWithInfoResult.result! , error: ipWithInfoResult.error)
        }
        
        return OperationResult(result: IpInfoBase(ipAddress: ipAddressString))
    }
    
    func getIpInfoAsync(ip : String) async -> OperationResult<IpInfoBase> {
        do {
            // TODO RUSS: Add to Settings, add JSON mapping
            let response = try await callGetApiAsync(apiUrl: "https://freeipapi.com/api/json/\(ip)")
            let jsonData = response.data(using: .utf8)!
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            let info = try decoder.decode(IpInfoBase.self, from: jsonData)
            
            return OperationResult(result: info)
        }
        catch {
            if let error = error as? URLError, case .notConnectedToInternet = error.code {
                return OperationResult(result: IpInfoBase(ipAddress: ip))
            }
            
            if let error = error as? URLError, case .networkConnectionLost = error.code {
                return OperationResult(result: IpInfoBase(ipAddress: ip))
            }
            
            return OperationResult(
                result: IpInfoBase(ipAddress: ip),
                error: String(format: Constants.errorWhenCallingIpInfoApi, error.localizedDescription))
        }
    }
    
    func addAllowedIp(ip : String, ipInfo: IpInfoBase?, safetyType: AddressSafetyType) {
            let newAllowedIp = IpInfo(ipAddress: ip, ipAddressInfo: ipInfo, safetyType: safetyType)
            
            if !appState.userData.allowedIps.contains(newAllowedIp) {
                appState.userData.allowedIps.append(newAllowedIp)
            }
            else {
                if let currentAllowedIpIndex = appState.userData.allowedIps.firstIndex(
                    where: {$0.ipAddress == ip && $0.safetyType != safetyType}) {
                    appState.userData.allowedIps[currentAllowedIpIndex] = newAllowedIp
                }
            }
        }
    
    // MARK: Private functions
    private func getRandomActiveIpApi() -> IpApiInfo? {
        let result = self.appState.userData.ipApis.filter({$0.active == nil || $0.active!}).randomElement()
        
        return result
    }
    
    
    private func callIpApiAsync(ipApiUrl : String) async -> OperationResult<String> {
        do {
            let response = try await callGetApiAsync(apiUrl: ipApiUrl)
            
            return OperationResult(result: response)
        }
        catch {
            if let error = error as? URLError, case .notConnectedToInternet = error.code {
                return OperationResult(result: String())
            }
            
            if let error = error as? URLError, case .networkConnectionLost = error.code {
                return OperationResult(result: String())
            }

            if let inactiveApiIndex = self.appState.userData.ipApis.firstIndex(where: { $0.url == ipApiUrl }) {
                self.appState.userData.ipApis[inactiveApiIndex].active = false
            }
                
            return OperationResult(error: String(format: Constants.errorWhenCallingIpAddressApi, ipApiUrl, error.localizedDescription))
        }
    }
}
