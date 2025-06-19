//
//  IpService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation
import Factory

class IpService : ServiceBase, ApiCallable, IpServiceType {
    @Injected(\.ipApiService) private var ipApiService
    
    func getPublicIpAsync(ipApiUrl: String? = nil, withInfo: Bool = true) async -> OperationResult<IpInfoBase> {
        guard !Task.isCancelled else {
            return OperationResult(error: Constants.errorTaskCancelled)
        }
        
        let currentIpApiUrl = ipApiUrl ?? ipApiService.getRandomActiveIpApi()?.url
        
        guard let currentIpApiUrl else {
            return OperationResult(error: Constants.errorNoActiveIpApiFound)
        }
        
        let ipAddressResult = await ipApiService.callIpApiAsync(ipApiUrl: currentIpApiUrl)
        guard ipAddressResult.success, let ipAddress = ipAddressResult.result?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return OperationResult(error: ipAddressResult.error ?? Constants.errorIpApiResponseIsInvalid)
        }
        
        guard ipAddress.isValidIp() else {
            return OperationResult(error: Constants.errorIpApiResponseIsInvalid)
        }
        
        if withInfo {
            let ipWithInfoResult = await getPublicIpInfoAsync(
                publicIp: ipAddress,
                keyMapping: appState.userData.ipInfoApiKeyMapping
            )
            
            return ipWithInfoResult
        }
        
        return OperationResult(result: IpInfoBase(ipAddress: ipAddress))
    }
    
    func getPublicIpInfoAsync(publicIp: String, keyMapping: [String:String]) async -> OperationResult<IpInfoBase> {
        guard !Task.isCancelled else {
            return OperationResult(error: Constants.errorTaskCancelled)
        }
        
        guard !keyMapping.isEmpty,
              let ipInfoUrl = ipApiService.prepareIpInfoApiUrl(
                publicIp: publicIp,
                ipInfoApiUrl: appState.userData.ipInfoApiUrl
              ) else {
            return OperationResult(result: IpInfoBase(ipAddress: publicIp))
        }
        
        do {
            let response = try await callGetApiAsync(
                apiUrl: ipInfoUrl,
                timeoutInterval: Constants.ipInfoApiCallTimeoutInSeconds)
            
            guard let jsonData = response.data(using: .utf8) else {
                throw URLError(.cannotParseResponse)
            }
            
            let preparedJsonData = try jsonData.remap(mapping: keyMapping)
            let info = try JSONDecoder().decode(IpInfoBase.self, from: preparedJsonData)
            
            return OperationResult(result: info)
        } catch {
            if let urlError = error as? URLError,
               [.notConnectedToInternet, .networkConnectionLost].contains(urlError.code) {
                return OperationResult(result: IpInfoBase(ipAddress: publicIp))
            }
            
            let errorMessage = String(format: Constants.errorWhenCallingIpInfoApi, error.localizedDescription)
            return OperationResult(result: IpInfoBase(ipAddress: publicIp), error: errorMessage)
        }
    }
    
    func addAllowedPublicIp(publicIp: IpInfo) {            
            if !appState.userData.allowedIps.contains(publicIp) {
                appState.userData.allowedIps.append(publicIp)
            }
            else {
                if let currentIpIndex = appState.userData.allowedIps.firstIndex(
                    where: {$0.ipAddress == publicIp.ipAddress && $0.safetyType != publicIp.safetyType}) {
                    appState.userData.allowedIps[currentIpIndex] = publicIp
                }
            }
        }
    
    // MARK: Private functions
    
    private func callIpApiAsync(ipApiUrl: String) async -> OperationResult<String> {
        do {
            let response = try await callGetApiAsync(
                apiUrl: ipApiUrl,
                timeoutInterval: Constants.ipInfoApiCallTimeoutInSeconds)
            
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
