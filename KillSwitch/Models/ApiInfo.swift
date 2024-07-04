//
//  IpAddressInfo.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import Foundation

struct ApiInfo: Codable, Identifiable, Equatable {
    var id = UUID()
    var url: String
    var active: Bool
    
    static func == (lhs: ApiInfo, rhs: ApiInfo) -> Bool {
        return lhs.url.uppercased() == rhs.url.uppercased()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
