//
//  SecurityType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import Foundation

enum SecurityType : Int, CaseIterable, Codable {
    case unknown = 0
    case full = 1
    case partial = 2
    case notSecure = 3
    
    var description : String {
        switch self {
            case .unknown: return "Unknown"
            case .full: return "Full"
            case .partial: return "Partial"
            case .notSecure: return "Not secure"
        }
    }
    
    var fullDesctiption : String {
        switch self {
            case .unknown: return String(
                format:Constants.securityDescriprion,
                description)
            case .full: return String(
                format:Constants.securityDescriprion,
                description)
            case .partial: return String(
                format:Constants.securityDescriprion,
                description)
            case .notSecure: return description
        }
    }
}
