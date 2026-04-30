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
    
    func killActiveProcesses() {
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            guard !appState.system.killingProcesses.isEmpty
            else { return }
            
            for process in appState.system.killingProcesses {
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
            guard let self
            else { return }
            
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: Constants.defaultProcessesMonitoringIntervalNanoseconds)
                
                guard !Task.isCancelled
                else { break }
                
                let snapshot = await MainActor.run {(
                    appsToClose: self.appState.userData.appsToClose,
                    isMonitoringEnabled: self.appState.monitoring.isEnabled,
                    safetyType: self.appState.current.safetyType,
                    useExtendedProtection: self.appState.userData.useExtendedProtection,
                    publicIp: self.appState.network.publicIp
                )}
                
                guard !snapshot.appsToClose.isEmpty
                else { continue }
                
                let activeProcesses = NSWorkspace.shared.runningApplications
                let killingProcesses = buildProcessesToKill(
                    appsToClose: snapshot.appsToClose,
                    activeProcesses: activeProcesses
                )
                let monitoringProcesses = buildProcessesToMonitor(
                    activeProcesses: activeProcesses)
                
                await updateStatusAsync {
                    $0.withKilllingProcesses(killingProcesses)
                    .withMonitoringProcesses(monitoringProcesses)
                }
                
                let shouldKill = !killingProcesses.isEmpty
                    && snapshot.isMonitoringEnabled
                    && (snapshot.safetyType == .unsafe
                        || (snapshot.useExtendedProtection
                        && snapshot.publicIp?.hasLocation() == false))
                
                if shouldKill {
                    killActiveProcesses()
                }
            }
        }
    }
    
    private func buildProcessesToKill(
        appsToClose: [AppInfo],
        activeProcesses: [NSRunningApplication]
    ) -> [ProcessInfo] {
        appsToClose.compactMap { appToClose in
            let escaped = appToClose.bundleId
                .replacingOccurrences(of: ".", with: "\\.")
                .replacingOccurrences(of: "(", with: "\\(")
                .replacingOccurrences(of: ")", with: "\\)")
            
            guard let regex = try? Regex(#".\#(escaped) - "#).ignoresCase()
            else {
                loggingService.write(
                    message: ProcessError.invalidRegex(bundleId: appToClose.bundleId).errorDescription ?? String(),
                    type: .error)
                
                return nil
            }
            
            guard let found = activeProcesses.first(where: { $0.description.contains(regex) })
            else { return nil }
            
            return ProcessInfo(
                pid: found.processIdentifier,
                description: found.description,
                url: appToClose.url,
                name: appToClose.name
            )
        }
    }
    
    private func buildProcessesToMonitor(
        activeProcesses: [NSRunningApplication]
    ) -> [ProcessInfo] {
        activeProcesses.compactMap { app in
            guard let appName = app.localizedName,
                  Constants.monitoredApps.contains(where: {
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
}
