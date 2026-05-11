//
//  MainView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) private var controlActiveState
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
                .opacity(controlActiveState == .key ? 1 : 0.6)
                .navigationSplitViewColumnWidth(220)
        } detail: {
            detailContent
                .navigationSplitViewColumnWidth(min: 600, ideal: 600)
        }
        .frame(minHeight: 600)
        .toolbar {
            ToolbarView()
                .padding(.trailing)
        }
        .safeToolbarGlassEffect()
        .onAppear(perform: openView)
        .onDisappear(perform: closeView)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var sidebarContent: some View {
        VStack {
            CurrentIpView()
                .environmentObject(appState)
                .padding(.top)
            Spacer()
                .frame(height: 15)
            MonitoringStatusView()
                .environmentObject(appState)
            NetworkStatusView()
                .environmentObject(appState)
            ProcessesStatusView()
                .environmentObject(appState)
            Spacer()
                .frame(minHeight: 20)
            ActiveConnectionsView()
                .environmentObject(appState)
        }
    }
    
    @ViewBuilder
    private var detailContent: some View {
        VStack {
            LogView()
                .environmentObject(appState)
        }
    }
    
    // MARK: Private functions
    
    private func openView() {
        appState.views.shownWindows.append(Constants.windowIdMain)
        AppHelper.setUpView(
            viewName: Constants.windowIdMain,
            onTop: appState.userData.onTopOfAllWindows
        )
    }
    
    private func closeView() {
        appState.views.shownWindows
            .removeAll { $0 == Constants.windowIdMain }
    }
}

#Preview {
    MainView().environmentObject(AppState())
}
