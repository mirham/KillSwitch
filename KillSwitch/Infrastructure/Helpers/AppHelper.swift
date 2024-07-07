//
//  AppHelper.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.07.2024.
//

import SwiftUI

class AppHelper {    
    static func setViewToTop(viewName: String) {
        for window in NSApplication.shared.windows {
            let windowId = String(window.identifier?.rawValue ?? String())
            if(windowId.starts(with: viewName))
            {
                window.level = .floating
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            }
        }
    }
    
    static func copyTextToClipboard(text : String) {
        guard !text.isEmpty else { return }
        
        NSPasteboard.general.declareTypes([.string], owner: nil)
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

