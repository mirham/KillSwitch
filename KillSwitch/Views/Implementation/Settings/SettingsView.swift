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
        VStack {
            HStack {
                Spacer()
                    .frame(width: 30)
                Text(Constants.settings)
                    .font(.headline)
                Spacer()
            }
            .offset(y: -25)
            FixedSidebarTabView {
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementGeneral,
                    icon: Constants.iconGear
                ) {
                    GeneralSettingsEditView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementMenubar,
                    icon: Constants.iconMenubar
                ) {
                    MenuBarStatusEditView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementAllowedIpAddresses,
                    icon: Constants.iconNetwork
                ) {
                    AllowedIpsEditView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementIpAddressApis,
                    icon: Constants.iconBulletRectangle
                ) {
                    IpApisEditView()
                        .environmentObject(appState)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementIpInfoApi,
                    icon: Constants.iconBulletRectangle
                ) {
                    IpInfoApiEditView()
                        .environmentObject(appState)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                FixedSidebarTabView.TabItem(
                    title: Constants.settingsElementClosingApps,
                    icon: Constants.iconClosingApps
                ) {
                    ClosingAppsEditView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onAppear { openView() }
        .onDisappear { closeView() }
        .opacity(getViewOpacity(state: controlActiveState))
    }
    
    // MARK: Private functions
    
    private func openView() {
        appState.views.shownWindows.append(Constants.windowIdSettings)
        
        AppHelper.setUpView(
            viewName: Constants.windowIdSettings,
            onTop: appState.userData.onTopOfAllWindows)
    }
    
    private func closeView() {
        appState.views.shownWindows.removeAll(where: {$0 == Constants.windowIdSettings})
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}
