//
//  IpAddressInfo.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation

struct AddressInfoBase: Codable, Equatable {
    var ipVersion: Int
    var ipAddress: String
    var countryName: String
    var countryCode: String
    
    static func == (lhs: AddressInfoBase, rhs: AddressInfoBase) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
}
