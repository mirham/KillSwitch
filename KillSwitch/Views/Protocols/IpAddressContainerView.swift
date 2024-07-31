//
//  IpAddressContainerView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 30.07.2024.
//

import SwiftUI
import FlagKit

protocol IpAddressContainerView : View {}

extension IpAddressContainerView {
    func getSafetyColor(safetyType: SafetyType, colorScheme: ColorScheme) -> Color {
        let baseColor = colorScheme == .dark ? Color.white : Color.black
        
        switch safetyType {
            case .compete:
                return Color.green
            case .some:
                return Color.yellow
            case .unsafe:
                return Color.red
            default:
                return baseColor.opacity(0.7)
        }
    }
    
    func getCountryFlag(countryCode: String) -> NSImage {
        return countryCode.isEmpty
        ? NSImage()
        : Flag(countryCode: countryCode)?.originalImage ?? NSImage()
    }
}
