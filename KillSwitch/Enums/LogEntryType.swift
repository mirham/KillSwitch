//
//  NetworkStatus.swift
//  KillSwitch
//
//  Created by UglyGeorge on 09.06.2024.
//

import Foundation

enum LogEntryType : Int, CaseIterable {
    case unknown = 0
    case info = 1
    case warning = 2
    case error = 3
    
    var description : String {
        switch self {
            case .unknown: return "Unknown"
            case .info: return "Info"
            case .warning: return "Warning"
            case .error: return "Error"
        }
    }
}
