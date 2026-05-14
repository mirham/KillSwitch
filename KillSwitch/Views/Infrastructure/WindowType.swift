//
//  WindowType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 14.05.2026.
//

import Foundation

enum WindowType: String, Hashable {
    case main = "main-view"
    case menuBar = "menubar-view"
    case settings = "settings-view"
    case dialogKillProcesses = "dialog-kill-processess"
    case dialogEnableNetwork = "dialog-enable-network"
    case dialogNoAllowedIp = "dialog-no-allowed-ip"
    case info = "info-view"
    
    var hideTitleBar: Bool {
        switch self {
            case .main: return true
            case .menuBar: return true
            case .settings: return true
            case .dialogKillProcesses: return true
            case .dialogEnableNetwork: return true
            case .dialogNoAllowedIp: return true
            case .info: return true
        }
    }
    
    var resizable: Bool {
        switch self {
            case .main: return true
            case .menuBar: return false
            case .settings: return false
            case .dialogKillProcesses: return false
            case .dialogEnableNetwork: return false
            case .dialogNoAllowedIp: return false
            case .info: return false
        }
    }
    
    var size: CGSize? {
        switch self {
            case .main: return nil
            case .menuBar: return nil
            case .settings: return nil
            case .dialogKillProcesses: return nil
            case .dialogEnableNetwork: return nil
            case .dialogNoAllowedIp: return nil
            case .info: return nil
        }
    }
}
