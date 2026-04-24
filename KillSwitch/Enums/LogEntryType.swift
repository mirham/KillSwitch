//
//  LogEntryType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 09.06.2024.
//

import SwiftUI

enum LogEntryType : Int, CaseIterable {
    case unknown = 0
    case info = 1
    case warning = 2
    case error = 3
    case success  = 4
    
    var description : String {
        switch self {
            case .unknown: return "Unknown"
            case .info: return "Info"
            case .warning: return "Warning"
            case .error: return "Error"
            case .success:  return "Success"
        }
    }
    
    var entryColor: Color {
        switch self {
            case .unknown: return .gray
            case .info: return .blue
            case .warning: return .orange
            case .error: return .red
            case .success: return .green
        }
    }
}
