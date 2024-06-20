//
//  LogEntry.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation

struct LogEntry: Equatable, Hashable {
    let id = UUID()
    let date = Date()
    let message: String
    let type: LogEntryType
}
