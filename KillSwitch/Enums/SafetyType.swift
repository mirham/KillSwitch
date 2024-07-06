//
//  IpAddressType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import Foundation

enum SafetyType : Int, CaseIterable, Codable {
    case unknown = 0
    case compete = 1
    case some = 2
    case unsafe = 3
    
    var description : String {
        switch self {
            case .unknown: return "Unknown"
            case .compete: return "Compete"
            case .some: return "Some"
            case .unsafe: return "Unsafe"
        }
    }
}