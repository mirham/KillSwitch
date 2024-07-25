//
//  SettingsView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import SwiftUI

struct SettingsView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) var controlActiveState

    var body: some View {
        TabView {
            GeneralSettingsEditView()
                .tabItem {
                    Text(Constants.settingsElementGeneral)
                }
            /* MenuBarStatusEditView()
                 .tabItem {
                     Text("Menubar")
             } */
            AllowedIpsEditView()
                .tabItem {
                    Text(Constants.settingsElementAllowedIpAddresses)
                }
                .navigationSplitViewColumnWidth(250)
            IpApisEditView()
                .environmentObject(appState)
                .tabItem {
                    Text(Constants.settingsElementIpAddressApis)
                }
            ApplicationsToCloseEditView()
                .tabItem {
                    Text(Constants.settingsElementAppsToClose)
                }
        }
        .onAppear(perform: {
            AppHelper.setViewToTop(viewName: Constants.windowIdSettings)
        })
        .onDisappear(perform: {
            appState.views.isSettingsViewShowed = false
        })
        .opacity(getViewOpacity(state: controlActiveState))
        .padding()
        .frame(maxWidth: 500, maxHeight: 500)
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}
