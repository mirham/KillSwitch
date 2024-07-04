//
//  NetworkInterface.swift
//  KillSwitch
//
//  Created by UglyGeorge on 09.06.2024.
//

import Foundation


class NetworkInterface: Hashable, Equatable {
    let id: UUID
    let name: String
    let type: NetworkInterfaceType
    
    init(name: String,
         type: NetworkInterfaceType) {
        self.id = UUID()
        self.name = name
        self.type = type
    }
    
    static func == (lhs: NetworkInterface, rhs: NetworkInterface) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
    }
}
