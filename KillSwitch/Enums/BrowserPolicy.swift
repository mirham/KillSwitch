//
//  BrowserPolicy.swift
//  KillSwitch
//
//  Created by UglyGeorge on 30.04.2026.
//

enum BrowserPolicy: Codable {
    case chromium(profilesBasePath: String)
    case firefox
    case safari
    case businessApp
}
