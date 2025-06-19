//
//  KillSwitchApp.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI
import Factory

@main
struct KillSwitchApp: App {
    let appState = AppState.shared
    
    init() {
        _ = Container.shared.networkStatusService()
        _ = Container.shared.processService()
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
        
        WindowGroup(id:Constants.windowIdMain, makeContent: {
            MainView()
                .environmentObject(appState)
        })
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        
        WindowGroup(id:Constants.windowIdSettings, makeContent: {
            SettingsView()
                .environmentObject(appState)
                .navigationTitle(Constants.settings)
                .frame(minWidth: 550, maxWidth: 550, minHeight: 500, maxHeight: 500)
        }).windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdKillProcessesConfirmationDialog, makeContent: {
            KillProcessesConfirmationDialogView()
                .environmentObject(appState)
                .hidden()
        })
        .windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdEnableNetworkDialog, makeContent: {
            EnableNetworkDialogView()
                .environmentObject(appState)
                .hidden()
        })
        .windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdNoOneAllowedIpDialog, makeContent: {
            NoOneAllowedIpDialogView()
                .environmentObject(appState)
                .hidden()
        })
        .windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdInfo, makeContent: {
            InfoView()
                .environmentObject(appState)
                .navigationTitle(Constants.info)
                .frame(minWidth: 360, maxWidth: 360, minHeight: 220, maxHeight: 220)
        })
        .windowResizability(.contentSize)
    }
}
