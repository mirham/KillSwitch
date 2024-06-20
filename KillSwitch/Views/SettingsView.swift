//
//  SettingsView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    let appManagementService = AppManagementService.shared

    var body: some View {
        TabView {
                GeneralSettingsEditView()
                    .tabItem {
                        Text("General")
                    }
                AllowedAddressesEditView()
                    .navigationSplitViewColumnWidth(250)
                    .tabItem {
                        Text("Allowed IP addresses")
                    }
                AddressApisEditView()
                    .tabItem {
                        Text("IP address APIs")
                    }
        }
        .onAppear(perform: {
            appManagementService.setViewToTop(viewName: "settings-view")
        })
        .onDisappear(perform: {
            appManagementService.isSettingsViewShowed = false
        })
        .padding()
        .frame(maxWidth: 500, maxHeight: 500)
    }
}

#Preview {
    SettingsView()
        .environmentObject(MonitoringService())
        .environmentObject(AddressesService())
}
