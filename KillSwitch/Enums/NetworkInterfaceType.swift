//
//  NetworkInterfaceType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 09.06.2024.
//

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
}
