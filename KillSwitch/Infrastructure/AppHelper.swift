//
//  AppHelper.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.07.2024.
//

import SwiftUI

class AppHelper {
    static func copyTextToClipboard(text : String) {
        guard !text.isEmpty else { return }
        
        NSPasteboard.general.declareTypes([.string], owner: nil)
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

