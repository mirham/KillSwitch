//
//  NetworkInterface.swift
//  KillSwitch
//
//  Created by UglyGeorge on 09.06.2024.
//

import Foundation

struct NetworkInterface: Hashable, Equatable {
    let name: String
    let localizedName: String?
    var friendlyName: String?
    let type: NetworkInterfaceType
    
    var isPhysical: Bool {
        switch type {
            case .wired, .wifi, .cellular:
                return true
            default:
                return false
        }
    }
    
    init(name: String,
         type: NetworkInterfaceType,
         localizedName: String? = nil) {
        self.name = name
        self.type = type
        self.localizedName = localizedName
    }
    
    static func == (lhs: NetworkInterface, rhs: NetworkInterface) -> Bool {
        return lhs.name == rhs.name
         && lhs.type == rhs.type
         && lhs.friendlyName == rhs.friendlyName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(friendlyName)
    }
}
