//
//  AppState.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.07.2024.
//

import SwiftUI
import CoreLocation

class AppState : ObservableObject, Equatable {
    @Published var log = [LogEntry]()
    
    @Published var current = Current()
    @Published var views = Views(shownWindows: [String()])
    @Published var monitoring = Monitoring() { didSet { setCurrentState() } }
    @Published var system = System() { didSet { setCurrentState() } }
    @Published var network = Network() { didSet { setCurrentState() } }
    @Published var userData = UserData() { didSet { setCurrentState() } }
    
    static let shared = AppState()
    
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        let result = lhs.current == rhs.current
        && lhs.monitoring == rhs.monitoring
        && lhs.network == rhs.network
        
        return result
    }
    
    func applyMonitoringUpdate(_ update: MonitoringStateUpdate) {
        if update.isMonitoringEnabled != nil {
            monitoring.isEnabled = update.isMonitoringEnabled!
        }
        
        if update.publicIp != nil {
            network.publicIp = update.publicIp
        }
    }
    
    func applyNetworkUpdate(_ update: NetworkStateUpdate) {
        var updatedNetwork = Network()
        
        if update.status != nil {
            updatedNetwork.status = update.status!
            
            if network.status != .on && update.status == .on {
                reactivateIpApis()
            }
        }
        else {
            updatedNetwork.status = network.status
        }
        
        updatedNetwork.publicIp = update.forceUpdatePublicIp ? update.publicIp : network.publicIp
        updatedNetwork.activeNetworkInterfaces = update.activeNetworkInterfaces ?? network.activeNetworkInterfaces
        updatedNetwork.physicalNetworkInterfaces = update.physicalNetworkInterfaces ?? network.physicalNetworkInterfaces
        updatedNetwork.isObtainingIp = update.isObtainingIp ?? network.isObtainingIp
        
        if network != updatedNetwork {
            network = updatedNetwork
        }
    }
    
    func applyProcessesStateUpdate (_ update: ProcessesStateUpdate) {
        if update.processesToKill != nil {
            system.processesToKill = update.processesToKill!
        }
    }
    
    // MARK: Private functions
    
    private func setCurrentState() {
        current.safetyType = determineSafetyType()
        current.isPublicIpAllowed = getCurrentAllowedIp() != nil
        current.isHighRisk = isHighRisk()
        current.isCountryDetected = isCountryDetected()
        current.mainNetworkInterface = findMainInterface()
    }
}

extension AppState {
    struct Current : Equatable {
        var safetyType = SafetyType.unknown
        var isPublicIpAllowed = false
        var isHighRisk = false
        var isCountryDetected = false
        var mainNetworkInterface = String()
        var colorScheme: ColorScheme = .light
        
        static func == (lhs: Current, rhs: Current) -> Bool {
            let result = lhs.safetyType == rhs.safetyType
            && lhs.isHighRisk == rhs.isHighRisk
            && lhs.isPublicIpAllowed == rhs.isPublicIpAllowed
            
            return result
        }
    }
}

extension AppState {
    struct Views {
        var shownWindows: [String]
    }
}

extension AppState {
    struct Monitoring : Settable, Equatable {
        var isEnabled = false {
            didSet { writeSetting(newValue: isEnabled, key: Constants.settingsKeyIsMonitoringEnabled) }
        }
        
        init() {
            isEnabled = readSetting(key: Constants.settingsKeyIsMonitoringEnabled) ?? false
        }
        
        static func == (lhs: Monitoring, rhs: Monitoring) -> Bool {
            let result = lhs.isEnabled == rhs.isEnabled
            
            return result
        }
    }
}

extension AppState {
    struct System {
        var locationServicesEnabled: Bool {
            get { return CLLocationManager.locationServicesEnabled() }
        }
        var processesToKill = [ProcessInfo]()
    }
}

extension AppState {
    struct Network : Equatable {
        var status: NetworkStatusType = NetworkStatusType.unknown
        var isObtainingIp = false
        var activeNetworkInterfaces: [NetworkInterface] = [NetworkInterface]()
        var physicalNetworkInterfaces: [NetworkInterface] = [NetworkInterface]()
        var publicIp: IpInfoBase? = nil
        
