//
//  IpAddressInfo.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation

struct AddressInfo: Codable, Identifiable, Equatable {
    var id = UUID()
    var ipVersion: Int
    var ipAddress: String
    var countryName: String
    var countryCode: String
    var safetyType: AddressSafetyType
    
    init(ipAddress: String,
         ipAddressInfo: AddressInfoBase?,
         safetyType: AddressSafetyType = .unknown){
        let info = ipAddressInfo ?? AddressInfoBase(ipAddress: ipAddress)
        
        self.ipVersion = info.ipVersion
        self.ipAddress = info.ipAddress
        self.countryName = info.countryName
        self.countryCode = info.countryCode
        self.safetyType = safetyType
    }
    
    static func == (lhs: AddressInfo, rhs: AddressInfo) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
}
