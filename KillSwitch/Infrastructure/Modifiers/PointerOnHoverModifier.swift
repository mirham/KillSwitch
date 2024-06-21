//
//  IsHiddenModifier.swift
//  KillSwitch
//
//  Created by UglyGeorge on 21.06.2024.
//

import SwiftUI

struct PointerOnHoverModifier: ViewModifier {
    func body(content: Content) -> some View {
         content.onHover(perform: { hovering in
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        })
    }
}
