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
        let isDarkTheme = colorScheme == .dark
        let baseColor = isDarkTheme ? Color.white : Color.black
        
        switch safetyType {
            case .compete:
                return isDarkTheme ? Color.green : Color(hex: "#369300")
            case .some:
                return isDarkTheme ? Color.yellow : Color(hex: "#A7A200")
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
