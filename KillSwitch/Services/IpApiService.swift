//
//  IpApiService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 19.06.2025.
//

import Foundation

class IpApiService : ServiceBase, ApiCallable, IpApiServiceType {
    func getRandomActiveIpApi() -> IpApiInfo? {
        let result = self.appState.userData.ipApis.filter({$0.isActive()}).randomElement()
        
        return result
    }
    
    func prepareIpInfoApiUrl(publicIp: String, ipInfoApiUrl: String) -> String? {
        guard !ipInfoApiUrl.isEmpty else { return nil }
        guard !publicIp.isEmpty else { return nil }
        
        let result = ipInfoApiUrl.replacingOccurrences(of: Constants.publicIpMask, with: publicIp)
        
        guard result.isValidUrl() else { return nil }
        
        return result
    }
    
    func callIpApiAsync(ipApiUrl : String) async -> OperationResult<String> {
        guard !Task.isCancelled else {
            return OperationResult(error: Constants.errorTaskCancelled)
        }
        
        do {
            let response = try await callGetApiAsync(
                apiUrl: ipApiUrl,
                timeoutInterval: calculateCallTimeout())
            
            return OperationResult(result: response)
        }
        catch {
            if let error = error as? URLError, case .notConnectedToInternet = error.code {
                return OperationResult(result: String())
            }
            
            if let error = error as? URLError, case .networkConnectionLost = error.code {
                return OperationResult(result: String())
            }
            
            await deactivateIpApiAsync(ipApiUrl: ipApiUrl)
            
            return OperationResult(error: String(format: Constants.errorWhenCallingIpAddressApi, ipApiUrl, error.localizedDescription))
        }
    }
    
    // MARK: Private functions
    
    private func deactivateIpApiAsync(ipApiUrl: String) async {
        guard !Task.isCancelled else { return }
        
        guard self.appState.network.status == .on else { return }
        
        if let inactiveApiIndex = self.appState.userData.ipApis
            .firstIndex(where: { $0.url == ipApiUrl }) {
            await MainActor.run() {
                self.appState.userData.ipApis[inactiveApiIndex].active = false
            }
        }
    }
    
    private func calculateCallTimeout() -> Double {
        let activeApisCount = self.appState.userData.ipApis.count(where: {$0.isActive()})
        
        guard activeApisCount > 0 else { return Constants.callTimeoutIpApiInSeconds }
        
        let result = Constants.callTimeoutIpApiTotalInSeconds / Double(activeApisCount)
        
        return max(result, Constants.callTimeoutIpApiInSeconds)
    }
}
