//
//  LogView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI

struct LogView : View {
    @EnvironmentObject var appState: AppState
    
    @State private var showOverText = false
    
    private let dateFormatter = DateFormatter()
    
    init(){
        dateFormatter.dateFormat = Constants.logDateFormat
    }
    
    var body: some View {
        Section {
            ScrollViewReader { item in
                List(appState.log) { log in
                    HStack{
                        Rectangle()
                            .foregroundColor(determineBadgeColor(logEntryType: log.type))
                            .frame(width: 4)
                            .cornerRadius(1.5)
                        Text("\(dateFormatter.string(from: log.date))")
                            .foregroundStyle(Color.gray)
                        Text(log.message)
                            .foregroundStyle(Color.gray)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .help(log.type.description)
                }
                .textSelection(.enabled)
                .focusable(false)
            }
            .scrollIndicators(.visible)
        }
    }
    
    // MARK: Private functions
    
    private func determineBadgeColor(logEntryType: LogEntryType) -> Color {
        switch logEntryType {
            case .warning:
                return .yellow
            case .error:
                return .red
            default:
                return .gray
        }
    }
}

#Preview {
    LogView().environmentObject(AppState())
}
