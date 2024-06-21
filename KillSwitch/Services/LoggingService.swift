//
//  LoggingService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import Combine

class LoggingService: ObservableObject {
    @Published var logs = [LogEntry]()
    
    var scrollViewId = UUID()
    
    static let shared = LoggingService()
    
    // TODO RUSS: Add truncate log setting, copy to clipboard.
    func log(message: String, type: LogEntryType = .info){
        let logEntry = LogEntry(message: message, type: type)
        log(logEntry: logEntry)
    }
    
    func log(logEntry: LogEntry){
        DispatchQueue.main.async {
            self.logs.insert(logEntry, at: 0)
            self.scrollViewId = logEntry.id
        }
    }
}
