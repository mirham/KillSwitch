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
        settingsTabView
            .opacity(opacityForControlState)
            .safeGlassEffect()
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
                    .fillMaxSize()
            }
            FixedSidebarTabView.TabItem(
                title: Constants.settingsElementLeaks,
                icon: Constants.iconLeak
            ) {
                LeaksEditView()
                    .fillMaxSize()
            }
            FixedSidebarTabView.TabItem(
                title: Constants.settingsElementMenubar,
                icon: Constants.iconMenubar
            ) {
                MenuBarStatusEditView()
                    .fillMaxSize()
            }
            FixedSidebarTabView.TabItem(
                title: Constants.settingsElementAllowedIpAddresses,
                icon: Constants.iconNetwork
            ) {
                AllowedIpsEditView()
                    .fillMaxSize()
            }
            FixedSidebarTabView.TabItem(
                title: Constants.settingsElementClosingApps,
                icon: Constants.iconClosingApps
            ) {
                ClosingAppsEditView()
                    .fillMaxSize()
            }
            FixedSidebarTabView.TabItem(
                title: Constants.settingsElementIpAddressApis,
                icon: Constants.iconBulletRectangle
            ) {
                IpApisEditView()
                    .fillMaxSize()
            }
            FixedSidebarTabView.TabItem(
                title: Constants.settingsElementIpInfoApi,
                icon: Constants.iconBulletRectangle
            ) {
                IpInfoApiEditView()
                    .fillMaxSize()
            }
            FixedSidebarTabView.TabItem(
                title: Constants.settingsElementPermissions,
                icon: Constants.iconPermissions
            ) {
                PermissionsView()
                    .fillMaxSize()
            }
        }
    }
    
    // MARK: Private functions
    
    private var opacityForControlState: Double {
        controlActiveState == .key ? 1 : 0.6
    }
}

private extension View {
    func fillMaxSize() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}
