//
//  IpAddressesService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation

class IpAddressesService : NetworkServiceBase {
    static let shared = IpAddressesService()
    
    private let loggingService = LoggingService.shared
    
    public func callIpAddressInfoApi(ipAddress : String) async -> IpAddressInfo? {
        do {
            let response = try await callGetApi(urlAddress: "https://freeipapi.com/api/json/\(ipAddress)")
            
            guard response != nil else {
                return nil
            }
            
            let jsonData = response!.data(using: .utf8)!
            let decoder = JSONDecoder()
            let info = try decoder.decode(IpAddressInfo.self, from: jsonData)
            
            // TODO RUSS: Continue from here
            return info
        }
        catch {
            let logEntry = LogEntry(message: "Error when called IP info API:\(error.localizedDescription)")
            loggingService.log(logEntry: logEntry)
            
            return nil
        }
    }
}
