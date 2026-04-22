//
//  ComputerManagementService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 24.06.2024.
//
import Foundation
import Factory

final class ComputerService: ShellAccessible, ComputerServiceType {
    @Injected(\.appState) private var appState
    @LazyInjected(\.loggingService) private var loggingService
    
    private var activity: NSObjectProtocol?
    
    func startSleepPreventing() {
        Task { @MainActor [weak self] in
            guard let self
            else { return }
            
            guard appState.userData.preventComputerSleep
            else { return }
            
            activity = Foundation.ProcessInfo.processInfo.beginActivity(
                options: [.idleDisplaySleepDisabled, .idleSystemSleepDisabled],
                reason: Constants.sleepPreventingReason
            )
            
            loggingService.write(
                message: Constants.logPreventComputerSleepEnabled,
                type: .info)
        }
    }
    
    func stopSleepPreventing() {
        guard let activity
        else { return }
        
        Foundation.ProcessInfo.processInfo.endActivity(activity)
        self.activity = nil
        
        loggingService.write(
            message: Constants.logPreventComputerSleepDisabled,
            type: .info)
    }
    
    func reboot() {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self
            else { return }
            
            do {
                try rootShell(command: Constants.shCommandReboot)
                loggingService.write(
                    message: Constants.logRebooting,
                    type: .info)
            } catch {
                loggingService.write(
                    message: ComputerError.rebootFailed(
                        reason: error.localizedDescription).errorDescription ?? String(),
                    type: .error)
            }
        }
    }
}
