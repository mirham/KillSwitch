//
//  NetworkInterface.swift
//  KillSwitch
//
//  Created by UglyGeorge on 09.06.2024.
//

import Foundation


class NetworkInterface {
    let id: UUID
    let name: String
    let type: NetworkInterfaceType
    
    init(name: String,
         type: NetworkInterfaceType) {
        self.id = UUID()
        self.name = name
        self.type = type
    }
}
