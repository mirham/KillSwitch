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
    let appManagementService = AppManagementService.shared
    let computerManagementService = ComputerManagementService.shared
    
    var body: some Scene {
        MenuBarExtra {
            VStack{
                MenuBarView()
                    .environmentObject(monitoringService)
                    .environmentObject(networkStatusService)
                    .environmentObject(appManagementService)
                    .environmentObject(computerManagementService)
            }
            .frame(width:390, height:280)
            .background(.windowBackground)
        } label: {
            HStack {
                MenuBarStatusView()
                    .environmentObject(monitoringService)
                    .environmentObject(networkStatusService)
            }
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup(id:"main-view", content: {
            MainView()
                .environmentObject(monitoringService)
                .environmentObject(networkStatusService)
                .environmentObject(appManagementService)
                .environmentObject(computerManagementService)
        })
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        
        WindowGroup(id:"settings-view", content: {
            SettingsView()
                .navigationTitle("Settings")
                .environmentObject(monitoringService)
                .environmentObject(addressesService)
                .environmentObject(computerManagementService)
                .frame(maxWidth: 500, maxHeight: 500)
        }).windowResizability(.contentSize)
    }
}
