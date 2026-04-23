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
                .safeGlassEffect()
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup(id:Constants.windowIdMain) {
            MainView()
                .environmentObject(appState)
                .safeGlassEffect()
        }
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        
        WindowGroup(id: Constants.windowIdSettings) {
            SettingsView()
                .environmentObject(appState)
                .navigationTitle(Constants.settings)
                .safeGlassEffect()
                .frame(minWidth: 650, maxWidth: 650, minHeight: 520, maxHeight: 520)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        
        WindowGroup(id: Constants.windowIdKillProcessesConfirmationDialog) {
            KillProcessesDialogView()
                .environmentObject(appState)
                .hidden()
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdEnableNetworkDialog) {
            EnableNetworkDialogView()
                .environmentObject(appState)
                .hidden()
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdNoOneAllowedIpDialog) {
            MissingAllowedIpDialogView()
                .environmentObject(appState)
                .hidden()
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: Constants.windowIdInfo) {
            InfoView()
                .environmentObject(appState)
                .navigationTitle(Constants.info)
                .safeGlassEffect()
                .frame(minWidth: 360, maxWidth: 360, minHeight: 190, maxHeight: 190)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
