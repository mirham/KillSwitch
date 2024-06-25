//
//  AppInfo.swift
//  KillSwitch
//
//  Created by UglyGeorge on 25.06.2024.
//

import Foundation

struct AppInfo: Codable, Identifiable, Equatable {
    var id = UUID()
    var url: String
    var name: String
    var executableName: String
    
    static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        return lhs.name.uppercased() == rhs.name.uppercased()
            && lhs.url.uppercased() == rhs.url.uppercased()
            && lhs.executableName.uppercased() == rhs.executableName.uppercased()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(url)
        hasher.combine(executableName)
    }
}
