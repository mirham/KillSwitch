//
//  NetworkEnforcementServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 12.05.2026.
//

protocol NetworkEnforcementServiceType {
    func enforceAsync(for result: OperationResult<IpInfoBase>) async
    func enforceIpAllowlistAsync() async
    func enforceIpApiAvailabilityAsync() async
}
