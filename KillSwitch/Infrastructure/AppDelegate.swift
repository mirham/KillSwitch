//
//  AppDelegate.swift
//  KillSwitch
//
//  Created by UglyGeorge on 11.05.2026.
//

import SwiftUI
import Factory

final class AppDelegate: NSObject, NSApplicationDelegate {
    @Injected(\.appState) private var appState
    @Injected(\.windowRegistry) private var registry
    
    func orderFrontStandardAboutPanel(_ sender: Any?) {
        for window in NSApplication.shared.windows {
            if let identifier = window.identifier?.rawValue,
               identifier.starts(with: WindowType.info.rawValue) {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                return
            }
        }
        
        NSApplication.shared.orderFrontStandardAboutPanel(sender)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory) 
        registry.registerAll()
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
