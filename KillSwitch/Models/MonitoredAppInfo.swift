//
//  MonitoredAppInfo.swift
//  KillSwitch
//
//  Created by UglyGeorge on 30.04.2026.
//

struct MonitoredAppInfo {
    let name: String
    let policy: BrowserPolicy
    
    static func chromium(
        name: String,
        profilesBasePath: String) -> MonitoredAppInfo {
        .init(
            name: name,
            policy: .chromium(profilesBasePath: profilesBasePath)
        )
    }
    
    static func firefox(name: String) -> MonitoredAppInfo {
        .init(
            name: name,
            policy: .firefox
        )
    }
    
    static func safari(name: String) -> MonitoredAppInfo {
        .init(
            name: name,
            policy: .safari
        )
    }
    
    static func businessApp(name: String) -> MonitoredAppInfo {
        .init(
            name: name,
            policy: .businessApp
        )
    }
}
