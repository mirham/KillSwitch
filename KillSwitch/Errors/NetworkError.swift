//
//  NetworkError.swift
//  KillSwitch
//
//  Created by UglyGeorge on 22.04.2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case taskCancelled
    case invalidUrl(String)
    case invalidResponse
    case unreachable(statusCode: Int)
    case interfaceCommandFailed(interfaceName: String, action: InterfaceAction)
    
    enum InterfaceAction {
        case enable
        case disable
    }
    
    var errorDescription: String? {
        switch self {
            case .taskCancelled:
                return "Task was cancelled."
            case .invalidUrl(let url):
                return "Invalid URL: \(url)"
            case .invalidResponse:
                return "Received an invalid HTTP response."
            case .unreachable(let code):
                return "Server returned unexpected status code: \(code)"
            case .interfaceCommandFailed(let name, let action):
                return "Failed to \(action == .enable ? "enable" : "disable") network interface: \(name)"
        }
    }
}
