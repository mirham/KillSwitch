//
//  LocationService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 24.06.2024.
//

import Foundation
import CoreLocation

class LocationService : ServiceBase, ShellAccessible {
    static let shared = LocationService()
    
    func isLocationServicesEnabled() -> Bool {
        let result = CLLocationManager.locationServicesEnabled()
        
        return result
    }
    
    func toggleLocationServices(isEnabled : Bool){
        do {
            try rootShell(command: String(format: Constants.shCommandToggleLocationServices, isEnabled.description))
            
            Log.write(
                message: String(format: Constants.logLocationServicesHaveBeenToggled, isEnabled ? Constants.enabled : Constants.disabled),
                type: LogEntryType.warning)
        }
        catch{
            Log.write(
                message: String(format: Constants.logCannotToggleLocationServices, error.localizedDescription),
                type: LogEntryType.error)
        }
    }
    
}
