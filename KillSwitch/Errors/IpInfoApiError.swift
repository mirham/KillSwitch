//
//  IpInfoApiError.swift
//  KillSwitch
//
//  Created by UglyGeorge on 23.04.2026.
//

import Foundation

enum IpInfoApiError: LocalizedError {
    case noPublicIp
    case invalidUrl
    case urlUnreachable
    case invalidApiResponse
    case missingLocationData
}
