//
//  SecurityType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import Foundation

enum SecurityType : Int, CaseIterable, Codable {
    case unknown = 0
    case compete = 1
    case some = 2
    case notSecure = 3
    
    var description : String {
        switch self {
            case .unknown: return "Unknown"
            case .compete: return "Compete"
            case .some: return "Some"
            case .notSecure: return "Not secure"
        }
    }
    
    var fullDesctiption : String {
        switch self {
            case .unknown: return String(format:Constants.securityDescriprion, description)
            case .compete: return String(format:Constants.securityDescriprion, description)
            case .some: return String(format:Constants.securityDescriprion, description)
            case .notSecure: return description
        }
    }
}
