//
//  NetworkEnforcementServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 12.05.2026.
//

protocol NetworkEnforcementServiceType {
    func enforce(for result: OperationResult<IpInfoBase>)
    func enforceIpAllowlist()
    func enforceIpApiAvailability()
}
