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
    
    let dateFormatter = DateFormatter()
    
    init(){
        dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss"
    }
    
    var body: some View {
        Section {
            ScrollViewReader { item in
                List(loggingService.logs) { log in
                    HStack{
                        Rectangle()
                            .foregroundColor(log.type == LogEntryType.error ? .red : log.type == LogEntryType.warning ? .yellow : .gray)
                            .frame(width: 4)
                            .cornerRadius(1.5)
                        Text("\(dateFormatter.string(from: log.date))")
                            .foregroundStyle(Color.gray)
                        Text("\(log.message)")
                            .foregroundStyle(Color.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .help(log.type.description)
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
