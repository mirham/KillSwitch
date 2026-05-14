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
    
    var title: String {
        switch self {
            case .main: return String()
            case .menuBar: return String()
            case .settings: return Constants.settings
            case .dialogKillProcesses: return String()
            case .dialogEnableNetwork: return String()
            case .dialogNoAllowedIp: return String()
            case .info: return Constants.info
        }
    }
    
    var glassTitlebar: Bool {
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
    
    var hideTitleBar: Bool {
        switch self {
            case .main: return true
            case .menuBar: return true
            case .settings: return false
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
            case .main: return CGSize(width: 950, height: 650)
            case .menuBar: return nil
            case .settings: return CGSize(width: 650, height: 500)
            case .dialogKillProcesses: return nil
            case .dialogEnableNetwork: return nil
            case .dialogNoAllowedIp: return nil
            case .info: return nil
        }
    }
    
    var hiddenButtons: [ButtonType] {
        switch self {
            case .main: return []
            case .menuBar: return [.close, .miniaturize, .zoom]
            case .settings: return [.miniaturize, .zoom]
            case .dialogKillProcesses: return [.close, .miniaturize, .zoom]
            case .dialogEnableNetwork: return [.close, .miniaturize, .zoom]
            case .dialogNoAllowedIp: return [.close, .miniaturize, .zoom]
            case .info: return [.miniaturize, .zoom]
        }
    }
}
