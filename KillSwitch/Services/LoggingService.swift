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
    
    func log(logEntry: LogEntry){
        logs.insert(logEntry, at: 0)
        scrollViewId = logEntry.id
    }
}
