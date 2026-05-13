//
//  MonitoredAppInfo.swift
//  KillSwitch
//
//  Created by UglyGeorge on 30.04.2026.
//

struct MonitoredAppInfo: Codable, Identifiable, Equatable {
    let name: String
    let policy: BrowserPolicy
    let configurable: Bool
    
    var id: String { name }
    var enabled: Bool = true
    
    static func chromium(
        name: String,
        profilesBasePath: String) -> MonitoredAppInfo {
        .init(
            name: name,
            policy: .chromium(profilesBasePath: profilesBasePath),
            configurable: true
        )
    }
    
    static func firefox(name: String) -> MonitoredAppInfo {
        .init(
            name: name,
            policy: .firefox,
            configurable: true
        )
    }
    
    static func safari(name: String) -> MonitoredAppInfo {
        .init(
            name: name,
            policy: .safari,
            configurable: true
        )
    }
    
    static func businessApp(name: String) -> MonitoredAppInfo {
        .init(
            name: name,
            policy: .businessApp,
            configurable: false
        )
    }
    
    static func == (lhs: MonitoredAppInfo, rhs: MonitoredAppInfo) -> Bool {
        return lhs.name.uppercased() == rhs.name.uppercased()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
