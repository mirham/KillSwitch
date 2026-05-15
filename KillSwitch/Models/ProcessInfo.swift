//
//  ProcessInfo.swift
//  KillSwitch
//
//  Created by UglyGeorge on 25.06.2024.
//

import Foundation

struct ProcessInfo: Equatable {
    var pid: pid_t
    var description: String
    var url: String
    var name: String
}
