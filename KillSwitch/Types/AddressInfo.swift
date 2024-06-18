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
    
    static func == (lhs: AddressInfo, rhs: AddressInfo) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
}
