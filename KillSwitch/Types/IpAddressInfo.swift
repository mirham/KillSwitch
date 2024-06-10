//
//  IpAddressInfo.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation

struct IpAddressInfo: Codable, Identifiable, Equatable {
    var id = UUID()
    var ipVersion: Int
    var ipAddress: String
    var countryName: String
    var countryCode:String
    
    static func == (lhs: IpAddressInfo, rhs: IpAddressInfo) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
}
