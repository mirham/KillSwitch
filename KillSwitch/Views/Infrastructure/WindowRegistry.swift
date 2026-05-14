//
//  WindowRegistry.swift
//  KillSwitch
//
//  Created by UglyGeorge on 14.05.2026.
//

import AppKit
import SwiftUI

@MainActor
class WindowRegistry {

    private var appState: AppState
    private let manager: WindowManager
    
    init(manager: WindowManager, appState: AppState) {
        self.manager = manager
        self.appState = appState
    }
    
    func registerAll() {
        manager.register(name: .main) {
            NSHostingView(rootView: MainView()
                .environmentObject(self.appState))
        }
        manager.register(name: .settings) {
            NSHostingView(rootView: SettingsView()
                .environmentObject(self.appState))
        }
        manager.register(name: .info) {
            NSHostingView(rootView: InfoView()
                .environmentObject(self.appState))
        }
        manager.register(name: .dialogEnableNetwork) {
            NSHostingView(rootView: EnableNetworkDialogView()
                .environmentObject(self.appState))
        }
        manager.register(name: .dialogNoAllowedIp) {
            NSHostingView(rootView:MissingAllowedIpDialogView()
                .environmentObject(self.appState))
        }
        manager.register(name: .dialogKillProcesses) {
            NSHostingView(rootView: KillProcessesDialogView()
                .environmentObject(self.appState))
        }
    }
}
