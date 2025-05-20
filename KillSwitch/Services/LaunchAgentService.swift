//
//  LaunchAgentService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import Foundation

class LaunchAgentService : ServiceBase, ShellAccessible, LaunchAgentServiceType {
    var isInstalled = false
    
    override init() {
        super.init()
        
        let fileManager = FileManager.default
        let plistFilePath = getPlistFilePath()
        
        if(fileManager.fileExists(atPath: plistFilePath)) {
            isInstalled = true
        }
    }
    
    func create() -> Bool {
        let appPath = Bundle.main.executablePath
        let plistFilePath = getPlistFilePath()
        
        let xmlContent = String(format: Constants.launchAgentXmlContent, appPath!)
        
        do {
            try xmlContent.write(toFile: plistFilePath, atomically: true, encoding: String.Encoding.utf8)
            
            loggingService.write(
                message: String(format: Constants.logLaunchAgentAdded),
                type: .info)
            
            return true
        } catch {
            loggingService.write(
                message: String(format: Constants.logCannotAddLaunchAgent, error.localizedDescription),
                type: .error)
            
            return false
        }
    }
    
    func setState(isInstalled: Bool) {
        self.isInstalled = isInstalled
    }
    
    func apply() {
        do {
            if(isInstalled){
                try safeShell(String(format: Constants.shCommandLoadLaunchAgent, Constants.launchAgentsFolderPath, Constants.launchAgentPlistName))
            }
            else{
                try safeShell(String(format: Constants.shCommandRemoveLaunchAgent, Constants.launchAgentName))
            }
        }
        catch {}
    }
    
    func delete() -> Bool {
        do {
            let fileManager = FileManager.default
            let plistFilePath = getPlistFilePath()
            try fileManager.removeItem(atPath: plistFilePath)
            
            loggingService.write(
                message: String(format: Constants.logLaunchAgentRemoved),
                type: .info)
            
            return true
        }
        catch {
            loggingService.write(
                message: String(format: Constants.logCannotRemoveLaunchAgent, error.localizedDescription),
                type: .error)
            
            return false
        }
    }
    
    // MARK: Private functions
    
    private func getPlistFilePath() -> String {
        let userDirectory = try! FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor:.libraryDirectory,
            create: false)
        let launchAgentsFolder = userDirectory
            .appendingPathComponent(Constants.launchAgents)
            .appendingPathComponent(Constants.launchAgentPlistName)
        let filename = URL(fileURLWithPath: launchAgentsFolder.path(), isDirectory: false)
        let result = filename.path()
        
        return result
    }
}
