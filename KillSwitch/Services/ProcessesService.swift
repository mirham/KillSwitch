//
//  ProcessesService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 26.06.2024.
//

import Foundation
import CoreLocation
import Darwin
import AppKit

class ProcessesService : ServiceBase, Settable, ShellAccessible {
    static let shared = ProcessesService()
    
    private var currentTimer: Timer? = nil
    
    override init() {
        super.init()

        startProcessesMonitoring()
    }
    
    deinit {
        currentTimer?.invalidate()
    }
    
    func killActiveProcesses() {
        guard !appState.system.processesToClose.isEmpty else { return }
        
        for activeProcessToClose in appState.system.processesToClose {
            kill(activeProcessToClose.pid, SIGTERM)
            Log.write(message: String(format: Constants.logProcessTerminated, activeProcessToClose.name))
        }
    }
    
    // MARK: Privare functions
    
    private func startProcessesMonitoring() {
        currentTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            if self.appState.userData.appsToClose.count > 0 {
                Task {
                    do {
                        let useHigherProtection = self.readSetting(key: Constants.settingsKeyHigherProtection) ?? false
                        
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
                        
                        if(!activeProcessesToClose.isEmpty && useHigherProtection){
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
                self.appState.system.processesToClose = activeProcessesToClose!
            }
            
            self.appState.objectWillChange.send()
        }
    }
}