        func isConnectionChanged (
            status: NetworkStatusType,
            activeNetworkInterfaces: [NetworkInterface]) -> Bool {
                let result = self.status != status || self.activeNetworkInterfaces != activeNetworkInterfaces
                return result
            }
        
        static func == (lhs: Network, rhs: Network) -> Bool {
            let result = lhs.status == rhs.status
            && lhs.publicIp == rhs.publicIp
            && lhs.publicIp?.hasLocation() == rhs.publicIp?.hasLocation()
            && lhs.isObtainingIp == rhs.isObtainingIp
            && lhs.activeNetworkInterfaces == rhs.activeNetworkInterfaces
            && lhs.physicalNetworkInterfaces == rhs.physicalNetworkInterfaces
            
            return result
        }
    }
    
    // MARK: Private functions
    
    private func reactivateIpApis() {
        for index in 0..<userData.ipApis.count {
            if !userData.ipApis[index].isActive() {
                userData.ipApis[index].active = true
            }
        }
    }
}

extension AppState {
    struct UserData : Settable, Equatable {
        var ipApis = [IpApiInfo]() {
            didSet { writeSettingsArray(newValues: ipApis, key: Constants.settingsKeyApis) }
        }
        var allowedIps = [IpInfo]() {
            didSet { writeSettingsArray(newValues: allowedIps, key: Constants.settingsKeyIps) }
        }
        var appsToClose = [AppInfo]() {
            didSet { writeSettingsArray(newValues: appsToClose, key: Constants.settingsKeyAppsToClose) }
        }
        var useHigherProtection: Bool = false {
            didSet { writeSetting(newValue: useHigherProtection, key: Constants.settingsKeyHigherProtection) }
        }
        var intervalBetweenChecks: Int = Constants.defaultIntervalBetweenChecksInSeconds {
            didSet { writeSetting(newValue: intervalBetweenChecks, key: Constants.settingsKeyIntervalBetweenChecks) }
        }
        var pickyMode: Bool = true {
            didSet { writeSetting(newValue: pickyMode, key: Constants.settingsKeyUsePickyMode) }
        }
        var periodicIpCheck: Bool = false {
            didSet { writeSetting(newValue: periodicIpCheck, key: Constants.settingsKeyPeriodicIpCheck) }
        }
        var autoCloseApps: Bool = false {
            didSet { writeSetting(newValue: autoCloseApps, key: Constants.settingsKeyAutoCloseApps) }
        }
        var appsCloseConfirmation: Bool = false {
            didSet { writeSetting(newValue: appsCloseConfirmation, key: Constants.settingsKeyConfirmationApplicationsClose) }
        }
        var menuBarShownItems = Constants.defaultShownMenuBarItems {
            didSet { writeSettingsArray(newValues: menuBarShownItems, key: Constants.settingsKeyShownMenuBarItems) }
        }
        var menuBarHiddenItems = Constants.defaultHiddenMenuBarItems {
            didSet { writeSettingsArray(newValues: menuBarHiddenItems, key: Constants.settingsKeyHiddenMenuBarItems) }
        }
        var menuBarUseThemeColor: Bool = false {
            didSet { writeSetting(newValue: menuBarUseThemeColor, key: Constants.settingsKeyMenuBarUseThemeColor) }
        }
        var onTopOfAllWindows: Bool = false {
            didSet { writeSetting(newValue: onTopOfAllWindows, key: Constants.settingsKeyOnTopOfAllWindows) }
        }
        var preventComputerSleep: Bool = false {
            didSet { writeSetting(newValue: preventComputerSleep, key: Constants.settingsKeyPreventComputerSleep) }
        }
        var ipInfoApiUrl: String = Constants.defaultIpInfoApiUrl {
            didSet { writeSetting(newValue: ipInfoApiUrl, key: Constants.settingsKeyIpInfoApiUrl) }
        }
        var ipInfoApiKeyMapping: [String:String] = Constants.defaultIpInfoApiKeyMapping {
            didSet { writeSettingsDictionary(newValues: ipInfoApiKeyMapping, key: Constants.settingsKeyIpInfoMapping) }
        }
        
