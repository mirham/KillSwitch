//
//  WindowRegistry.swift
//  KillSwitch
//
//  Created by UglyGeorge on 14.05.2026.
//

import AppKit
import SwiftUI
import Factory

@MainActor
class WindowRegistry {
    private let manager: WindowManager
    private let appState: AppState = Container.shared.appState()
    
    init(manager: WindowManager) {
        self.manager = manager
        registerAll()
    }
    
    // MARK: Private functions
    
    private func registerAll() {
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
            NSHostingView(rootView: MissingAllowedIpDialogView()
                .environmentObject(self.appState))
        }
        manager.register(name: .dialogKillProcesses) {
            NSHostingView(rootView: KillProcessesDialogView()
                .environmentObject(self.appState))
        }
    }
}
