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
            ClosingApplicationsEditView()
                .tabItem {
                    Text(Constants.settingsElementClosingApps)
                }
        }
        .onAppear(perform: {
            openView()
        })
        .onDisappear(perform: {
            closeView()
        })
        .opacity(getViewOpacity(state: controlActiveState))
        .padding()
        .frame(maxWidth: 500, maxHeight: 500)
    }
    
    // MARK: Private functions
    
    private func openView() {
        appState.views.isSettingsViewShown = true
        AppHelper.setUpView(
            viewName: Constants.windowIdSettings,
            onTop: appState.userData.onTopOfAllWindows)
    }
    
    private func closeView() {
        appState.views.isSettingsViewShown = false
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}
