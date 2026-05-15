//
//  MainView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationSplitView {
            sidebarContent
                .navigationSplitViewColumnWidth(220)
        } detail: {
            detailContent
                .navigationSplitViewColumnWidth(min: 650, ideal: 650)
        }
        .frame(minHeight: 600)
        .safeGlassEffect()
        .toolbar {
            ToolbarView()
                .padding(.trailing)
        }
        .safeToolbarGlassEffect()
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var sidebarContent: some View {
        VStack {
            CurrentIpView(showDetailedIssues: true)
                .padding(.top)
            Spacer()
                .frame(height: 15)
            MonitoringStatusView()
            NetworkStatusView()
            ProcessesStatusView()
            Spacer()
                .frame(minHeight: 20)
            ActiveConnectionsView()
        }
    }
    
    @ViewBuilder
    private var detailContent: some View {
        VStack {
            LogView()
        }
    }
}

#Preview {
    MainView().environmentObject(AppState())
}
