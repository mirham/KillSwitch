//
//  NetworkStatus.swift
//  KillSwitch
//
//  Created by UglyGeorge on 09.06.2024.
//

import Foundation

enum NetworkStatusType : Int, CaseIterable {
    case unknown = 0
    case on = 1
    case off = 2
    case wait = 3
}
