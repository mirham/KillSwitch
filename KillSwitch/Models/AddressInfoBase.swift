//
//  IpAddressInfo.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation
import Network

struct AddressInfoBase: Codable, Equatable {
    var ipVersion: Int
    var ipAddress: String
    var countryName: String
    var countryCode: String
    
    static func == (lhs: AddressInfoBase, rhs: AddressInfoBase) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
    
    init(ipAddress: String){
        self.ipVersion = (IPv4Address(ipAddress) != nil) ? Constants.ipV4 : Constants.ipV6
        self.ipAddress = ipAddress
        self.countryName = String()
        self.countryCode = String()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
}