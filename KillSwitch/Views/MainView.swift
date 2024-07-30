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
            AppHelper.setUpView(
                viewName: Constants.windowIdMain,
                onTop: appState.userData.onTopOfAllWindows)
        })
        .onDisappear(perform: {
            appState.views.isMainViewShown = false
        })
        .frame(minHeight: 600)
        .toolbar(content: {
            ToolbarView()
                .padding(.trailing)
        })
    }
}

#Preview {
    MainView().environmentObject(AppState())
}
