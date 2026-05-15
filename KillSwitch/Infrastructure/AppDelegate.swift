//
//  AppDelegate.swift
//  KillSwitch
//
//  Created by UglyGeorge on 11.05.2026.
//

import SwiftUI
import Factory

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    @Injected(\.appState) private var appState
    @Injected(\.windowManager) private var windowManager
    
    func orderFrontStandardAboutPanel(_ sender: Any?) {
        windowManager.open(name: .info)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard appState.monitoring.isEnabled
        else { return .terminateNow }
        
        let alert = NSAlert()
        alert.messageText = Constants.dialogHeaderCloseApp
        alert.informativeText = Constants.dialogBodyCloseApp
        alert.alertStyle = .warning
        
        let quitButton = alert.addButton(withTitle: Constants.quit)
        quitButton.hasDestructiveAction = true
        
        alert.addButton(withTitle: Constants.cancel)
        
        return alert.runModal() == .alertFirstButtonReturn
            ? .terminateNow
            : .terminateCancel
    }
}
