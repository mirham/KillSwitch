//
//  LoggingServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

protocol LoggingServiceType {
    var entriesCount: Int { get }
    var isWritingToFile: Bool { get }
    
    func write(message: String, type: LogEntryType)
    func copy()
    func clear()
    func openCurrentLog()
    func openLogsFolder()
}
