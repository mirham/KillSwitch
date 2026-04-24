//
//  IpApiError.swift
//  KillSwitch
//
//  Created by UglyGeorge on 22.04.2026.
//

import Foundation

enum IpApiError: LocalizedError {
    case taskCancelled
    case notConnected
    case callFailed(apiUrl: String, reason: String)
    
    var errorDescription: String? {
        switch self {
            case .taskCancelled:
                return "Task was cancelled."
            case .notConnected:
                return "No internet connection."
            case .callFailed(let url, let reason):
                return "Error when called IP address API '\(url)': '\(reason)', API marked as inactive and will be skipped until next application run"
        }
    }
}
