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
    @StateObject private var appState = AppState.shared
    
    init() {
        _ = Container.shared.networkStatusService()
        _ = Container.shared.processService()
    }
    
    var body: some Scene {
        menuBar
        mainWindow
        settingsWindow
        dialogsGroup
        infoWindow
    }
    
    // MARK: Menu bar
 
    @SceneBuilder
    private var menuBar: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
                .safeGlassEffect()
        } label: {
            MenuBarStatusView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
    }
    
    // MARK: Windows
    
    @SceneBuilder
    private var mainWindow: some Scene {
        WindowGroup(id: Constants.windowIdMain) {
            MainView()
                .environmentObject(appState)
                .safeGlassEffect()
        }
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
    }
    
    @SceneBuilder
    private var settingsWindow: some Scene {
        WindowGroup(id: Constants.windowIdSettings) {
            SettingsView()
                .environmentObject(appState)
                .navigationTitle(Constants.settings)
                .safeGlassEffect()
                .frame(minWidth: 650, maxWidth: 650, minHeight: 520, maxHeight: 520)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
    
    @SceneBuilder
    private var infoWindow: some Scene {
        WindowGroup(id: Constants.windowIdInfo) {
            InfoView()
                .environmentObject(appState)
                .navigationTitle(Constants.info)
                .safeGlassEffect()
                .fixedSize(horizontal: true, vertical: true)
                .frame(width: 360, height: 190)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
    
    // MARK: Dialogs
    
    @SceneBuilder
    private var dialogsGroup: some Scene {
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
    }
}
