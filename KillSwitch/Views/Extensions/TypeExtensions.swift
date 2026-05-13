//
//  TypeExtensions.swift
//  KillSwitch
//
//  Created by UglyGeorge on 08.05.2026.
//

import SwiftUI

extension NetworkStatusType {
    var color: Color {
        switch self {
            case .on: return Color(hex: Constants.colorOn)
            case .wait: return Color(hex: Constants.colorWait)
            case .off, .unknown: return Color(hex: Constants.colorOff)
        }
    }
    
    var backgroundColor: Color { color.opacity(0.10) }
    var borderColor: Color { color.opacity(0.35) }
}

extension MonitoringStatusType {
    var color: Color {
        switch self {
            case .on: return Color(hex: Constants.colorOn)
            case .off, .unknown: return Color(hex: Constants.colorOff)
        }
    }
    
    var backgroundColor: Color { color.opacity(0.10) }
    var borderColor: Color { color.opacity(0.35) }
}

extension NetworkInterfaceType {
    var color: Color {
        switch self {
            case .vpn: return .orange
            case .wifi: return .blue
            case .wired: return .green
            case .loopback: return .purple
            case .cellular: return .teal
            default: return .gray
        }
    }
    
    var icon: String {
        switch self {
            case .cellular: return Constants.iconCellular
            case .loopback: return Constants.iconLoopback
            case .vpn: return Constants.iconVpn
            case .wifi: return Constants.iconWifi
            case .wired: return Constants.iconWired
            case .other: return Constants.iconOtherConnection
            case .unknown: return Constants.iconUnknownConnection
        }
    }
}
