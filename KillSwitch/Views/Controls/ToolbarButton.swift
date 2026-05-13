//
//  ToolbarButton.swift
//  KillSwitch
//
//  Created by UglyGeorge on 21.04.2026.
//

import SwiftUI

struct ToolbarButton: View {
    let title: String
    let systemImage: String
    let isHovered: Bool
    let activeState: ControlActiveState
    let action: () -> Void
    
    var fontSize: CGFloat = 16
    var color: Color = .blue
    
    var body: some View {
        Button(title, systemImage: systemImage, action: action)
            .buttonStyle(.plain)
            .foregroundColor(isHovered && activeState == .key ? color : .gray)
            .focusEffectDisabled()
            .font(.system(size: fontSize))
            .opacity(activeState == .inactive ? 0.5 : 1.0)
            .pointerOnHover()
            .contentShape(Rectangle())
            .padding(.leading, 2)
            .padding(.trailing, 2)
    }
}
