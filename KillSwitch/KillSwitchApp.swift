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
                .modelContainer(for: IpAddressModelNew.self)
        })
        
        WindowGroup(id:"settings-view", content: {
            SettingsView()
                .environmentObject(monitoringService)
                .environmentObject(networkStatusService)
                .modelContainer(for: IpAddressModelNew.self)
                .frame(maxWidth: 300, maxHeight: 450)
        }).windowResizability(.contentSize)
    }
}
