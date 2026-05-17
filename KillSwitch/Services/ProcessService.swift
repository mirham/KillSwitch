//
//  ProcessesService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 26.06.2024.
//

import Foundation
import AppKit
import Factory

final class ProcessService: ShellAccessible, ProcessServiceType {
    @Injected(\.appState) private var appState
    @LazyInjected(\.loggingService) private var loggingService
    
    private var monitoringTask: Task<Void, Never>?
    
    init() {
        startProcessesMonitoring()
    }
    
    deinit {
        monitoringTask?.cancel()
    }
    
    func killProcesses(processes: [ProcessInfo]) {
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            guard !processes.isEmpty
            else { return }
            
            for process in processes {
                kill(process.pid, SIGTERM)
                
                loggingService.write(
                    message: String(
                        format: Constants.logProcessTerminated,
                        process.name),
                    type: .success)
            }
        }
    }
    
    // MARK: Private methods
    
    private func startProcessesMonitoring() {
        monitoringTask = Task { [weak self] in
            guard let self else { return }
            
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: Constants.defaultProcessesMonitoringIntervalNanoseconds)
                
                guard !Task.isCancelled
                else { break }
                
                let snapshot = await captureSnapshot()
                let (closingApps, webRtcMonitoredApps) = await buildAndUpdateProcessesAsync(
                    snapshot: snapshot)
                
                if shouldKillClosingApps(
                    closingApps,
                    snapshot: snapshot) {
                    killProcesses(processes: closingApps)
                }
                
                if shouldKillWebRtcMonitoredApps(
                    webRtcMonitoredApps,
                    snapshot: snapshot) {
                    killProcesses(processes: webRtcMonitoredApps)
                }
            }
        }
    }
    
    private func captureSnapshot() async -> MonitoringSnapshot {
        await MainActor.run {
            MonitoringSnapshot(
                closingApps: appState.userData.closingApps,
                isMonitoringEnabled: appState.monitoring.isEnabled,
                autoCloseApps: appState.userData.autoCloseApps,
                securityType: appState.current.securityType,
                useExtendedProtection: appState.userData.useExtendedProtection,
                publicIp: appState.network.publicIp,
                hasDnsLeak: appState.network.hasDnsLeak,
                hasWebRtcLeak: appState.network.hasWebRtcLeak
            )
        }
    }
    
    private func buildAndUpdateProcessesAsync(
        snapshot: MonitoringSnapshot
    ) async -> (killing: [ProcessInfo], monitoring: [ProcessInfo]) {
        let activeProcesses = NSWorkspace.shared.runningApplications
        
        let closingApps = snapshot.closingApps.isEmpty
            ? []
            : buildProcessesToKill(
                closingApps: snapshot.closingApps,
                activeProcesses: activeProcesses)
        
        let webRtcMonitoredApps = buildProcessesToMonitor(
            activeProcesses: activeProcesses)
        
        await updateStatusAsync {
            $0.withClosingProcesses(closingApps)
                .withWebRtcMonitoredProcesses(webRtcMonitoredApps)
        }
        
        return (closingApps, webRtcMonitoredApps)
    }
    
    private func shouldKillClosingApps(
        _ processes: [ProcessInfo],
        snapshot: MonitoringSnapshot) -> Bool {
        let hasNetworkLeaks = snapshot.hasDnsLeak || snapshot.hasWebRtcLeak
        let isUnsafeForExtendedProtection = snapshot.useExtendedProtection
            && (snapshot.publicIp?.hasLocation() == false || hasNetworkLeaks)
        
        return !processes.isEmpty
            && snapshot.isMonitoringEnabled
            && snapshot.securityType == .notSecure
            && (snapshot.autoCloseApps || isUnsafeForExtendedProtection)
    }
    
    private func shouldKillWebRtcMonitoredApps(
        _ processes: [ProcessInfo],
        snapshot: MonitoringSnapshot) -> Bool {
        let hasNetworkLeaks = snapshot.hasDnsLeak || snapshot.hasWebRtcLeak
        
        return !processes.isEmpty
            && snapshot.isMonitoringEnabled
            && snapshot.useExtendedProtection
            && hasNetworkLeaks
    }

    
    private func buildProcessesToKill(
        closingApps: [AppInfo],
        activeProcesses: [NSRunningApplication]
    ) -> [ProcessInfo] {
        closingApps.compactMap { closingApp in
            let escaped = closingApp.bundleId
                .replacingOccurrences(of: ".", with: "\\.")
                .replacingOccurrences(of: "(", with: "\\(")
                .replacingOccurrences(of: ")", with: "\\)")
            
            guard let regex = try? Regex(#".\#(escaped) - "#).ignoresCase()
            else {
                loggingService.write(
                    message: ProcessError.invalidRegex(bundleId: closingApp.bundleId).errorDescription ?? String(),
                    type: .error)
                
                return nil
            }
            
            guard let found = activeProcesses.first(where: { $0.description.contains(regex) })
            else { return nil }
            
            return ProcessInfo(
                pid: found.processIdentifier,
                description: found.description,
                url: closingApp.url,
                name: closingApp.name
            )
        }
    }
    
    private func buildProcessesToMonitor(
        activeProcesses: [NSRunningApplication]
    ) -> [ProcessInfo] {
        activeProcesses.compactMap { app in
            guard let appName = app.localizedName,
                  Constants.webRtcMonitoredApps.contains(where: {
                      $0.name.caseInsensitiveCompare(appName) == .orderedSame
                  })
            else { return nil }
            
            return ProcessInfo(
                pid: app.processIdentifier,
                description: app.description,
                url: app.bundleIdentifier ?? appName,
                name: appName
            )
        }
    }
    
    private func updateStatusAsync(
        _ configure: (ProcessesStateUpdateBuilder) -> ProcessesStateUpdateBuilder
    ) async {
        guard !Task.isCancelled else { return }
        let update = configure(ProcessesStateUpdateBuilder()).build()
        await MainActor.run {
            appState.applyProcessesStateUpdate(update)
        }
    }
    
    // MARK: Inner types
    
    private struct MonitoringSnapshot {
        let closingApps: [AppInfo]
        let isMonitoringEnabled: Bool
        let autoCloseApps: Bool
        let securityType: SecurityType
        let useExtendedProtection: Bool
        let publicIp: IpInfoBase?
        let hasDnsLeak: Bool
        let hasWebRtcLeak: Bool
    }
}
