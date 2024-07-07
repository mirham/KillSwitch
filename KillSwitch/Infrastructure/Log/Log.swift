//
//  Log.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation

class Log {
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
    
    static func copy(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.logDateFormat
        
        var logText = String()
        
        for logEntry in AppState.shared.log {
            logText.append("\(dateFormatter.string(from: logEntry.date)) [\(logEntry.type.description.uppercased())] \(logEntry.message)\n")
        }
        
        AppHelper.copyTextToClipboard(text: logText)
    }
    
    static func clear(){
        Task {
            await MainActor.run {
                AppState.shared.log.removeAll()
            }
        }
    }
}
