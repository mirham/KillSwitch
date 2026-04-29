//
//  NetworkInterfaceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 09.06.2024.
//

import SwiftUI

enum NetworkInterfaceType : Int, CaseIterable {
    case unknown = 0
    case cellular = 1
    case loopback = 2
    case wifi = 3
    case wired = 4
    case other = 5
    case vpn = 6
    
    var name: String {
        switch self {
            case .unknown:  return "Unknown"
            case .cellular: return "Cellular"
            case .loopback: return "Loopback"
            case .wifi: return "Wi-Fi"
            case .wired: return "Wired"
            case .other: return "Other"
            case .vpn: return "VPN"
        }
    }
    
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
            case .other, .unknown: return Constants.iconUnknownConnection
        }
    }
}
