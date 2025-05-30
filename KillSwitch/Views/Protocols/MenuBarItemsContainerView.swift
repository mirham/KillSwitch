//
//  MenuBarItemsContainerView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.07.2024.
//

import SwiftUI

protocol MenuBarItemsContainerView : IpAddressContainerView {
    func getMenuBarElements(
        keys: [String],
        appState: AppState,
        colorScheme: ColorScheme,
        exampleAllowed: Bool) -> [MenuBarElement]
}

extension MenuBarItemsContainerView {
    @MainActor 
    func getMenuBarElements(
        keys: [String],
        appState: AppState,
        colorScheme: ColorScheme,
        exampleAllowed: Bool = false) -> [MenuBarElement] {
        var result = [MenuBarElement]()
        
        let baseColor = colorScheme == .dark ? Color.white : Color.black
        let safetyColor = appState.userData.menuBarUseThemeColor
            ? baseColor
            : getSafetyColor(safetyType: appState.current.safetyType, colorScheme: colorScheme)
        let mainColor = appState.userData.menuBarUseThemeColor || !appState.monitoring.isEnabled
            ? baseColor
            : getSafetyColor(safetyType: appState.current.safetyType, colorScheme: colorScheme)
        
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
                        ipAddress: appState.network.publicIp == nil
                        ? appState.network.status == .off
                            ? Constants.offline
                            : Constants.none
                        : appState.network.publicIp!.ipAddress,
                        color: mainColor,
                        exampleAllowed: exampleAllowed)
                    let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: ipAddress), key: key)
                    result.append(menuBarItem)
                case Constants.mbItemKeyCountryCode:
                    let countryCode = getCountryCodeItem(
                        countryCode: appState.network.publicIp == nil
                            ? String()
                            : appState.network.publicIp!.countryCode,
                        color: mainColor,
                        exampleAllowed: exampleAllowed)
                    let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: countryCode), key: key)
                    result.append(menuBarItem)
                case Constants.mbItemKeyCountryFlag:
                    let countryFlag = getCountryFlagItem(
                        countryCode: appState.network.publicIp == nil
                            ? String()
                            : appState.network.publicIp!.countryCode,
                        exampleAllowed: exampleAllowed)
                    let menuBarItem = MenuBarElement(image: countryFlag, key: key)
                    result.append(menuBarItem)
                case Constants.mbItemKeySeparatorBullet:
                    let bullet = getBulletItem(color: baseColor)
                    let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: bullet), key: key, isSeparator: true)
                    result.append(menuBarItem)
                case Constants.mbItemKeySeparatorPipe:
                    let pipe = getPipeItem(color: baseColor)
                    let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: pipe), key: key, isSeparator: true)
                    result.append(menuBarItem)
                case Constants.mbItemKeySeparatorLeftBracket:
                    let leftBracket = getLeftBracketItem(color: baseColor)
                    let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: leftBracket), key: key, isSeparator: true)
                    result.append(menuBarItem)
                case Constants.mbItemKeySeparatorRightBracket:
                    let rightBracket = getRightBracketItem(color: baseColor)
                    let menuBarItem = MenuBarElement(image: renderMenuBarItemImage(view: rightBracket), key: key, isSeparator: true)
                    result.append(menuBarItem)
                default:
                    break
            }
        }
        
        return result
    }
    
    // MARK: Private functions
    @MainActor
    private func renderMenuBarItemImage(view: some View) -> NSImage {
        let result = view.renderAsImage() ?? NSImage()
        
        return result
    }
    
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
        let noIpAddress = ipAddress.isEmpty || ipAddress == Constants.none || ipAddress == Constants.offline
        let effectiveIpAddress = noIpAddress && exampleAllowed
            ? Constants.defaultIpAddress
            : ipAddress
        
        let result = Text(effectiveIpAddress.uppercased())
            .asOptionalMenuBarItem(color: color)
        
        return result
    }
    
    private func getCountryCodeItem(countryCode: String, color: Color, exampleAllowed: Bool) -> Text {
        let effectiveCountryCode = countryCode.isEmpty && exampleAllowed ? Constants.defaultCountryCode : countryCode
        
        let result = Text(effectiveCountryCode.uppercased())
            .asOptionalMenuBarItem(color: color)
        
        return result
    }
    
    private func getCountryFlagItem(countryCode: String, exampleAllowed: Bool) -> NSImage {
        let scale = 0.9
        let effectiveCountryCode = countryCode.isEmpty && exampleAllowed ? Constants.defaultCountryCode : countryCode
        let result = getCountryFlag(countryCode: effectiveCountryCode)
        result.size.width = result.size.width * scale
        result.size.height = result.size.height * scale
        
        return result
    }
    
    private func getBulletItem(color: Color) -> Text {
        let result = Text(Constants.bullet)
            .asOptionalMenuBarItem(color: color)
        
        return result
    }
    
    private func getPipeItem(color: Color) -> Text {
        let result = Text(Constants.pipe)
            .asOptionalMenuBarItem(color: color)
        
        return result
    }
    
    private func getLeftBracketItem(color: Color) -> Text {
        let result = Text(Constants.leftBracket)
            .asOptionalMenuBarItem(color: color)
        
        return result
    }
    
    private func getRightBracketItem(color: Color) -> Text {
        let result = Text(Constants.rightBracket)
            .asOptionalMenuBarItem(color: color)
        
        return result
    }
}

private extension Text {
    func asPrimaryMenuBarItem(color: Color) -> Text {
        self.font(.system(size: 16.0))
            .bold()
            .foregroundColor(color)
    }
    
    func asOptionalMenuBarItem(color: Color) -> Text {
        self.font(.system(size: 12.0))
            .foregroundColor(color)
    }
}
