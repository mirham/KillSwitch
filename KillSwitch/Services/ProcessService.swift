//
//  ProcessesService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 26.06.2024.
//

import Foundation
import AppKit

class ProcessService : ServiceBase, ShellAccessible, ProcessServiceType {
    private var monitoringTask: Task<Void, Never>?
    
    override init() {
        super.init()

        startProcessesMonitoring()
    }
    
    deinit {
        monitoringTask?.cancel()
    }
    
    func killActiveProcesses() {
        guard !appState.system.processesToKill.isEmpty else { return }
        
        for targetProcess in appState.system.processesToKill {
            kill(targetProcess.pid, SIGTERM)
            
            loggingService.write(
                message: String(format: Constants.logProcessTerminated, targetProcess.name),
                type: .info)
        }
    }
    
    // MARK: Privare functions
    
    private func startProcessesMonitoring() {
        monitoringTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: Constants.defaultProcessesMonitoringIntervalNanoseconds)
                
                guard self.appState.userData.appsToClose.count > 0 else { continue }
                
                do {
                    let activeProcesses = NSWorkspace.shared.runningApplications
                    
                    var processesToKill = [ProcessInfo]()
                    
                    for appToClose in self.appState.userData.appsToClose {
                        var escapedBundleId = appToClose.bundleId.replacingOccurrences(of: ".", with: "\\.")
                        escapedBundleId = escapedBundleId.replacingOccurrences(of: "(", with: "\\(")
                        escapedBundleId = escapedBundleId.replacingOccurrences(of: ")", with: "\\)")
                        let search = #".\#(escapedBundleId) - "#
                        let regex = try Regex(search).ignoresCase()
                        
                        let foundActiveProcess = activeProcesses.first{$0.description.contains(regex)}
                        
                        if (foundActiveProcess != nil) {
                            let info = ProcessInfo(
                                pid: foundActiveProcess!.processIdentifier,
                                description: foundActiveProcess!.description,
                                url: appToClose.url,
                                name: appToClose.name)
                            processesToKill.append(info)
                        }
                    }
                    
                    await self.updateStatusAsync(update: ProcessesStateUpdateBuilder()
                        .withProcessesToKill(processesToKill)
                        .build())
                    
                    let shouldKillProcesses = processesToKill.count > 0
                        && self.appState.monitoring.isEnabled
                        && (self.appState.current.safetyType == SafetyType.unsafe
                            || (self.appState.userData.useHigherProtection
                                && self.appState.network.publicIp != nil
                                && !self.appState.network.publicIp!.isConfirmed()))
                    
                    if shouldKillProcesses {
                        self.killActiveProcesses()
                    }
                } catch {
                    loggingService.write(
                        message: String(format: Constants.logErrorHandlingProcesses, error.localizedDescription),
                        type: .error)
                }
            }
        }
    }
    
    private func updateStatusAsync(update: ProcessesStateUpdate) async {
        await MainActor.run {
            appState.applyProcessesStateUpdate(update)
            appState.objectWillChange.send()
        }
    }
}
