//
//  AppManagementService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import Foundation
import SwiftUI

class AppManagementService{
    
    @Environment(\.openWindow) private var openWindow
    
    private let shellService = ShellService.shared
    private let loggingServie = LoggingService.shared
    
    let mainWindowId = "main-view"
    let settingsWindowId = "settings-view"
    
    let addressessSettingsKey = "allowed-addresses"
    let apisKey = "apis"
    
    var isMainViewShowed = false
    var isSettingsViewShowed = false
    var isLaunchAgentInstalled = false
    
    static let shared = AppManagementService()
    
    func showMainView(){
        if(!isMainViewShowed){
            openWindow(id: mainWindowId)
            isMainViewShowed = true
        
            let fileManager = FileManager.default
            let plistFilePath = getPlistFilePath()
            
            if(fileManager.fileExists(atPath: plistFilePath)) {
                isLaunchAgentInstalled = true
            }
        }
    }
    
    func showSettingsView(){
        if(!isSettingsViewShowed){
            openWindow(id: settingsWindowId)
            isSettingsViewShowed = true
        }
    }
    
    func setViewToTop(viewName: String){
        for window in NSApplication.shared.windows {
            let windowId = String(window.identifier?.rawValue ?? String())
            if(windowId.starts(with: viewName))
            {
                window.level = .floating
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            }
        }
    }
    
    func installLaunchAgent() -> Bool{
        let appPath = Bundle.main.executablePath
        let plistFilePath = getPlistFilePath()
        
        let xmlContent =
        """
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>user.launchkeep.KillSwitch</string>
                <key>KeepAlive</key>
                <true/>
                <key>Program</key>
                <string>\(appPath ?? String())</string>
            </dict>
        </plist>
        """;
        
        do {
            try xmlContent.write(toFile: plistFilePath, atomically: true, encoding: String.Encoding.utf8)
            try shellService.safeShell("launchctl load ~/Library/LaunchAgents/user.launchkeep.KillSwitch.plist")
            
            let logEntry = LogEntry(message: "Launch agent added, the application will be always running.")
            loggingServie.log(logEntry: logEntry)
            
            return true
        } catch {
            let logEntry = LogEntry(message: "Cannot add Launch agent: \(error.localizedDescription)")
            loggingServie.log(logEntry: logEntry)
            
            return false
        }
    }
    
    func uninstallLaunchAgent() -> Bool{
        do {
            try shellService.safeShell("launchctl remove user.launchkeep.KillSwitch.plist")
            
            let fileManager = FileManager.default
            let plistFilePath = getPlistFilePath()
            try fileManager.removeItem(atPath: plistFilePath)
            
            let logEntry = LogEntry(message: "Launch agent removed, the application, and won't be always running. Restart your Mac for applying changes.")
            loggingServie.log(logEntry: logEntry)
            
            return true
        }
        catch {
            let logEntry = LogEntry(message: "Cannot remove Launch agent: \(error.localizedDescription)")
            loggingServie.log(logEntry: logEntry)
            
            return false
        }
    }
    
    func readSettingsArray<T: Codable>(key: String) -> [T]? {
        if let objects = UserDefaults.standard.value(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [T] {
                return objectsDecoded
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func writeSettingsArray<T: Codable>(allObjects: [T], key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(allObjects){
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func quitApp(){
        NSApplication.shared.terminate(nil)
    }
    
    private func getPlistFilePath() -> String {
        let userDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor:.libraryDirectory, create: false)
        let launchDaemonsFolder = userDirectory.appendingPathComponent("LaunchAgents").appendingPathComponent("user.launchkeep.KillSwitch.plist")
        let filename = URL(fileURLWithPath: launchDaemonsFolder.path(), isDirectory: false)
        let result = filename.path()
        
        return result
    }
}
