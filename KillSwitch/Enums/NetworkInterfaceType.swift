//
//  NetworkStatus.swift
//  KillSwitch
//
//  Created by UglyGeorge on 09.06.2024.
//

import Foundation

enum NetworkInterfaceType : Int, CaseIterable {
    case unknown = 0
    case cellular = 1
    case loopback = 2
    case wifi = 3
    case wired = 4
    case other = 5
    case vpn = 6
}
