//
//  ComputerManagementService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 24.06.2024.
//

import Foundation

class ComputerService : ServiceBase, ShellAccessible, ComputerServiceType {
    private var activity: NSObjectProtocol? = nil
    
    func startSleepPreventing() {
        guard appState.userData.preventComputerSleep else { return }
        
        activity = Foundation.ProcessInfo.processInfo.beginActivity(
            options: [Foundation.ProcessInfo.ActivityOptions.idleDisplaySleepDisabled,
                      Foundation.ProcessInfo.ActivityOptions.idleSystemSleepDisabled],
            reason: Constants.sleepPreventingReason)
        
        loggingService.write(
            message: Constants.logPreventComputerSleepEnabled,
            type: .info)
    }
    
    func stopSleepPreventing() {
        guard activity != nil else { return }
        
        Foundation.ProcessInfo.processInfo.endActivity(activity!)
        
        loggingService.write(
            message: Constants.logPreventComputerSleepDisabled,
            type: .info)
    }
    
    func reboot() {
        do {
            try rootShell(command: Constants.shCommandReboot)
            
            loggingService.write(
                message: Constants.logRebooting,
                type: .info)
        }
        catch {
            loggingService.write(
                message: String(format: Constants.logCannotReboot, error.localizedDescription),
                type: .error)
        }
    }
}
