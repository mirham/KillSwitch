//
//  IpError.swift
//  KillSwitch
//
//  Created by UglyGeorge on 22.04.2026.
//

import Foundation

enum IpError: LocalizedError {
    case taskCancelled
    case noActiveApi
    case invalidResponse(apiUrl: String)
    case invalidIpAddress(apiUrl: String)
    case ipInfoCallFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
            case .taskCancelled:
                return "Task was cancelled."
            case .noActiveApi:
                return Constants.errorNoActiveIpApiFound
            case .invalidResponse(let url):
                return String(format: Constants.errorIpApiResponseIsInvalid, url)
            case .invalidIpAddress(let url):
                return String(format: Constants.errorIpApiResponseIsInvalid, url)
            case .ipInfoCallFailed(let reason):
                return String(format: Constants.errorWhenCallingIpInfoApi, reason)
        }
    }
}
