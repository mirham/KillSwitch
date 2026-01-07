//
//  PointerOnHoverModifier.swift
//  KillSwitch
//
//  Created by UglyGeorge on 21.06.2024.
//

import SwiftUI

struct PointerOnHoverModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onHover { isHovering in
                DispatchQueue.main.async {
                    if isHovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
    }
}
