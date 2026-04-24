//
//  BadgeModifier.swift
//  KillSwitch
//
//  Created by UglyGeorge on 21.04.2026.
//

import SwiftUI

struct BadgeModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 9, weight: .medium))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.25))
            .cornerRadius(4)
    }
}
