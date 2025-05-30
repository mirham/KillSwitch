//
//  MonitoringStateUpdateBuilder.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.05.2025.
//

final class MonitoringStateUpdateBuilder {
    private var update = MonitoringStateUpdate()
    
    @discardableResult
    func withIsMonitoringEnabled (_ isMonitoringEnabled: Bool) -> Self {
        update.isMonitoringEnabled = isMonitoringEnabled
        return self
    }
    
    @discardableResult
    func withPublicIp(_ publicIp: IpInfoBase?) -> Self {
        update.publicIp = publicIp
        return self
    }
    
    func build() -> MonitoringStateUpdate {
        update
    }
}
