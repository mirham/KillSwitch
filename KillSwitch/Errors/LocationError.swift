//
//  LocationError.swift
//  KillSwitch
//
//  Created by UglyGeorge on 22.04.2026.
//

import Foundation

enum LocationError: LocalizedError {
    case toggleFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
            case .toggleFailed(let reason):
                return "Cannot toggle location services: \(reason)"
        }
    }
}
