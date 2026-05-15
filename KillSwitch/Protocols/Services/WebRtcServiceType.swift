//
//  WebRtcServiceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.04.2026.
//

protocol WebRtcServiceType {
    func startMonitoringAsync() async
    func stopMonitoringAsync() async
}
