//
//  MenuBarItemsContainerView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.07.2024.
//

import SwiftUI

@MainActor
protocol MenuBarItemsContainerView: IpAddressContainerView {
    func getMenuBarElements(
        keys: [String],
        appState: AppState,
        colorScheme: ColorScheme,
        exampleAllowed: Bool
    ) -> [MenuBarElement]
}

extension MenuBarItemsContainerView {
    @MainActor
    func getMenuBarElements(
        keys: [String],
        appState: AppState,
        colorScheme: ColorScheme,
        exampleAllowed: Bool = false
    ) -> [MenuBarElement] {
        let colors = MenuBarColors(
            base: colorScheme == .dark ? .white : .black,
            safety: appState.userData.menuBarUseThemeColor
            ? (colorScheme == .dark ? .white : .black)
            : getSafetyColor(safetyType: appState.current.safetyType, colorScheme: colorScheme),
            main: (appState.userData.menuBarUseThemeColor || !appState.monitoring.isEnabled)
            ? (colorScheme == .dark ? .white : .black)
            : getSafetyColor(safetyType: appState.current.safetyType, colorScheme: colorScheme)
        )
        
        let context = MenuBarContext(
            appState: appState,
            colors: colors,
            exampleAllowed: exampleAllowed
        )
        
        return keys.compactMap { key in
            buildMenuBarElement(for: key, context: context)
        }
    }
    
    @MainActor
    private func buildMenuBarElement(for key: String, context: MenuBarContext) -> MenuBarElement? {
        switch key {
            case Constants.mbItemKeyShield:
                return MenuBarElement(
                    image: renderImage {
                        getShieldIcon(
                            safetyType: context.appState.current.safetyType,
                            color: context.colors.safety)
                    },
                    key: key
                )
                
            case Constants.mbItemKeyMonitoringStatus:
                return MenuBarElement(
                    image: renderImage {
                        getMonitoringStatus(
                            isMonitoringEnabled: context.appState.monitoring.isEnabled,
                            color: context.colors.safety)
                    },
                    key: key
                )
                
            case Constants.mbItemKeyIpAddress:
                let ipText = resolveIpAddressText(
                    appState: context.appState,
                    exampleAllowed: context.exampleAllowed)
                return MenuBarElement(
                    image: renderImage {
                        getIpAddressItem(
                            ipText: ipText,
                            color: context.colors.main)
                    },
                    key: key
                )
                
            case Constants.mbItemKeyCountryCode:
                let code = resolveCountryCode(
                    appState: context.appState,
                    exampleAllowed: context.exampleAllowed)
                return MenuBarElement(
                    image: renderImage {
                        getCountryCodeItem(
                            countryCode: code,
                            color: context.colors.main)
                    },
                    key: key
                )
                
            case Constants.mbItemKeyCountryFlag:
                let code = resolveCountryCode(
                    appState: context.appState,
                    exampleAllowed: context.exampleAllowed)
                return MenuBarElement(
                    image: getCountryFlagItem(countryCode: code),
                    key: key
                )
                
            case Constants.mbItemKeySeparatorBullet:
                return MenuBarElement(
                    image: renderImage {
                        getSeparatorItem(
                            .bullet,
                            color: context.colors.base)
                    },
                    key: key,
                    isSeparator: true
                )
                
            case Constants.mbItemKeySeparatorPipe:
                return MenuBarElement(
                    image: renderImage {
                        getSeparatorItem(
                            .pipe,
                            color: context.colors.base)
                    },
                    key: key,
                    isSeparator: true
                )
                
            case Constants.mbItemKeySeparatorLeftBracket:
                return MenuBarElement(
                    image: renderImage {
                        getSeparatorItem(
                            .leftBracket,
                            color: context.colors.base)
                    },
                    key: key,
                    isSeparator: true
                )
                
            case Constants.mbItemKeySeparatorRightBracket:
                return MenuBarElement(
                    image: renderImage {
                        getSeparatorItem(
                            .rightBracket,
                            color: context.colors.base)
                    },
                    key: key,
                    isSeparator: true
                )
                
            default:
                return nil
        }
    }
    
    // MARK: View sections
    
    private func getShieldIcon(safetyType: SafetyType, color: Color) -> some View {
        let iconName: String
        switch safetyType {
            case .compete:
                iconName = Constants.iconCompleteSafety
            case .some:
                iconName = Constants.iconSomeSafety
            default:
                iconName = Constants.iconUnsafe
        }
        
        return Text(Image(systemName: iconName))
            .asPrimaryMenuBarItem(color: color)
            .bold()
    }
    
    @ViewBuilder
    private func getMonitoringStatus(
        isMonitoringEnabled: Bool,
        color: Color) -> some View {
        let status = (isMonitoringEnabled ? Constants.on : Constants.off).uppercased()
        
        Text(status)
            .asPrimaryMenuBarItem(color: color)
            .bold()
    }
    
    @ViewBuilder
    private func getIpAddressItem(
        ipText: String,
        color: Color) -> some View {
        Text(ipText.uppercased())
            .asOptionalMenuBarItem(color: color)
    }
    
    @ViewBuilder
    private func getCountryCodeItem(
        countryCode: String,
        color: Color) -> some View {
        Text(countryCode.uppercased())
            .asOptionalMenuBarItem(color: color)
    }
    
    private func getCountryFlagItem(countryCode: String) -> NSImage {
        let scale = 0.9
        let flag = getCountryFlag(countryCode: countryCode)
        
        flag.size = CGSize(
            width: flag.size.width * scale,
            height: flag.size.height * scale
        )
        
        return flag
    }
    
    // MARK: Private functions
    
    private func resolveIpAddressText(
        appState: AppState,
        exampleAllowed: Bool) -> String {
            let ip: String
            
            if appState.network.status == .off {
                ip = Constants.offline
            } else if appState.network.isObtainingIp {
                ip = Constants.obtainingIp
            } else {
                ip = appState.network.publicIp?.ipAddress ?? Constants.none
            }
            
            let noValidIp = ip.isEmpty || [Constants.none, Constants.offline, Constants.obtainingIp].contains(ip)
            
            return (noValidIp && exampleAllowed)
                ? Constants.defaultIpAddress
                : ip
        }
    
    private func resolveCountryCode(
        appState: AppState,
        exampleAllowed: Bool) -> String {
            let code = appState.network.publicIp?.countryCode ?? String()
            
            return (code.isEmpty && exampleAllowed)
                ? Constants.defaultCountryCode
                : code
        }
    
    @MainActor
    private func renderImage(@ViewBuilder content: () -> some View) -> NSImage {
        ImageRenderer(content: content()).nsImage ?? NSImage()
    }
    
    private func getSeparatorItem(_ type: SeparatorType, color: Color) -> some View {
        let symbol: String
        
        switch type {
            case .bullet:
                symbol = Constants.bullet
            case .pipe:
                symbol = Constants.pipe
            case .leftBracket:
                symbol = Constants.leftBracket
            case .rightBracket:
                symbol = Constants.rightBracket
        }
        
        return Text(symbol)
            .asOptionalMenuBarItem(color: color)
    }
}

private enum SeparatorType {
    case bullet, pipe, leftBracket, rightBracket
}

private struct MenuBarColors {
    let base: Color
    let safety: Color
    let main: Color
}

private struct MenuBarContext {
    let appState: AppState
    let colors: MenuBarColors
    let exampleAllowed: Bool
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
