//
//  ProcessesStateUpdateBuilder.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.05.2025.
//

final class ProcessesStateUpdateBuilder {
    private var update = ProcessesStateUpdate()
    
    @discardableResult
    func withProcessesToKill (_ processesToKill: [ProcessInfo]?) -> Self {
        update.processesToKill = processesToKill
        return self
    }
    
    func build() -> ProcessesStateUpdate {
        update
    }
}
