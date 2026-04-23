//
//  ShellError.swift
//  KillSwitch
//
//  Created by UglyGeorge on 23.04.2026.
//

import Foundation

enum ShellError: LocalizedError {
    case commandFailed(command: String, underlyingError: String)
    case permissionDenied(command: String, underlyingError: String)
    case invalidOutput(command: String)
    
    var errorDescription: String? {
        switch self {
            case .commandFailed(let command, let error):
                return "Shell command failed: '\(command)' - \(error)"
            case .permissionDenied(let command, let error):
                return "Permission denied for command: '\(command)' - \(error)"
            case .invalidOutput(let command):
                return "Invalid or empty output from command: '\(command)'"
        }
    }
}
