//
//  LogView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation
import SwiftUI

struct LogView: View {
    @StateObject var loggingService = LoggingService.shared
    
    var body: some View {
        Section {
            ScrollViewReader { item in
                List(loggingService.logs) { log in
                    Text(log.date.ISO8601Format() + ":" + log.message)
                }
            }.environmentObject(loggingService).id(loggingService.scrollViewId)
        }
        .padding()
    }
}

extension LogEntry: Identifiable { }

#Preview {
    LogView()
}
