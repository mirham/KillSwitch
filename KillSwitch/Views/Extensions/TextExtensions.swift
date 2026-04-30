//
//  TextExtensions.swift
//  KillSwitch
//
//  Created by UglyGeorge on 30.04.2026.
//

import SwiftUI

extension String {
    var attributedWithLinks: AttributedString {
        var attributedString = AttributedString(self)
        
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        else {
            return attributedString
        }
        
        let nsString = self as NSString
        let matches = detector.matches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            if let url = match.url,
               let range = Range(match.range, in: attributedString) {
                attributedString[range].link = url
            }
        }
        
        return attributedString
    }
}

extension Text {
    init(linksIn text: String) {
        self.init(text.attributedWithLinks)
    }
}
