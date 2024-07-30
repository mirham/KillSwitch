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
            MenuBarStatusEditView()
                 .tabItem {
                     Text(Constants.settingsElementMenubar)
                 }
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
            AppHelper.setUpView(
                viewName: Constants.windowIdSettings,
                onTop: appState.userData.onTopOfAllWindows)
        })
        .onDisappear(perform: {
            appState.views.isSettingsViewShown = false
        })
        .opacity(getViewOpacity(state: controlActiveState))
        .padding()
        .frame(maxWidth: 500, maxHeight: 500)
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}
