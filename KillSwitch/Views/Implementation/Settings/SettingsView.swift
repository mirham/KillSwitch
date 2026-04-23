//
//  SettingsView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.controlActiveState) private var controlActiveState
    
    var body: some View {
        VStack {
            headerView
            settingsTabView
        }
        .onAppear(perform: openView)
        .onDisappear(perform: closeView)
        .opacity(opacityForControlState)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var headerView: some View {
        HStack {
            Spacer()
                .frame(width: 30)
            Text(Constants.settings)
                .font(.headline)
            Spacer()
        }
        .offset(y: -25)
    }
    
    @ViewBuilder
    private var settingsTabView: some View {
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
    
    // MARK: Private functions
    
    private func openView() {
        appState.views.shownWindows.append(Constants.windowIdSettings)
        AppHelper.setUpView(
            viewName: Constants.windowIdSettings,
            onTop: appState.userData.onTopOfAllWindows
        )
    }
    
    private func closeView() {
        appState.views.shownWindows
            .removeAll { $0 == Constants.windowIdSettings }
    }
    
    private var opacityForControlState: Double {
        controlActiveState == .key ? 1 : 0.6
    }
}
#Preview {
    SettingsView().environmentObject(AppState())
}
