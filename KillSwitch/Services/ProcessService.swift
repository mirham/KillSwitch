//
//  ProcessesService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 26.06.2024.
//

import Foundation
import AppKit

class ProcessService : ServiceBase, ShellAccessible, ProcessServiceType {
    private var currentTimer: Timer? = nil
    
    override init() {
        super.init()

        startProcessesMonitoring()
    }
    
    deinit {
        currentTimer?.invalidate()
    }
    
    func killActiveProcesses() {
        guard !appState.system.processesToKill.isEmpty else { return }
        
        for activeProcessToClose in appState.system.processesToKill {
            kill(activeProcessToClose.pid, SIGTERM)
            
            loggingService.write(
                message: String(format: Constants.logProcessTerminated, activeProcessToClose.name),
                type: .info)
        }
    }
    
    // MARK: Privare functions
    
    private func startProcessesMonitoring() {
        currentTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            if self.appState.userData.appsToClose.count > 0 {
                Task {
                    do {
                        let activeProcesses = NSWorkspace.shared.runningApplications
                        
                        var activeProcessesToClose = [ProcessInfo]()
                        
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
                                activeProcessesToClose.append(info)
                            }
                        }
                        
                        self.updateStatus(activeProcessesToClose: activeProcessesToClose)
                        
                        if (!activeProcessesToClose.isEmpty
                            && self.appState.userData.useHigherProtection
                            && self.appState.monitoring.isEnabled
                            && self.appState.network.status == .on
                            && !self.appState.current.isCurrentIpAllowed) {
                            self.killActiveProcesses()
                        }
                    }
                }
            }
        }
    }
    
    private func updateStatus(activeProcessesToClose: [ProcessInfo]? = nil) {
        DispatchQueue.main.async {
            if activeProcessesToClose != nil {
                self.appState.system.processesToKill = activeProcessesToClose!
            }
            
            self.appState.objectWillChange.send()
        }
    }
}
