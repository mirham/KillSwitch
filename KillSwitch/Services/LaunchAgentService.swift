//
//  LaunchAgentService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import Foundation
import Factory

final class LaunchAgentService: ShellAccessible, LaunchAgentServiceType {
    @LazyInjected(\.loggingService) private var loggingService
    
    private let fileManager = FileManager.default
    private(set) var isInstalled: Bool
    
    init() {
        isInstalled = (try? LaunchAgentService.plistFilePath())
            .map { FileManager.default.fileExists(atPath: $0) } ?? false
    }
    
    func create() -> Bool {
        guard let appPath = Bundle.main.executablePath
        else {
            loggingService.write(
                message: LaunchAgentError.executablePathNotFound.errorDescription ?? String(),
                type: .error)
            
            return false
        }
        
        guard let plistFilePath = try? LaunchAgentService.plistFilePath()
        else {
            loggingService.write(
                message: LaunchAgentError.libraryDirectoryNotFound.errorDescription ?? String(),
                type: .error)
            
            return false
        }
        
        do {
            try String(format: Constants.launchAgentXmlContent, appPath)
                .write(toFile: plistFilePath, atomically: true, encoding: .utf8)
            
            loggingService.write(
                message: Constants.logLaunchAgentAdded,
                type: .success)
            
            return true
        } catch {
            loggingService.write(
                message: LaunchAgentError.createFailed(
                    reason: error.localizedDescription).errorDescription ?? String(),
                type: .error)
            
            return false
        }
    }
    
    func delete() -> Bool {
        guard let plistFilePath = try? LaunchAgentService.plistFilePath()
        else {
            loggingService.write(
                message: LaunchAgentError.libraryDirectoryNotFound.errorDescription ?? String(),
                type: .error)
            
            return false
        }
        
        do {
            try fileManager.removeItem(atPath: plistFilePath)
            
            loggingService.write(
                message: Constants.logLaunchAgentRemoved,
                type: .success)
            
            return true
        } catch {
            loggingService.write(
                message: LaunchAgentError.deleteFailed(
                    reason: error.localizedDescription).errorDescription ?? String(),
                type: .error)
            
            return false
        }
    }
    
    func setState(isInstalled: Bool) {
        self.isInstalled = isInstalled
    }
    
    func apply() {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self
            else { return }
            
            do {
                if isInstalled {
                    try safeShell(String(
                        format: Constants.shCommandLoadLaunchAgent,
                        Constants.launchAgentsFolderPath,
                        Constants.launchAgentPlistName
                    ))
                } else {
                    try safeShell(String(
                        format: Constants.shCommandRemoveLaunchAgent,
                        Constants.launchAgentName
                    ))
                }
            } catch {
                loggingService.write(
                    message: LaunchAgentError.applyFailed(
                        reason: error.localizedDescription).errorDescription ?? String(),
                    type: .error)
            }
        }
    }
    
    // MARK: Private functions
    
    private static func plistFilePath() throws -> String {
        guard let libraryUrl = FileManager.default.urls(
            for: .libraryDirectory,
            in: .userDomainMask
        ).first else {
            throw LaunchAgentError.libraryDirectoryNotFound
        }
        
        return libraryUrl
            .appendingPathComponent(Constants.launchAgents)
            .appendingPathComponent(Constants.launchAgentPlistName)
            .path()
    }
}
