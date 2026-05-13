//
//  LocationService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 24.06.2024.
//

import Foundation
import CoreLocation
import Factory

final class LocationService: ShellAccessible, LocationServiceType {
    @LazyInjected(\.loggingService) private var loggingService
    
    func areLocationServicesEnabled() -> Bool {
        CLLocationManager.locationServicesEnabled()
    }
    
    func toggleLocationServices(isEnabled: Bool) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self
            else { return }
            
            do {
                let flag = isEnabled ? Constants.enabled : Constants.disabled
                
                try rootShell(command: String(format: Constants.shCommandToggleLocationServices, flag))
                
                loggingService.write(
                    message: String(
                        format: Constants.logLocationServicesHaveBeenToggled,
                        flag),
                    type: .warning)
            } catch {
                loggingService.write(
                    message: LocationError.toggleFailed(
                        reason: error.localizedDescription).errorDescription ?? String(),
                    type: .error)
            }
        }
    }
}
