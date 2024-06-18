//
//  IpAddressType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import Foundation

enum AddressSafetyType : Int, CaseIterable, Codable {
    case unknown = 0
    case compete = 1
    case some = 2
}
