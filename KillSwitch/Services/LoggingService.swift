//
//  LoggingService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation

class LoggingService : ServiceBase, LoggingServiceType {
    func write(message: String, type: LogEntryType = .info) {
        DispatchQueue.main.async {
            let logEntry = LogEntry(message: message, type: type)
            self.write(logEntry: logEntry)
        }
    }
    
    func copy() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.logDateFormat
        
        var logText = String()
        
        for logEntry in self.appState.log {
            logText.append("\(dateFormatter.string(from: logEntry.date)) [\(logEntry.type.description.uppercased())] \(logEntry.message)\n")
        }
        
        AppHelper.copyTextToClipboard(text: logText)
    }
    
    func clear() {
        Task {
            await MainActor.run {
                self.appState.log.removeAll()
            }
        }
    }
    
    // MARK: Private functions
    
    private func write(logEntry: LogEntry) {
        Task {
            await MainActor.run {
                self.appState.log.insert(logEntry, at: 0)
            }
        }
    }
}
