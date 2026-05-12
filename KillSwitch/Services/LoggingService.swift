//
//  LoggingService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import Factory
import AppKit

final class LoggingService: LoggingServiceType {
    @Injected(\.appState) private var appState
    
    private(set) var entriesCount = 0
    
    var isWritingToFile: Bool {
        FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    private var fileUrl: URL {
        let dateString = fileDateFormatter.string(from: .now)
        return logsDir.appendingPathComponent("\(dateString).\(Constants.logExtension)")
    }
    private let logsDir: URL
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private let fileDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
    
    init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask).first!
        logsDir = appSupport.appendingPathComponent(Constants.logPath)
        
        try? FileManager.default.createDirectory(
            at: logsDir,
            withIntermediateDirectories: true)
        
        cleanOldLogs()
    }
    
    func write(message: String, type: LogEntryType = .info) {
        let logEntry = LogEntry(message: message, type: type)
        
        entriesCount += 1
        
        writeToFile(logEntry)
        
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            appState.log.insert(logEntry, at: 0)
            
            if appState.log.count > Constants.logMaxInMemoryEntries {
                appState.log.removeLast()
            }
        }
    }
    
    func copy() {
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            let logText = appState.log
                .map { "\(self.dateFormatter.string(from: $0.date)) [\($0.type.description.uppercased())] \($0.message)" }
                .joined(separator: Constants.newline)
            
            AppHelper.copyTextToClipboard(text: logText)
        }
    }
    
    func clear() {
        entriesCount = 0
        
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            appState.log.removeAll()
            try? Data().write(to: fileUrl, options: .atomic)
        }
    }
    
    func openCurrentLog() {
        guard FileManager.default.fileExists(atPath: fileUrl.path)
        else { return }
        
        NSWorkspace.shared.open(fileUrl)
    }
    
    func openLogsFolder() {
        NSWorkspace.shared.open(logsDir)
    }
    
    // MARK: Private functions
    
    private func writeToFile(_ entry: LogEntry) {
        let line = "\(dateFormatter.string(from: entry.date)) [\(entry.type.description.uppercased())] \(entry.message)\(Constants.newline)"
        
        guard let data = line.data(using: .utf8)
        else { return }
        
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            if let handle = try? FileHandle(forWritingTo: fileUrl) {
                handle.seekToEndOfFile()
                handle.write(data)
                try? handle.close()
            }
        } else {
            try? data.write(to: fileUrl, options: .atomic)
        }
    }
    
    private func cleanOldLogs() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: logsDir, includingPropertiesForKeys: [.creationDateKey]) else { return }
        
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -Constants.logMaxLogAgeDays, to: .now)!
        
        for file in files where file.pathExtension == Constants.logExtension {
            guard let dateString = file.deletingPathExtension()
                    .lastPathComponent as String?,
                  let fileDate = fileDateFormatter.date(from: dateString),
                  fileDate < cutoffDate
            else { continue }
            
            try? FileManager.default.removeItem(at: file)
        }
    }
}
