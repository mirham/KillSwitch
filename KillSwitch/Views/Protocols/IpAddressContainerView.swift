//
//  IpAddressContainerView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 30.07.2024.
//

import SwiftUI
import FlagKit

protocol IpAddressContainerView: View {}

extension IpAddressContainerView {
    func getSafetyColor(safetyType: SafetyType, colorScheme: ColorScheme) -> Color {
        let isDarkTheme = colorScheme == .dark
        
        switch safetyType {
            case .compete:
                return isDarkTheme
                ? .green
                : Color(hex: Constants.colorCompleteSafetyLightTheme)
            case .some:
                return isDarkTheme
                ? .yellow
                : Color(hex: Constants.colorSomeSafetyLightTheme)
            case .unsafe:
                return .red
            default:
                return (isDarkTheme ? Color.white : Color.black).opacity(0.7)
        }
    }
    
    func getCountryFlag(countryCode: String) -> NSImage {
        guard !countryCode.isEmpty
        else { return NSImage() }
        
        return Flag(countryCode: countryCode)?.originalImage ?? NSImage()
    }
}
