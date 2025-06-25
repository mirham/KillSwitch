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
        
        guard let apiUrl = ipApiUrl ?? ipApiService.getRandomActiveIpApi()?.url else {
            return OperationResult(error: Constants.errorNoActiveIpApiFound)
        }
        
        let ipAddress = try? await fetchIpAddressAsync(from: apiUrl)
        
        guard let ipAddress else {
            return OperationResult(error: Constants.errorIpApiResponseIsInvalid)
        }
        
        if withInfo {
            return await getPublicIpInfoAsync(
                apiUrl: appState.userData.ipInfoApiUrl,
                publicIp: ipAddress,
                keyMapping: appState.userData.ipInfoApiKeyMapping
            )
        }
        
        return OperationResult(result: IpInfoBase(ipAddress: ipAddress))
    }
    
    func getPublicIpInfoAsync(
        apiUrl: String,
        publicIp: String,
        keyMapping: [String:String]) async -> OperationResult<IpInfoBase> {
        guard !Task.isCancelled else {
            return OperationResult(error: Constants.errorTaskCancelled)
        }
        
        guard !keyMapping.isEmpty, let ipInfoUrl = ipApiService.prepareIpInfoApiUrl(
            publicIp: publicIp, ipInfoApiUrl: apiUrl)
        else {
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
    
    private func fetchIpAddressAsync(from apiUrl: String) async throws -> String {
        guard !Task.isCancelled else {
            throw Constants.errorTaskCancelled
        }
        
        let apiResponse = await ipApiService.callIpApiAsync(ipApiUrl: apiUrl)
        
        guard apiResponse.success, let ipAddress = apiResponse.result?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw apiResponse.error ?? Constants.errorIpApiResponseIsInvalid
        }
        
        guard ipAddress.isValidIp() else {
            throw Constants.errorIpApiResponseIsInvalid
        }
        
        return ipAddress
    }
}
