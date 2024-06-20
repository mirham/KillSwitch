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
    
    var isMainViewShowed = false
    var isSettingsViewShowed = false
    var isLaunchAgentInstalled = false
    
    static let shared = AppManagementService()
    
    func showMainView(){
        if(!isMainViewShowed){
            openWindow(id: Constants.windowIdMain)
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
            openWindow(id: Constants.windowIdSettings)
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
        
        var xmlContent = String(format: Constants.launchAgentXmlContent, plistFilePath)
        
        do {
            try xmlContent.write(toFile: plistFilePath, atomically: true, encoding: String.Encoding.utf8)
            try shellService.safeShell("launchctl load ~/Library/LaunchAgents/user.launchkeep.KillSwitch.plist")
            
            loggingServie.log(message: String(format: Constants.logLaunchAgentAdded))
            
            return true
        } catch {
            loggingServie.log(message: String(format: Constants.logCannotAddLaunchAgent, error.localizedDescription))
            
            return false
        }
    }
    
    func uninstallLaunchAgent() -> Bool{
        do {
            try shellService.safeShell("launchctl remove user.launchkeep.KillSwitch.plist")
            
            let fileManager = FileManager.default
            let plistFilePath = getPlistFilePath()
            try fileManager.removeItem(atPath: plistFilePath)
            
            loggingServie.log(message: String(format: Constants.logLaunchAgentRemoved))
            
            return true
        }
        catch {
            loggingServie.log(message: String(format: Constants.logCannotRemoveLaunchAgent, error.localizedDescription))
            
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
