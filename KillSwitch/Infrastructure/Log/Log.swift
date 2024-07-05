//
//  LoggingService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation

class Log {
    var scrollViewId = UUID()
    
    // TODO RUSS: Add truncate log setting, copy to clipboard.
    static func write(message: String, type: LogEntryType = .info){
        let logEntry = LogEntry(message: message, type: type)
        write(logEntry: logEntry)
    }
    
    static func write(logEntry: LogEntry){
        Task {
            await MainActor.run {
                AppState.shared.log.insert(logEntry, at: 0)
            }
        }
    }
}
