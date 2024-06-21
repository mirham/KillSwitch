//
//  IpAddressesService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation
import Network

class AddressesService : NetworkServiceBase, ObservableObject {
    @Published var apis = [ApiInfo]()
    
    static let shared = AddressesService()
    
    private let appManagementService = AppManagementService.shared
    private let loggingService = LoggingService.shared
    
    init() {
        let savedApis: [ApiInfo]? = appManagementService.readSettingsArray(key: Constants.settingsKeyApis)
        
        if(savedApis == nil){
            for addressApiUrl in Constants.addressApiUrls {
                let apiInfo = ApiInfo(url: addressApiUrl, active: true)
                apis.append(apiInfo)
            }
        }
        else{
            self.apis = savedApis!
        }
    }
    
    func getRandomActiveAddressApi() -> ApiInfo? {
        let result = self.apis.filter({$0.active}).randomElement()
        
        return result
    }
    
    func getCurrentIpAddress(addressApiUrl: String) async -> String? {
        let ipAddressResponse = await callIpAddressApi(urlAddress: addressApiUrl)
        let ipAddressString = ipAddressResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if((IPv4Address(ipAddressString) != nil) || (IPv6Address(ipAddressString) != nil)){
            self.loggingService.log(message: String(format: Constants.logCurrentIp, ipAddressString))
            
            return ipAddressString
        }
        else{            
            return nil
        }
    }
    
    func getIpAddressInfo(ipAddress : String) async -> AddressInfoBase? {
        do {
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
                loggingService.log(
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
                if let inactiveApi = self.apis.firstIndex(where: {$0.url == urlAddress}) {
                    self.apis[inactiveApi].active = false
                }
                
                loggingService.log(
                    message: String(format: Constants.logErrorWhenCallingIpAddressApi, urlAddress, error.localizedDescription),
                    type: .error
                )
                
                return String()
            }
        }
    }
}
