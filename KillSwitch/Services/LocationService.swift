//
//  LocationService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 24.06.2024.
//

import Foundation
import CoreLocation

class LocationService {
    static let shared = LocationService()
    
    private let shellService = ShellService.shared
    private let loggingServie = LoggingService.shared
    
    func isLocationServicesEnabled() -> Bool {
        let result = CLLocationManager.locationServicesEnabled()
        
        return result
    }
    
    func toggleLocationServices(isEnabled : Bool){
        do {
            try shellService.rootShell(command: String(format: Constants.shCommandToggleLocationServices, isEnabled.description))
            
            loggingServie.log(
                message: String(format: Constants.logLocationServicesHaveBeenToggled, isEnabled ? Constants.enabled : Constants.disabled),
                type: LogEntryType.warning)
        }
        catch{
            loggingServie.log(
                message: String(format: Constants.logCannotToggleLocationServices, error.localizedDescription),
                type: LogEntryType.error)
        }
    }
    
}
