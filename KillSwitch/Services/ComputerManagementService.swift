//
//  LocationService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 24.06.2024.
//

import Foundation
import CoreLocation

class ComputerManagementService {
    static let shared = ComputerManagementService()
    
    private let shellService = ShellService.shared
    private let loggingServie = LoggingService.shared
    
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
    
}