        static func == (lhs: UserData, rhs: UserData) -> Bool {
            let result = lhs.menuBarUseThemeColor == rhs.menuBarUseThemeColor
            
            return result
        }
        
        init() {
            useHigherProtection = readSetting(key: Constants.settingsKeyHigherProtection) ?? false
            intervalBetweenChecks = readSetting(key: Constants.settingsKeyIntervalBetweenChecks) ?? Constants.defaultIntervalBetweenChecksInSeconds
            pickyMode = readSetting(key: Constants.settingsKeyUsePickyMode) ?? true
            periodicIpCheck = readSetting(key: Constants.settingsKeyPeriodicIpCheck) ?? true
            autoCloseApps = readSetting(key: Constants.settingsKeyAutoCloseApps) ?? false
            appsCloseConfirmation = readSetting(key: Constants.settingsKeyConfirmationApplicationsClose) ?? true
            onTopOfAllWindows = readSetting(key: Constants.settingsKeyOnTopOfAllWindows) ?? false
            preventComputerSleep = readSetting(key: Constants.settingsKeyPreventComputerSleep) ?? false
            menuBarUseThemeColor = readSetting(key: Constants.settingsKeyMenuBarUseThemeColor) ?? false
            
            if let savedAllowedIps: [IpInfo] = readSettingsArray(key: Constants.settingsKeyIps) {
                allowedIps = savedAllowedIps
            }
            
            if let savedIpApis: [IpApiInfo] = readSettingsArray(key: Constants.settingsKeyApis) {
                ipApis = savedIpApis
            }
            else {
                for ipApiUrl in Constants.ipApiUrls {
                    let apiInfo = IpApiInfo(url: ipApiUrl, active: true)
                    ipApis.append(apiInfo)
                }
            }
            
            if let savedAppsToClose:[AppInfo] = readSettingsArray(key: Constants.settingsKeyAppsToClose) {
                appsToClose = savedAppsToClose
            }
            
            if let savedMenuBarShownItems:[String] = readSettingsArray(key: Constants.settingsKeyShownMenuBarItems) {
                menuBarShownItems = savedMenuBarShownItems
            }
            
            if let savedMenuBarHiddenItems: [String] = readSettingsArray(key: Constants.settingsKeyHiddenMenuBarItems) {
                menuBarHiddenItems = savedMenuBarHiddenItems
            }
        }
        
        func getRandomActiveIpApi() -> IpApiInfo? {
            let result = ipApis.filter({$0.isActive()}).randomElement()
            
            return result
        }
        
        func hasActiveIpApi() -> Bool {
            return !ipApis.isEmpty && ipApis.contains(where: {$0.isActive()})
        }
    }
}

extension AppState {
    private func determineSafetyType() -> SafetyType {
        if (monitoring.isEnabled && network.publicIp != nil) {
            let currentAllowedIp = getCurrentAllowedIp()
            
            if(currentAllowedIp != nil && !system.locationServicesEnabled) {
                return currentAllowedIp!.safetyType
            }
            
            return SafetyType.unsafe
        }
        
        return SafetyType.unknown
    }
    
    private func getCurrentAllowedIp() -> IpInfo? {
        var result: IpInfo? = nil
        
        for allowedIp in userData.allowedIps {
            if (network.publicIp?.ipAddress == allowedIp.ipAddress) {
                result = allowedIp
            }
        }
        
        return result
    }
    
    private func isHighRisk() -> Bool {
        return monitoring.isEnabled && system.locationServicesEnabled
    }
    
    private func isCountryDetected() -> Bool {
        return network.publicIp != nil && !network.publicIp!.countryName.isEmpty
    }
    
    private func findMainInterface() -> String {
        for activeInterface in network.activeNetworkInterfaces {
            for physicalInterface in network.physicalNetworkInterfaces {
                if (activeInterface.name == physicalInterface.name) {
                    return activeInterface.name
                }
            }
        }
        
        return current.mainNetworkInterface
    }
}
