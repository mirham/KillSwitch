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
    let processsesService = ProcessesService.shared
    
    var body: some Scene {
        MenuBarExtra {
            VStack{
                MenuBarView()
                    .environmentObject(monitoringService)
                    .environmentObject(networkStatusService)
                    .environmentObject(appManagementService)
                    .environmentObject(processsesService)
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(.windowBackground)
        } label: {
            HStack {
                MenuBarStatusView()
                    .environmentObject(monitoringService)
                    .environmentObject(networkStatusService)
            }
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup(id:Constants.windowIdMain, content: {
            MainView()
                .environmentObject(monitoringService)
                .environmentObject(networkStatusService)
                .environmentObject(appManagementService)
                .environmentObject(processsesService)
        })
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        
        WindowGroup(id:Constants.windowIdSettings, content: {
            SettingsView()
                .navigationTitle(Constants.settings)
                .environmentObject(monitoringService)
                .environmentObject(addressesService)
                .environmentObject(processsesService)
                .frame(maxWidth: 500, maxHeight: 500)
        }).windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdKillProcessesConfirmationDialog, content: {
            KillProcessesConfirmationDialogView()
                .hidden()
        })
        .windowResizability(.contentSize)
    }
}
