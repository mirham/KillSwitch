//
//  ComputerManagementService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 24.06.2024.
//

import Foundation

class ComputerManagementService : ServiceBase, ShellAccessible {
    static let shared = ComputerManagementService()
    
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
