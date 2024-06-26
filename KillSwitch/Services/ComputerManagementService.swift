//
//  LocationService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 24.06.2024.
//

import Foundation

class ComputerManagementService : ServiceBase {
    static let shared = ComputerManagementService()
    
    private let shellService = ShellService.shared
    
    func reboot(){
        do {
            try shellService.rootShell(command: Constants.shCommandReboot)
            
            loggingService.log(message: Constants.logRebooting)
        }
        catch{
            loggingService.log(
                message: String(format: Constants.logCannotReboot, error.localizedDescription),
                type: LogEntryType.error)
        }
    }
}
