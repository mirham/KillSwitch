//
//  WebRtcService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.04.2026.
//

import Foundation
import Factory

final class WebRtcService: WebRtcServiceType {
    @Injected(\.loggingService) private var logger
    @Injected(\.appState) private var appState
    
    private var pollingTask: Task<Void, Never>?
    private var checkedApps = Set<String>()
    private var previousRunningApps = Set<String>()
    
    private var shouldCheckForLeak: Bool {
        appState.monitoring.isEnabled
        && appState.userData.webRtcLeakCheck
        && appState.network.status == .on
    }
    
    deinit {
        pollingTask?.cancel()
    }
    
    func startMonitoring() {
        guard pollingTask == nil, shouldCheckForLeak
        else { return }
        
        logger.write(
            message: String(format: Constants.logWebRtcMonitoringStarted, Int(appState.userData.webRtcLeakCheckInterval)),
            type: .success
        )
        
        pollingTask = Task { [weak self] in
            guard let self
            else { return }
            
            while !Task.isCancelled {
                if shouldCheckForLeak {
                    await checkForLeakAsync()
                }
                try? await Task.sleep(for: .seconds(appState.userData.webRtcLeakCheckInterval))
            }
        }
    }
    
    func stopMonitoring() {
        if pollingTask != nil {
            logger.write(
                message: Constants.logWebRtcMonitoringStopped,
                type: .success)
        }
        
        pollingTask?.cancel()
        pollingTask = nil
        checkedApps.removeAll()
        previousRunningApps.removeAll()
    }
    
    // MARK: Private functions
    
    private func checkForLeakAsync() async {
        let current = currentRunningApps()
        let new = current.subtracting(previousRunningApps)
        let old = previousRunningApps.subtracting(current)
        
        checkedApps.subtract(old)
        
        if !new.isEmpty {
            let hasLeak = await evaluateNewAppsAsync(current: new)
            
            await updateStatusAsync { builder in
                builder.withHasWebRtcLeakIp(hasLeak)
            }
        }
        
        previousRunningApps = current
    }
    
    private func evaluateNewAppsAsync(current apps: Set<String>) async -> Bool {
        let newApps = Constants.monitoredApps.filter { app in
            let name = app.name.lowercased()
            return apps.contains(name) && !checkedApps.contains(name)
        }
        
        guard !newApps.isEmpty else {
            previousRunningApps = apps
            
            return appState.network.hasWebRtcLeak
        }
        
        var hasLeak = false
        
        await withTaskGroup(of: Bool.self) { group in
            for app in newApps {
                group.addTask { [weak self] in
                    await self?.evaluateAppAsync(app: app) ?? false
                }
            }
            
            for await leakDetected in group {
                if leakDetected { hasLeak = true }
            }
        }
        
        for app in newApps {
            checkedApps.insert(app.name.lowercased())
        }
        
        previousRunningApps = apps
        
        return hasLeak
    }
    
    private func evaluateAppAsync(app: MonitoredAppInfo) async -> Bool {
        switch app.policy {
            case .businessApp:
                log(
                    app: app.name,
                    message: Constants.logWebRtcBusinessAppWarning,
                    type: .warning
                )
                
                return true
            case .safari:
                log(
                    app: app.name,
                    message: Constants.logWebRtcSafariWarning,
                    type: .warning
                )
                
                return true
            case .chromium(let profilesBasePath):
                return await evaluateChromiumAsync(
                    app: app,
                    profilesBasePath: profilesBasePath)
            case .firefox:
                return await evaluateFirefoxAsync(app: app)
        }
    }
    
    private func evaluateChromiumAsync(
        app: MonitoredAppInfo,
        profilesBasePath: String) async -> Bool {
        let basePath = Constants.libraryBasePath.appending(profilesBasePath)
        
        let entries = await Task.detached(priority: .background) {
            try? FileManager.default.contentsOfDirectory(atPath: basePath)
        }.value
        
        guard let entries else {
            log(
                app: app.name,
                message: Constants.logWebRtcPrefsUnavailable,
                type: .warning
            )
            
            return true
        }
        
        let profileFolders = entries.filter {
            $0 == Constants.chromiumProfileDefault || $0.hasPrefix(Constants.chromiumProfile)
        }
        
        guard !profileFolders.isEmpty else {
            log(
                app: app.name,
                message: Constants.logWebRtcPrefsUnavailable,
                type: .warning
            )
            
            return true
        }
        
        var hasLeak = false
        
        await withTaskGroup(of: Bool.self) { group in
            for folder in profileFolders {
                group.addTask { [weak self] in
                    await self?.evaluateChromiumProfileAsync(
                        app: app,
                        basePath: basePath,
                        folder: folder
                    ) ?? false
                }
            }
            
            for await leakDetected in group {
                if leakDetected { hasLeak = true }
            }
        }
        
        return hasLeak
    }
    
