//
//  IpAddress.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import SwiftData

@Model
class IpAddressModelNew {
    let ip: String
    let desc: String
    
    init(ip: String, 
         desc: String) {
        self.ip = ip
        self.desc = desc
    }
}
