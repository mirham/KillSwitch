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
                NetworkInterfacesView()
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
            AppHelper.setViewToTop(viewName: Constants.windowIdMain)
        })
        .onDisappear(perform: {
            appState.views.isMainViewShowed = false
        })
        .frame(minHeight: 600)
        .toolbar(content: {
            SettingsButtonView()
                .padding(.trailing)
        })
    }
}

#Preview {
    MainView().environmentObject(AppState())
}
