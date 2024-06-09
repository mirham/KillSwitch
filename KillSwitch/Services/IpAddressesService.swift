//
//  IpAddressesService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import Network

class IpAddressesService: ObservableObject {
    static let shared = IpAddressesService()
    
    let loggingService = LoggingService.shared
    
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
    
    private func callIpAddressApi(urlAddress : String) async -> String {
        do {
            let url = URL(string: urlAddress)!
            
            let request = URLRequest(url: url)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response  = String(data: data, encoding: String.Encoding.utf8) as String?
            
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
