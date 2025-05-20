//
//  LoggingServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

protocol LoggingServiceType {
    func write(message: String, type: LogEntryType)
    func copy()
    func clear()
}
