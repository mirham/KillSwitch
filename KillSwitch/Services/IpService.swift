//
//  IpService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation
import Factory

final class IpService: ApiCallable, IpServiceType {
    @Injected(\.appState) private var appState
    @Injected(\.ipApiService) private var ipApiService
    
    func getPublicIpAsync(
        ipApiUrl: String? = nil,
        withInfo: Bool = true
    ) async -> OperationResult<IpInfoBase> {
        guard !Task.isCancelled
        else {
            return OperationResult(
                error: IpError.taskCancelled.localizedDescription)
        }
        
        let snapshot = await MainActor.run {(
            apiUrl: ipApiUrl ?? ipApiService.getRandomActiveIpApi()?.url,
            ipInfoUrl: appState.userData.ipInfoApiUrl,
            keyMapping: appState.userData.ipInfoApiKeyMapping
        )}
        
        guard let apiUrl = snapshot.apiUrl
        else {
            return OperationResult(
                error: IpError.noActiveApi.localizedDescription)
        }
        
        do {
            let ipAddress = try await fetchIpAddressAsync(from: apiUrl)
            
            guard !Task.isCancelled else {
                return OperationResult(error: IpError.taskCancelled.localizedDescription)
            }
            
            if withInfo {
                return await getPublicIpInfoAsync(
                    apiUrl: snapshot.ipInfoUrl,
                    publicIp: ipAddress,
                    keyMapping: snapshot.keyMapping,
                    fetchedFromApi: apiUrl
                )
            }
            
            return OperationResult(
                result: IpInfoBase(
                    ipAddress: ipAddress,
                    fetchedFromApi: apiUrl))
        } catch let error as IpError {
            return OperationResult(error: error.localizedDescription)
        } catch {
            return OperationResult(error: error.localizedDescription)
        }
    }
    
    func getPublicIpInfoAsync(
        apiUrl: String,
        publicIp: String,
        keyMapping: [String: String],
        fetchedFromApi: String?
    ) async -> OperationResult<IpInfoBase> {
        guard !Task.isCancelled
        else {
            return OperationResult(
                error: IpError.taskCancelled.localizedDescription)
        }
        
        guard !keyMapping.isEmpty,
              let ipInfoUrl = ipApiService.prepareIpInfoApiUrl(
                publicIp: publicIp,
                ipInfoApiUrl: apiUrl)
        else {
            return OperationResult(
                result: IpInfoBase(
                    ipAddress: publicIp,
                    fetchedFromApi: fetchedFromApi))
        }
        
        do {
            let response = try await callGetApiAsync(
                apiUrl: ipInfoUrl,
                timeoutInterval: Constants.ipInfoApiCallTimeoutInSeconds
            )
            
            guard let jsonData = response.data(using: .utf8)
            else { throw IpError.invalidResponse(apiUrl: ipInfoUrl) }
            
            let remapped = try jsonData.remap(mapping: keyMapping)
            var info = try JSONDecoder().decode(IpInfoBase.self, from: remapped)
            
            info.fetchedFromApi = fetchedFromApi
            
            return OperationResult(result: info)
            
        } catch let urlError as URLError
            where [.notConnectedToInternet, .networkConnectionLost]
            .contains(urlError.code) {
            return OperationResult(
                result: IpInfoBase(
                    ipAddress: publicIp,
                    fetchedFromApi: fetchedFromApi))
        } catch let error as IpError {
            return OperationResult(
                result: IpInfoBase(
                    ipAddress: publicIp,
                    fetchedFromApi: fetchedFromApi),
                error: error.localizedDescription
            )
        } catch {
            return OperationResult(
                result: IpInfoBase(
                    ipAddress: publicIp,
                    fetchedFromApi: fetchedFromApi),
                error: IpError.ipInfoCallFailed(
                    reason: error.localizedDescription).localizedDescription
            )
        }
    }
    
    func addAllowedPublicIp(publicIp: IpInfo) {
        Task { @MainActor in
            if !appState.userData.allowedIps.contains(publicIp) {
                appState.userData.allowedIps.append(publicIp)
            } else if let index = appState.userData.allowedIps.firstIndex(where: {
                $0.ipAddress == publicIp.ipAddress && $0.safetyType != publicIp.safetyType
            }) {
                appState.userData.allowedIps[index] = publicIp
            }
        }
    }
    
    // MARK: Private functions
    
    private func fetchIpAddressAsync(from apiUrl: String) async throws -> String {
        guard !Task.isCancelled
        else { throw IpError.taskCancelled }
        
        let apiResponse = await ipApiService.callIpApiAsync(ipApiUrl: apiUrl)
        
        guard apiResponse.success,
              let ipAddress = apiResponse.result?.trimmingCharacters(in: .whitespacesAndNewlines)
        else { throw IpError.invalidResponse(apiUrl: apiUrl) }
        
        guard ipAddress.isValidIp()
        else { throw IpError.invalidIpAddress(apiUrl: apiUrl) }
        
        return ipAddress
    }
}
