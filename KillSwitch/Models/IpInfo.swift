//
//  IpAddressInfo.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation

struct IpInfo: Codable, Identifiable, Equatable {
    var id = UUID()
    var ipVersion: Int
    var ipAddress: String
    var countryName: String
    var countryCode: String
    var safetyType: AddressSafetyType
    
    init(ipAddress: String,
         ipAddressInfo: IpInfoBase?,
         safetyType: AddressSafetyType = .unknown){
        let info = ipAddressInfo ?? IpInfoBase(ipAddress: ipAddress)
        
        self.ipVersion = info.ipVersion
        self.ipAddress = info.ipAddress
        self.countryName = info.countryName
        self.countryCode = info.countryCode
        self.safetyType = safetyType
    }
    
    static func == (lhs: IpInfo, rhs: IpInfo) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
}
