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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        _ = Container.shared.windowRegistry()
        _ = Container.shared.networkStatusService()
        _ = Container.shared.processService()
    }
    
    var body: some Scene {
        let appState = Container.shared.appState()
        
        return menuBar(appState: appState)
    }
    
    // MARK: View sections
    
    private func menuBar(appState: AppState) -> some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            MenuBarStatusView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button(Constants.about) {
                    Container.shared.windowManager().open(name: .info)
                }
            }
            CommandGroup(replacing: .appSettings) {
                Button(Constants.settingsTitle) {
                    Container.shared.windowManager().open(name: .settings)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            CommandGroup(replacing: .newItem) { }
        }
    }
}
