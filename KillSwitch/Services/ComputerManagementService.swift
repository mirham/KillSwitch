//
//  LocationService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 24.06.2024.
//

import Foundation
import CoreLocation
import Darwin
import AppKit

class ComputerManagementService : ObservableObject {
    @Published var applicationsToClose = [AppInfo]()
    @Published var activeProcessesToClose = [ProcessInfo]()
    
    static let shared = ComputerManagementService()
    
    private let appManagementService = AppManagementService.shared
    private let shellService = ShellService.shared
    private let loggingServie = LoggingService.shared
    
    private var currentTimer: Timer? = nil
    
    init() {
        let savedAppsToClose: [AppInfo]? = appManagementService.readSettingsArray(key: Constants.settingsKeyAppsToClose)
        
        if(savedAppsToClose != nil){
            self.applicationsToClose = savedAppsToClose!
        }
        
        startProcessesMonitoring()
    }
    
    deinit {
        currentTimer?.invalidate()
    }
    
    func killActiveProcesses() {
        guard !activeProcessesToClose.isEmpty else { return }
        
        for activeProcessToClose in activeProcessesToClose {
            kill(activeProcessToClose.pid, SIGTERM)
        }
    }
    
    func reboot(){
        do {
            try shellService.rootShell(command: "reboot")
            
            loggingServie.log(message: Constants.logRebooting)
        }
        catch{
            loggingServie.log(
                message: String(format: Constants.logCannotReboot, error.localizedDescription),
                type: LogEntryType.error)
        }
    }
    
    // MARK: Privare functions
    
    private func startProcessesMonitoring() {
        currentTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            if self.applicationsToClose.count > 0 {
                Task {
                    do {
                        let useHigherProtection = self.appManagementService.readSetting(key: Constants.settingsKeyHigherProtection) ?? false
                        
                        let activeProcesses = NSWorkspace.shared.runningApplications
                        
                        var activeProcessesToClose = [ProcessInfo]()
                        
                        for appToClose in self.applicationsToClose {
                            let foundActiveProcess = activeProcesses.first{$0.description.contains(appToClose.executableName)}
                            
                            if (foundActiveProcess != nil) {
                                let info = ProcessInfo(pid: foundActiveProcess!.processIdentifier, description: foundActiveProcess!.description)
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
                self.activeProcessesToClose = activeProcessesToClose!
            }
                
            self.objectWillChange.send()
        }
    }
}
