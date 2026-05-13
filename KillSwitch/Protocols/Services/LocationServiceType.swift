//
//  LocationServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

protocol LocationServiceType {
    func areLocationServicesEnabled() -> Bool
    func toggleLocationServices(isEnabled : Bool)
}
