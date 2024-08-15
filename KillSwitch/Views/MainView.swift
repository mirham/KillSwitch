//
//  MainView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct MainView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) var controlActiveState
    
    var body: some View {
        NavigationSplitView {
            VStack{
                CurrentIpView()
                    .environmentObject(appState)
                    .padding(.top)
                Spacer()
                    .frame(height: 25)
                MonitoringStatusView()
                    .environmentObject(appState)
                    .padding(.top)
                NetworkStatusView()
                    .environmentObject(appState)
                    .padding(.top)
                ProcessesStatusView()
                    .environmentObject(appState)
                    .padding(.top)
                Spacer()
                    .frame(minHeight: 20)
                ActiveConnectionsView()
                    .environmentObject(appState)
            }
            .opacity(controlActiveState == .key ? 1 : 0.6)
            .navigationSplitViewColumnWidth(220)
        } detail: {
            VStack{
                LogView()
                    .environmentObject(appState)
            }
            .navigationSplitViewColumnWidth(min: 600, ideal: 600)
        }.onAppear(perform: {
            openView()
        })
        .onDisappear(perform: {
            closeView()
        })
        .frame(minHeight: 600)
        .toolbar(content: {
            ToolbarView()
                .padding(.trailing)
        })
    }
    
    // MARK: Private functions
    
    private func openView() {
        appState.views.isMainViewShown = true
        AppHelper.setUpView(
            viewName: Constants.windowIdMain,
            onTop: appState.userData.onTopOfAllWindows)
    }
    
    private func closeView() {
        appState.views.isMainViewShown = false
    }
}

#Preview {
    MainView().environmentObject(AppState())
}
