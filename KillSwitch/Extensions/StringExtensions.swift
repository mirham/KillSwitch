//
//  StringExtensions.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

import Foundation
import AppKit

extension String {
    func isValidIp() -> Bool {
        var result = false
        
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()
        
        if self.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            result = true
        }
        else if self.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            result = true
        }
        
        return result
    }
    
    func isValidUrl() -> Bool {
        do {
            let match = try Constants.regexUrl.wholeMatch(in: self)
            return match != nil
        }
        catch {
            return false
        }
    }
    
    static func copyToClipboard(input: String) {
        guard !input.isEmpty else { return }
        
        NSPasteboard.general.declareTypes([.string], owner: nil)
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(input, forType: .string)
    }
}

extension String: @retroactive Error {}
extension String: @retroactive LocalizedError {
    public var errorDescription: String? { return self }
}
