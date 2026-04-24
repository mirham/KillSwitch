//
//  LaunchAgentError.swift
//  KillSwitch
//
//  Created by UglyGeorge on 22.04.2026.
//

import Foundation

enum LaunchAgentError: LocalizedError {
    case executablePathNotFound
    case libraryDirectoryNotFound
    case createFailed(reason: String)
    case deleteFailed(reason: String)
    case applyFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
            case .executablePathNotFound:
                return "Could not locate the app executable path."
            case .libraryDirectoryNotFound:
                return "Could not locate the Library directory."
            case .createFailed(let reason):
                return "Cannot add Launch agent: \(reason)"
            case .deleteFailed(let reason):
                return "Cannot remove Launch agent: \(reason)"
            case .applyFailed(let reason):
                return "Failed to apply launch agent state: \(reason)"
        }
    }
}
