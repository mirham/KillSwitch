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
                    Text("General")
                }
            /* MenuBarStatusEditView()
                 .tabItem {
                     Text("Menubar")
             } */
            AllowedAddressesEditView()
                .navigationSplitViewColumnWidth(250)
                .tabItem {
                    Text("Allowed IP addresses")
                }
            AddressApisEditView()
                .environmentObject(appState)
                .tabItem {
                    Text("IP address APIs")
                }
            ApplicationsToCloseEditView()
                .tabItem {
                    Text("Apps to close")
                }
        }
        .opacity(controlActiveState == .key ? 1 : 0.6)
        .onAppear(perform: {
            AppHelper.setViewToTop(viewName: Constants.windowIdSettings)
        })
        .onDisappear(perform: {
            appState.views.isSettingsViewShowed = false
        })
        .padding()
        .frame(maxWidth: 500, maxHeight: 500)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
