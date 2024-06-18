//
//  KillSwitchApp.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

@main
struct KillSwitchApp: App {
    let monitoringService = MonitoringService.shared
    let networkStatusService = NetworkStatusService.shared
    let addressesService = AddressesService.shared
    
    var body: some Scene {
        MenuBarExtra {
            VStack{
                MenuBarView()
                    .environmentObject(monitoringService)
                    .environmentObject(networkStatusService)
            }
            .frame(width: 300, height: 310)
            .background(.windowBackground)
        } label: {
            HStack {
                MenuBarStatusView()
                    .environmentObject(monitoringService)
            }
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup(id:"main-view", content: {
            MainView()
                .environmentObject(monitoringService)
                .environmentObject(networkStatusService)
        })
        
        WindowGroup(id:"settings-view", content: {
            SettingsView()
                .navigationTitle("Settings")
                .environmentObject(monitoringService)
                .environmentObject(addressesService)
                .frame(maxWidth: 500, maxHeight: 500)
        }).windowResizability(.contentSize)
    }
}
