//
//  NetworkStatusType.swift
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
    
    var description : String {
        switch self {
            case .unknown: return "Unknown"
            case .on: return "On"
            case .off: return "Off"
            case .wait: return "Wait"
        }
    }
}
