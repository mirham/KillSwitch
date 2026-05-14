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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Injected(\.windowManager) private var windowManager
    
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
        } label: {
            MenuBarStatusView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
    }
    
    // MARK: Windows
    
    @SceneBuilder
    private var mainWindow: some Scene {
        WindowGroup(id: WindowType.main.rawValue) {
            MainView()
                .environmentObject(appState)
        }
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button(Constants.about) {
                    windowManager.open(name: .info)
                }
            }
            CommandGroup(replacing: .appSettings){
                Button(Constants.settingsTitle) {
                    windowManager.open(name: .main)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            CommandGroup(replacing: .newItem) { }
        }
    }
    
    @SceneBuilder
    private var settingsWindow: some Scene {
        Settings {
            SettingsView()
                .navigationTitle(Constants.settings)
                .environmentObject(appState)
        }
    }
    
    @SceneBuilder
    private var infoWindow: some Scene {
        WindowGroup(id: WindowType.info.rawValue) {
            InfoView()
                .navigationTitle(Constants.info)
                .environmentObject(appState)
        }
    }
    
    // MARK: Dialogs
    
    @SceneBuilder
    private var dialogsGroup: some Scene {
        WindowGroup(id: WindowType.dialogKillProcesses.rawValue) {
            KillProcessesDialogView()
                .environmentObject(appState)
                .hidden()
        }
        
        WindowGroup(id: WindowType.dialogEnableNetwork.rawValue) {
            EnableNetworkDialogView()
                .environmentObject(appState)
                .hidden()
        }
        
        WindowGroup(id: WindowType.dialogNoAllowedIp.rawValue) {
            MissingAllowedIpDialogView()
                .environmentObject(appState)
                .hidden()
        }
    }
}
