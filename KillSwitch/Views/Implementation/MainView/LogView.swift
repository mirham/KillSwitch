//
//  LogView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI

struct LogView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var selectedType: LogEntryType? = nil
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private var filteredEntries: [LogEntry] {
        guard let selectedType else { return appState.log }
        return appState.log.filter { $0.type == selectedType }
    }
    
    var body: some View {
        Section {
            VStack(spacing: 0) {
                filterBar
                Divider()
                logList
            }
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var filterBar: some View {
        HStack(spacing: 6) {
            filterButton(type: nil)
            filterButton(type: .info)
            filterButton(type: .success)
            filterButton(type: .warning)
            filterButton(type: .error)
            Spacer()
            Text(String(format: filteredEntries.count == 1
                        ? Constants.toolbarLogEntrty
                        : Constants.toolbarLogEntries,
                        filteredEntries.count))
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .focusable(false)
    }
    
    @ViewBuilder
    private func filterButton(type: LogEntryType?) -> some View {
        let isSelected = selectedType == type
        let color = type?.entryColor ?? .primary
        let label = type?.description ?? Constants.all
        
        Button {
            selectedType = (selectedType == type) ? nil : type
        } label: {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(isSelected ? color : Color.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(isSelected ? color.opacity(0.12) : Color.clear)
                .overlay(
                    Capsule().stroke(
                        isSelected ? color.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var logList: some View {
        if filteredEntries.isEmpty {
            emptyState
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) {
                        ForEach(filteredEntries) { entry in
                            LogEntryRow(entry: entry, dateFormatter: dateFormatter)
                                .id(entry.id)
                            
                            Divider()
                                .opacity(0.4)
                        }
                    }
                }
                .scrollIndicators(.visible)
                .onChange(of: appState.log.first?.id) { _, id in
                    guard let id else { return }
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(id, anchor: .top)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: Constants.iconEmptyLog)
                .font(.system(size: 24))
                .foregroundStyle(.tertiary)
            Text(Constants.hintNoLogEntries)
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    LogView().environmentObject(AppState())
}
