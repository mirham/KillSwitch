//
//  ViewExtensions.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.07.2024.
//

import SwiftUI

extension View {
    func isHidden(hidden: Bool = false, remove: Bool = false) -> some View {
        modifier(IsHiddenModifier(hidden: hidden, remove: remove))
    }
    
    func pointerOnHover() -> some View {
        modifier(PointerOnHoverModifier())
    }
    
    func getViewOpacity(state: ControlActiveState) -> Double {
        return state == .key ? 1 : 0.6
    }
}
