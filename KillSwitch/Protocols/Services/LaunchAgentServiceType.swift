//
//  LaunchAgentServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

protocol LaunchAgentServiceType {
    var isInstalled: Bool { get }
    
    func create() -> Bool
    func setState(isInstalled: Bool)
    func apply()
    func delete() -> Bool
}
