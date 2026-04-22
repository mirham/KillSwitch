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
            
            guard !appState.system.processesToKill.isEmpty
            else { return }
            
            for process in appState.system.processesToKill {
                kill(process.pid, SIGTERM)
                loggingService.write(
                    message: String(format: Constants.logProcessTerminated, process.name),
                    type: .info)
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
                    useHigherProtection: self.appState.userData.useHigherProtection,
                    publicIp: self.appState.network.publicIp
                )}
                
                guard !snapshot.appsToClose.isEmpty
                else { continue }
                
                let activeProcesses = NSWorkspace.shared.runningApplications
                let processesToKill = buildProcessesToKill(
                    appsToClose: snapshot.appsToClose,
                    activeProcesses: activeProcesses
                )
                
                await updateStatusAsync {
                    $0.withProcessesToKill(processesToKill)
                }
                
                let shouldKill = !processesToKill.isEmpty
                && snapshot.isMonitoringEnabled
                && (snapshot.safetyType == .unsafe
                    || (snapshot.useHigherProtection
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
