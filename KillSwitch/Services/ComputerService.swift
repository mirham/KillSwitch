//
//  ComputerManagementService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 24.06.2024.
//

import Foundation

class ComputerService : ServiceBase, ShellAccessible {
    static let shared = ComputerService()
    
    private var activity: NSObjectProtocol? = nil
    
    func startSleepPreventing() {
        guard appState.userData.preventComputerSleep else { return }
        
        activity = Foundation.ProcessInfo.processInfo.beginActivity(
            options: [Foundation.ProcessInfo.ActivityOptions.idleDisplaySleepDisabled,
                      Foundation.ProcessInfo.ActivityOptions.idleSystemSleepDisabled],
            reason: Constants.sleepPreventingReason)
        
        Log.write(message: Constants.logPreventComputerSleepEnabled)
    }
    
    func stopSleepPreventing() {
        guard activity != nil else { return }
        
        Foundation.ProcessInfo.processInfo.endActivity(activity!)
        
        Log.write(message: Constants.logPreventComputerSleepDisabled)
    }
    
    func reboot(){
        do {
            try rootShell(command: Constants.shCommandReboot)
            
            Log.write(message: Constants.logRebooting)
        }
        catch{
            Log.write(
                message: String(format: Constants.logCannotReboot, error.localizedDescription),
                type: LogEntryType.error)
        }
    }
}