    private func evaluateChromiumProfileAsync(
        app: MonitoredAppInfo,
        basePath: String,
        folder: String
    ) async -> Bool {
        let prefsPath = "\(basePath)/\(folder)/\(Constants.chromiumPrefsFile)"
        
        let result = await Task.detached(priority: .background) {
            guard let data = FileManager.default.contents(atPath: prefsPath),
                  let json = try? JSONSerialization.jsonObject(with: data)
                    as? [String: Any]
            else { return (found: false, policy: nil as String?) }
            
            let policy = (json[Constants.chromiumWebRtcKey]
                          as? [String: Any])?[Constants.chromiumIpHandlingKey]
            as? String
            return (found: true, policy: policy)
        }.value
        
        guard result.found else {
            log(
                app: app.name,
                message: Constants.logWebRtcPrefsUnavailable,
                type: .warning
            )
            
            return true
        }
        
        guard let policy = result.policy else {
            logger.write(
                message: String(
                    format: Constants.logWebRtcNoPolicy,
                    app.name,
                    folder),
                type: .warning
            )
            
            return true
        }
        
        let isSafe = Constants.chromiumSafePolicies.contains(policy)
        
        logger.write(
            message: String(
                format: Constants.logWebRtcChromiumPolicy,
                app.name,
                folder, policy),
            type: isSafe ? .success : .warning
        )
        
        return !isSafe
    }
    
    private func evaluateFirefoxAsync(app: MonitoredAppInfo) async -> Bool {
        let profilesPath = Constants.libraryBasePath.appending(Constants.firefoxProfilesPath)
        
        let allProfiles = await Task.detached(priority: .background) {
            try? FileManager.default
                .contentsOfDirectory(atPath: profilesPath)
                .filter { !$0.hasPrefix(Constants.dot) }
        }.value
        
        guard let allProfiles else {
            log(app: app.name, message: Constants.logWebRtcPrefsUnavailable, type: .warning)
            return true
        }
        
        var isProtected = false
        
        await withTaskGroup(of: Bool.self) { group in
            for profile in allProfiles {
                group.addTask { [weak self] in
                    await self?.evaluateFirefoxProfile(named: profile, profilesPath: profilesPath) ?? false
                }
            }
            
            for await leakDetected in group {
                if leakDetected { isProtected = true }
            }
        }
        
        return isProtected
    }
    
    private func evaluateFirefoxProfile(
        named profile:
        String, profilesPath: String) async -> Bool {
        let prefsPath = "\(profilesPath)/\(profile)\(Constants.firefoxPrefsFile)"
        
        let content = await Task.detached(priority: .background) {
            try? String(contentsOfFile: prefsPath, encoding: .utf8)
        }.value
        
        guard let content
        else { return false }
        
        let isProtected = content.contains(Constants.firefoxWebRtcDisabledEntry)
        
        logger.write(
            message: String(
                format: Constants.logWebRtcFirefoxProfile,
                profile,
                isProtected
                    ? Constants.logFirefoxProfileProtected
                    : Constants.logFirefoxProfileUnprotected
            ),
            type: isProtected ? .success : .warning
        )
        
        return !isProtected
    }
    
    private func currentRunningApps() -> Set<String> {
        Set(appState.system.monitoringProcesses.map { $0.name.lowercased() })
    }
    
    private func log(app: String, message: String, type: LogEntryType) {
        logger.write(message: String(format: message, app), type: type)
    }
    
    private func updateStatusAsync(_ configure: (NetworkStateUpdateBuilder) -> NetworkStateUpdateBuilder) async {
        guard !Task.isCancelled
        else { return }
        
        let update = configure(NetworkStateUpdateBuilder()).build()
        
        await MainActor.run {
            appState.applyNetworkUpdate(update)
        }
    }
}
