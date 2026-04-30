//
//  ProcessesStateUpdateBuilder.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.05.2025.
//

final class ProcessesStateUpdateBuilder {
    private var update = ProcessesStateUpdate()
    
    @discardableResult
    func withKilllingProcesses (_ killingProcesses: [ProcessInfo]?) -> Self {
        update.killingProcesses = killingProcesses
        
        return self
    }
    
    func withMonitoringProcesses(_ monitoringProcesses: [ProcessInfo]?) -> Self {
        update.monitoringProcesses = monitoringProcesses
        
        return self
    }
    
    func build() -> ProcessesStateUpdate {
        update
    }
}
