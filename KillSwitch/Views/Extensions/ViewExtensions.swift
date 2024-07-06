//
//  ViewExtensions.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.07.2024.
//

import SwiftUI
import FlagKit

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
    
    func getSafetyColor(safetyType: SafetyType) -> Color {
        switch safetyType {
            case .compete:
                return Color.green
            case .some:
                return Color.yellow
            default:
                return Color.red
        }
    }
    
    func getCountryFlag(countryCode: String) -> NSImage {
        return countryCode.isEmpty 
            ? NSImage()
            : Flag(countryCode: countryCode)?.originalImage ?? NSImage()
    }
}
