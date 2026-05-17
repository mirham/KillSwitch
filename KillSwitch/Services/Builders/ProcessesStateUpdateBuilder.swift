//
//  ProcessesStateUpdateBuilder.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.05.2025.
//

final class ProcessesStateUpdateBuilder {
    private var update = ProcessesStateUpdate()
    
    @discardableResult
    func withClosingProcesses (_ closingProcesses: [ProcessInfo]?) -> Self {
        update.closingProcesses = closingProcesses
        
        return self
    }
    
    func withWebRtcMonitoredProcesses(_ webRtcMonitoredProcesses: [ProcessInfo]?) -> Self {
        update.webRtcMonitoredProcesses = webRtcMonitoredProcesses
        
        return self
    }
    
    func build() -> ProcessesStateUpdate {
        update
    }
}
