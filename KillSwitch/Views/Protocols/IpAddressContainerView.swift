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
    func getSecurityColor(securityType: SecurityType, colorScheme: ColorScheme) -> Color {
        let isDarkTheme = colorScheme == .dark
        
        switch securityType {
            case .full:
                return isDarkTheme
                ? .green
                : Color(hex: Constants.colorGreenLightTheme)
            case .partial:
                return isDarkTheme
                ? .yellow
                : Color(hex: Constants.colorYellowLightTheme)
            case .notSecure:
                return .red
            default:
                return (isDarkTheme ? Color.white : Color.black).opacity(0.7)
        }
    }
    
    func getLeakColor(
        areLeakChecksEnabled: Bool,
        hasLeak: Bool,
        colorScheme: ColorScheme) -> Color {
        let isDarkTheme = colorScheme == .dark
        
        guard areLeakChecksEnabled
        else { return (isDarkTheme ? Color.white : Color.black).opacity(0.7) }
        
        if hasLeak {
            return .red
        }
        else {
            return isDarkTheme
                ? .green
                : Color(hex: Constants.colorGreenLightTheme)
        }
    }
    
    func getVpnColor(isVpnConnected: Bool, colorScheme: ColorScheme) -> Color {
        let isDarkTheme = colorScheme == .dark
        
        if isVpnConnected {
            return isDarkTheme
            ? .green
            : Color(hex: Constants.colorGreenLightTheme)
        }
        else {
            return (isDarkTheme ? Color.white : Color.black).opacity(0.7)
        }
    }
    
    func getCountryFlag(countryCode: String) -> NSImage {
        guard !countryCode.isEmpty
        else { return NSImage() }
        
        return Flag(countryCode: countryCode)?.originalImage ?? NSImage()
    }
}
