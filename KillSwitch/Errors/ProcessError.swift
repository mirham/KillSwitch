//
//  ProcessError.swift
//  KillSwitch
//
//  Created by UglyGeorge on 22.04.2026.
//

import Foundation

enum ProcessError: LocalizedError {
    case invalidRegex(bundleId: String)
    
    var errorDescription: String? {
        switch self {
            case .invalidRegex(let bundleId):
                return "Error when handling active processes: Invalid regex for \(bundleId)"
        }
    }
}
