//
//  OpenWindowActionExtensions.swift
//  KillSwitch
//
//  Created by UglyGeorge on 12.05.2026.
//

import SwiftUI

extension OpenWindowAction {
    func openSingle(id: String, title: String) {
        if let existing = NSApp.windows.first(where: { $0.title == title }) {
            existing.makeKeyAndOrderFront(nil)
        } else {
            self(id: id)
        }
    }
}
