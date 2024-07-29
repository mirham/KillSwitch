//
//  MenuBarItemsContainerView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.07.2024.
//

import SwiftUI

protocol MenuBarItemsContainerView : View {
    func getMenuBarElements(
        keys: [String],
        appState: AppState,
        colorScheme: ColorScheme,
        exampleAllowed: Bool) -> [MenuBarElement]
    func renderMenuBarItemImage(view: some View) -> NSImage
}

extension MenuBarItemsContainerView {
    @MainActor
    func renderMenuBarItemImage(view: some View) -> NSImage {
        let renderer = ImageRenderer(content: view)
        let result = renderer.nsImage
        
        return result!
    }
    
    func getMenuBarElements(
        keys: [String],
        appState: AppState,
        colorScheme: ColorScheme,
        exampleAllowed: Bool = false) -> [MenuBarElement] {
        var result = [MenuBarElement]()
        
        let baseColor = colorScheme == .dark ? Color.white : Color.black
        let safetyColor = appState.userData.menuBarUseThemeColor
            ? baseColor
            : getSafetyColor(safetyType: appState.current.safetyType)
        let mainColor = appState.userData.menuBarUseThemeColor || !appState.monitoring.isEnabled
            ? baseColor
            : getSafetyColor(safetyType: appState.current.safetyType)
        
        for key in keys {
            switch key {
                case Constants.mbItemKeyShield:
                    let shield = getShieldIconItem(
                        safetyType: appState.current.safetyType,
                        color: safetyColor)
                    let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: shield), key: key)
                    result.append(menuBarItem)
                case Constants.mbItemKeyMonitoringStatus:
                    let monitoringStatus = getMonitoringStatusItem(
                        isMonitoringEnabled: appState.monitoring.isEnabled,
                        color: safetyColor)
                    let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: monitoringStatus), key: key)
                    result.append(menuBarItem)
                case Constants.mbItemKeyIpAddress:
                    let ipAddress = getIpAddressItem(
                        ipAddress: appState.network.currentIpInfo == nil
                            ? Constants.none
                            : appState.network.currentIpInfo!.ipAddress,
                        color: mainColor,
                        exampleAllowed: exampleAllowed)
                    let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: ipAddress), key: key)
                    result.append(menuBarItem)
                case Constants.mbItemKeyCountryCode:
                    let countryCode = getCountryCodeItem(
                        countryCode: appState.network.currentIpInfo == nil
                            ? String()
                            : appState.network.currentIpInfo!.countryCode,
                        color: mainColor,
                        exampleAllowed: exampleAllowed)
                    let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: countryCode), key: key)
                    result.append(menuBarItem)
                case Constants.mbItemKeyCountryFlag:
                    let countryFlag = getCountryFlagItem(
                        countryCode: appState.network.currentIpInfo == nil
                            ? String()
                            : appState.network.currentIpInfo!.countryCode,
                        exampleAllowed: exampleAllowed)
                    let menuBarItem = MenuBarElement(image: countryFlag, key: key)
                    result.append(menuBarItem)
                default:
                    break
            }
        }
        
        return result
    }
    
    // MARK: Private functions
    
    private func getShieldIconItem(safetyType: SafetyType, color: Color) -> Text {
        var result: Text
        
        switch safetyType {
            case .compete:
                result = Text(Image(systemName:Constants.iconCompleteSafety))
            case .some:
                result = Text(Image(systemName:Constants.iconSomeSafety))
            default:
                result = Text(Image(systemName:Constants.iconUnsafe))
        }
        
        result = result
            .asPrimaryMenuBarItem(color: color)
            .bold()
        
        return result
    }
    
    private func getMonitoringStatusItem(isMonitoringEnabled: Bool, color: Color) -> Text {
        let result = Text((isMonitoringEnabled ? Constants.on : Constants.off).uppercased())
            .asPrimaryMenuBarItem(color: color)
            .bold()
        
        return result
    }
    
    private func getIpAddressItem(ipAddress: String, color: Color, exampleAllowed: Bool) -> Text {
        let effectiveIpAddress = (ipAddress.isEmpty || ipAddress == Constants.none) && exampleAllowed
            ? Constants.defaultIpAddress
            : ipAddress
        
        let result = Text(effectiveIpAddress)
            .asOptionalMenuBarItem(color: color)
        
        return result
    }
    
    private func getCountryCodeItem(countryCode: String, color: Color, exampleAllowed: Bool) -> Text {
        let effectiveCountryCode = countryCode.isEmpty && exampleAllowed ? Constants.defaultCountryCode : countryCode
        
        let result = Text(effectiveCountryCode)
            .asOptionalMenuBarItem(color: color)
        
        return result
    }
    
    private func getCountryFlagItem(countryCode: String, exampleAllowed: Bool) -> NSImage {
        let effectiveCountryCode = countryCode.isEmpty && exampleAllowed ? Constants.defaultCountryCode : countryCode
        let result = getCountryFlag(countryCode: effectiveCountryCode)
        
        return result
    }
}

private extension Text {
    func asPrimaryMenuBarItem(color: Color) -> Text {
        self.font(.system(size: 16.0))
            .foregroundColor(color)
            .bold()
    }
    
    func asOptionalMenuBarItem(color: Color) -> Text {
        self.font(.system(size: 12.0))
            .foregroundColor(color)
    }
}
