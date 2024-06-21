//
//  AppManagementService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import Foundation
import SwiftUI

class AppManagementService : ObservableObject {
    @Published var isMainViewShowed = false
    @Published var isSettingsViewShowed = false
    
    var isLaunchAgentInstalled = false
    
    private let shellService = ShellService.shared
    private let loggingServie = LoggingService.shared
    
    static let shared = AppManagementService()
    
    init() {
        let fileManager = FileManager.default
        let plistFilePath = getPlistFilePath()
        
        if(fileManager.fileExists(atPath: plistFilePath)) {
            isLaunchAgentInstalled = true
        }
    }
    
    func showMainView() {
        isMainViewShowed = true
    }
    
    func showSettingsView() {
        isSettingsViewShowed = true
    }
    
    func setViewToTop(viewName: String) {
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
    
    func copyTextToClipboard(text : String) {
        guard !text.isEmpty else { return }
        
        NSPasteboard.general.declareTypes([.string], owner: nil)
        
        let pasteboard = NSPasteboard.general 
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    func installLaunchAgent() -> Bool {
        let appPath = Bundle.main.executablePath
        let plistFilePath = getPlistFilePath()
        
        let xmlContent = String(format: Constants.launchAgentXmlContent, appPath ?? String())
        
        do {
            try xmlContent.write(toFile: plistFilePath, atomically: true, encoding: String.Encoding.utf8)
            
            loggingServie.log(message: String(format: Constants.logLaunchAgentAdded))
            
            return true
        } catch {
            loggingServie.log(message: String(format: Constants.logCannotAddLaunchAgent, error.localizedDescription))
            
            return false
        }
    }
    
    func uninstallLaunchAgent() -> Bool {
        do {
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
    
    func readSetting<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        let result = try? JSONDecoder().decode(T.self, from: data)
        return result
    }
    
    func writeSetting<T: Codable>(newValue: T, key: String) {
        let data = try? JSONEncoder().encode(newValue)
        UserDefaults.standard.set(data, forKey: key)
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
    
    func quitApp() {
        do {
            if(isLaunchAgentInstalled){
                try shellService.safeShell(String(format: Constants.shellCommandLoadLaunchAgent, Constants.launchAgentsFolderPath, Constants.launchAgentPlistName))
            }
            else{
                try shellService.safeShell(String(format: Constants.shellCommandRemoveLaunchAgent, Constants.launchAgentName))
            }
        }
        catch {}
        
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: Private functions
    
    private func getPlistFilePath() -> String {
        let userDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor:.libraryDirectory, create: false)
        let launchAgentsFolder = userDirectory
            .appendingPathComponent("LaunchAgents")
            .appendingPathComponent(Constants.launchAgentPlistName)
        let filename = URL(fileURLWithPath: launchAgentsFolder.path(), isDirectory: false)
        let result = filename.path()
        
        return result
    }
}
