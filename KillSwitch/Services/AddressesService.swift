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
    
    private let loggingService = LoggingService.shared
    
    private var apisList = [
        "http://api.ipify.org",
        "http://icanhazip.com",
        "http://ipinfo.io/ip",
        "http://ipecho.net/plain",
        "http://ident.me",
        "https://checkip.amazonaws.com",
        "http://whatismyip.akamai.com",
        "https://ip.istatmenus.app",
        "https://api.seeip.org"
    ]
    
    func getCurrentIpAddress() async -> String?{
        let ipAddressResponse = await callIpAddressApi(urlAddress: apisList.randomElement()!)
        let ipAddressString = ipAddressResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let _ = IPv4Address(ipAddressString) {
            return ipAddressString
        } else if let _ = IPv6Address(ipAddressString) {
            return ipAddressString
        } else {
            return nil
        }
    }
    
    func getCurrentIpAddressInfo(ipAddress : String) async -> AddressInfo? {
        do {
            let response = try await callGetApi(urlAddress: "https://freeipapi.com/api/json/\(ipAddress)")
            
            guard response != nil else {
                return nil
            }
            
            let jsonData = response!.data(using: .utf8)!
            let decoder = JSONDecoder()
            let info = try decoder.decode(AddressInfo.self, from: jsonData)
            
            // TODO RUSS: Continue from here
            return info
        }
        catch {
            let logEntry = LogEntry(message: "Error when called IP info API:\(error.localizedDescription)")
            loggingService.log(logEntry: logEntry)
            
            return nil
        }
    }
    
    private func callIpAddressApi(urlAddress : String) async -> String {
        do {
            let response = try await callGetApi(urlAddress: urlAddress)
            
            let logEntry = LogEntry(message: "Called API:" + urlAddress)
            loggingService.log(logEntry: logEntry)
            
            return response ?? String()
        }
        catch {
            let logEntry = LogEntry(message: "Error when called API:\(error.localizedDescription)")
            loggingService.log(logEntry: logEntry)
            
            return String()
        }
    }
}
