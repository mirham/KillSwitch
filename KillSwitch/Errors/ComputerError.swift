//
//  ComputerError.swift
//  KillSwitch
//
//  Created by UglyGeorge on 22.04.2026.
//

import Foundation

enum ComputerError: LocalizedError {
    case rebootFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
            case .rebootFailed(let reason):
                return String(format: Constants.logCannotReboot, reason)
        }
    }
}
