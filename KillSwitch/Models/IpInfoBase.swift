//
//  IpInfoBase.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation

struct IpInfoBase: Codable, Equatable {
    var ipAddress: String
    var countryName: String
    var countryCode: String
    
    enum CodingKeys: String, CodingKey {
        case ipAddress
        case countryCode
        case countryName
    }
    
    static func == (lhs: IpInfoBase, rhs: IpInfoBase) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
    
    init(ipAddress: String) {
        self.ipAddress = ipAddress
        self.countryName = String()
        self.countryCode = String()
    }
    
    func hasLocation() -> Bool {
        return !self.countryCode.isEmpty && !self.countryName.isEmpty
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ipAddress)
    }
}
