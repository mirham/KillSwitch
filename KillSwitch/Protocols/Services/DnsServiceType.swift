//
//  DnsServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.04.2026.
//

protocol DnsServiceType {
    @discardableResult
    func checkForLeakAsync() async -> Bool
    func startMonitoringAsync() async
    func stopMonitoringAsync() async
}
