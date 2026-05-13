//
//  MonitoringStatusType.swift
//  KillSwitch
//
//  Created by UglyGeorge on 08.05.2026.
//

import Foundation

enum MonitoringStatusType : Int, CaseIterable {
    case unknown = 0
    case on = 1
    case off = 2
    
    var description : String {
        switch self {
            case .unknown: return Constants.na
            case .on: return Constants.on
            case .off: return Constants.off
        }
    }
}
