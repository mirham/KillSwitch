//
//  LogEntryRow.swift
//  KillSwitch
//
//  Created by UglyGeorge on 23.04.2026.
//

import SwiftUI

struct LogEntryRow: View {
    let entry: LogEntry
    let dateFormatter: DateFormatter
    
    private var formattedLine: String {
        "[\(entry.type.description.uppercased())] \(dateFormatter.string(from: entry.date))  \(entry.message)"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(entry.type.entryColor)
                .frame(width: 3)
                .padding(.vertical, 2)
            Group {
                Text(dateFormatter.string(from: entry.date))
                    .foregroundStyle(Color.secondary.opacity(0.8))
                + Text(Constants.space)
                + Text(linksIn: entry.message)
                    .foregroundStyle(.primary.opacity(0.8))
            }
            .font(.system(size: 11, design: .monospaced))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
    }
}
