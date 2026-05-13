//
//  TypeExtensions.swift
//  KillSwitch
//
//  Created by UglyGeorge on 08.05.2026.
//

import SwiftUI

extension NetworkStatusType {
    func getColor(for colorScheme: ColorScheme) -> Color {
        switch self {
            case .on: return colorScheme == .dark
                ? Color(hex: Constants.colorOn)
                : Color(hex: Constants.colorGreenLightTheme)
            case .wait: return Color(hex: Constants.colorWait)
            case .off, .unknown: return Color(hex: Constants.colorOff)
        }
    }
    
    func getBackgroundColor(for colorScheme: ColorScheme) -> Color {
        getColor(for: colorScheme).opacity(0.10)
    }
    
    func getBorderColor(for colorScheme: ColorScheme) ->  Color {
        getColor(for: colorScheme).opacity(0.35)
    }
}

extension MonitoringStatusType {
    func getColor(for colorScheme: ColorScheme) -> Color {
        switch self {
            case .on: return colorScheme == .dark
                ? Color(hex: Constants.colorOn)
                : Color(hex: Constants.colorGreenLightTheme)
            case .off, .unknown: return Color(hex: Constants.colorOff)
        }
    }
    
    func getBackgroundColor(for colorScheme: ColorScheme) -> Color {
        getColor(for: colorScheme).opacity(0.10)
    }
    
    func getBorderColor(for colorScheme: ColorScheme) -> Color {
        getColor(for: colorScheme).opacity(0.35)
    }
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
