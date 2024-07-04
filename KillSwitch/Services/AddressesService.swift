//
//  IpAddressesService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation
import Network

class AddressesService : ServiceBase, ApiCallable, Settable {
    static let shared = AddressesService()
    
    func getRandomActiveAddressApi() -> ApiInfo? {
        let result = self.appState.userData.ipApis.filter({$0.active == nil || $0.active!}).randomElement()
        
        return result
    }
    
    func getCurrentIpAddress(addressApiUrl: String) async -> String? {
        let ipAddressResponse = await callIpAddressApi(urlAddress: addressApiUrl)
        let ipAddressString = ipAddressResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if((IPv4Address(ipAddressString) != nil) || (IPv6Address(ipAddressString) != nil)){
            Log.write(message: String(format: Constants.logCurrentIp, ipAddressString))
            
            return ipAddressString
        }
        else{            
            return nil
        }
    }
    
    func getIpAddressInfo(ipAddress : String) async -> AddressInfoBase? {
        do {
            // TODO RUSS: Add to Settings, add JSON mapping
            let response = try await callGetApi(urlAddress: "https://freeipapi.com/api/json/\(ipAddress)")
            
            guard response != nil else {
                return nil
            }
                        
            let jsonData = response?.data(using: .utf8)!
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            let info = try decoder.decode(AddressInfoBase.self, from: jsonData!)
            
            return info
        }
        catch {
            if let error = error as? URLError, case .notConnectedToInternet = error.code {
                return nil
            }
            else{
                Log.write(
                    message: String(format: Constants.logErrorWhenCallingIpInfoApi, error.localizedDescription),
                    type: .error)
                
                return nil
            }
        }
    }
    
    func validateIpAddress(ipToValidate: String) -> Bool {
        var result = false
        
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()
        
        if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            result = true
        }
        else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            result = true
        }
        
        return result
    }
    
    func validateApiAddress(apiAddressToValidate: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [Constants.regexUrl])
        
        return predicate.evaluate(with: apiAddressToValidate)
    }
    
    // MARK: Private functions
    
    private func callIpAddressApi(urlAddress : String) async -> String {
        do {
            let response = try await callGetApi(urlAddress: urlAddress)
            
            return response ?? String()
        }
        catch {
            if let error = error as? URLError, case .notConnectedToInternet = error.code {
                return String()
            }
            else{
                if let inactiveApiIndex = self.appState.userData.ipApis.firstIndex(where: {$0.url == urlAddress}) {
                    self.appState.userData.ipApis[inactiveApiIndex].active = false
                }
                
                Log.write(
                    message: String(format: Constants.logErrorWhenCallingIpAddressApi, urlAddress, error.localizedDescription),
                    type: .error
                )
                
                return String()
            }
        }
    }
}
