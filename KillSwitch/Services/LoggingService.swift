//
//  LoggingService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import Factory

final class LoggingService: LoggingServiceType {
    @Injected(\.appState) private var appState
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.logDateFormat
        return formatter
    }()
    
    func write(message: String, type: LogEntryType = .info) {
        let logEntry = LogEntry(message: message, type: type)
        
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            appState.log.insert(logEntry, at: 0)
        }
    }
    
    func copy() {
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            let logText = appState.log
                .map { "\(self.dateFormatter.string(from: $0.date)) [\($0.type.description.uppercased())] \($0.message)" }
                .joined(separator: "\n")
            
            AppHelper.copyTextToClipboard(text: logText)
        }
    }
    
    func clear() {
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            appState.log.removeAll()
        }
    }
}
