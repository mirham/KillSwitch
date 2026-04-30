//
//  IpApiService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 19.06.2025.
//

import Foundation
import Factory

final class IpApiService: ApiCallable, IpApiServiceType {
    @Injected(\.appState) private var appState
    
    func getRandomActiveIpApi() -> IpApiInfo? {
        appState.userData.ipApis.filter { $0.isActive() }.randomElement()
    }
    
    func prepareIpInfoApiUrl(publicIp: String, ipInfoApiUrl: String) -> String? {
        guard !ipInfoApiUrl.isEmpty, !publicIp.isEmpty
        else { return nil }
        
        let result = ipInfoApiUrl.replacingOccurrences(
            of: Constants.publicIpMask,
            with: publicIp)
        
        return result.isValidUrl() ? result : nil
    }
    
    func callIpApiAsync(ipApiUrl: String) async -> OperationResult<String> {
        guard !Task.isCancelled
        else {
            return OperationResult(
                error: IpApiError.taskCancelled.localizedDescription)
        }
        
        let timeout = await MainActor.run { calculateCallTimeout() }
        
        for attempt in 1...Constants.defaultRetryCount {
            guard !Task.isCancelled else {
                return OperationResult(
                    error: IpApiError.taskCancelled.localizedDescription)
            }
            do {
                let response = try await callGetApiAsync(
                    apiUrl: ipApiUrl,
                    timeoutInterval: timeout
                )
                
                let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard trimmed.isValidIp()
                else {
                    return OperationResult(
                        error: IpError.invalidIpAddress(
                            apiUrl: ipApiUrl).localizedDescription
                    )
                }
                
                return OperationResult(result: response)
                
            } catch let urlError as URLError
                        where [.notConnectedToInternet, .networkConnectionLost]
                .contains(urlError.code) {
                return OperationResult(
                    error: IpApiError.notConnected.localizedDescription)
            } catch {
                if attempt < Constants.defaultRetryCount {
                    try? await Task.sleep(nanoseconds: UInt64(attempt) * Constants.secondInNanoseconds)
                    continue
                }
                
                await deactivateIpApiAsync(ipApiUrl: ipApiUrl)
                
                return OperationResult(
                    error: IpApiError.callFailed(
                        apiUrl: ipApiUrl,
                        reason: error.localizedDescription
                    ).localizedDescription
                )
            }
        }
        
        await deactivateIpApiAsync(ipApiUrl: ipApiUrl)
        
        return OperationResult(
            error: IpApiError.callFailed(
                apiUrl: ipApiUrl,
                reason: Constants.logMaxRetriesExceeded
            ).localizedDescription
        )
    }
    
    // MARK: Private methods
    
    @MainActor
    private func calculateCallTimeout() -> Double {
        let activeCount = appState.userData.ipApis.filter { $0.isActive() }.count
        
        guard activeCount > 0
        else { return Constants.callTimeoutIpApiInSeconds }
        
        let result = Constants.callTimeoutIpApiTotalInSeconds / Double(activeCount)
        
        return max(result, Constants.callTimeoutIpApiInSeconds)
    }
    
    private func deactivateIpApiAsync(ipApiUrl: String) async {
        guard !Task.isCancelled
        else { return }
        
        await MainActor.run {
            guard appState.network.status == .on
            else { return }
            
            guard let index = appState.userData.ipApis
                .firstIndex(where: { $0.url == ipApiUrl })
            else { return }
            
            appState.userData.ipApis[index].active = false
        }
    }
}
