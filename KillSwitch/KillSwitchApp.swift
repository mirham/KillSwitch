//
//  KillSwitchApp.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

@main
struct KillSwitchApp: App {
    let appState = AppState.shared
    
    init() {
        _ = NetworkStatusService()
        _ = ProcessesService()
    }
    
    var body: some Scene {
        MenuBarExtra {
            VStack{
                MenuBarView()
                    .environmentObject(appState)
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(.windowBackground)
        } label: {
            MenuBarStatusView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup(id:Constants.windowIdMain, content: {
            MainView()
                .environmentObject(appState)
        })
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        
        WindowGroup(id:Constants.windowIdSettings, content: {
            SettingsView()
                .environmentObject(appState)
                .navigationTitle(Constants.settings)
                .frame(minWidth: 500, maxWidth: 500, minHeight: 500, maxHeight: 500)
        }).windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdKillProcessesConfirmationDialog, content: {
            KillProcessesConfirmationDialogView()
                .environmentObject(appState)
                .hidden()
        })
        .windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdEnableNetworkDialog, content: {
            EnableNetworkDialogView()
                .environmentObject(appState)
                .hidden()
        })
        .windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdNoOneAllowedIpDialog, content: {
            NoOneAllowedIpDialogView()
                .environmentObject(appState)
                .hidden()
        })
        .windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdInfo, content: {
            InfoView()
                .environmentObject(appState)
                .navigationTitle(Constants.info)
                .frame(minWidth: 360, maxWidth: 360, minHeight: 220, maxHeight: 220)
        })
        .windowResizability(.contentSize)
    }
}
